// Writes the Volta launch file of one CUTLASS kernel launch from its host-built `Params`.
//
// A unit builds the kernel's `Arguments` over fake device pointers (`Launch::array`), runs
// CUTLASS's own `to_underlying_arguments`, and passes the `Params` to `Launch::write`. The
// TMA encoders below stand in for the driver's: each records its arguments and stamps the
// descriptor with a marker, so `write` finds every descriptor inside the `Params` bytes and
// emits it as a `tensor_map` field. No GPU and no driver are needed.
#pragma once

#include <cuda.h>

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <typeinfo>
#include <vector>

namespace volta {

constexpr uint64_t kMapMarker = 0x50414d41544c4f56ull;  // "VOLTAMAP"

struct MapRecord {
  CUtensorMapDataType dtype;
  uint64_t address;
  std::vector<uint64_t> dims, strides;
  std::vector<uint32_t> box, element_strides;
  bool im2col = false;
  std::vector<int> lower, upper;
  uint32_t channels_per_pixel = 0, pixels_per_column = 0;
  CUtensorMapInterleave interleave;
  CUtensorMapSwizzle swizzle;
  CUtensorMapFloatOOBfill fill;
};

inline std::vector<MapRecord>& maps() {
  static std::vector<MapRecord> recorded;
  return recorded;
}

inline CUresult stamp(CUtensorMap* map, MapRecord record) {
  std::memset(map, 0, sizeof(CUtensorMap));
  auto* words = reinterpret_cast<uint64_t*>(map);
  words[0] = kMapMarker;
  words[2] = maps().size();
  maps().push_back(std::move(record));
  return CUDA_SUCCESS;
}

struct ArrayDef {
  std::string name, kind, dtype;
  std::vector<long> shape;
  uint64_t base;
  std::vector<long> contents;
};

[[noreturn]] inline void fail(std::string const& message) {
  std::fprintf(stderr, "volta_launch: %s\n", message.c_str());
  std::exit(1);
}

inline std::string json_string(std::string const& s) {
  std::string out = "\"";
  for (char c : s) {
    if (c == '"' || c == '\\') out += '\\';
    out += c;
  }
  return out + "\"";
}

template <class T>
std::string json_list(std::vector<T> const& values) {
  std::ostringstream out;
  out << "[";
  for (size_t i = 0; i < values.size(); ++i) out << (i ? ", " : "") << values[i];
  out << "]";
  return out.str();
}

inline char const* map_dtype(CUtensorMapDataType t) {
  switch (t) {
    case CU_TENSOR_MAP_DATA_TYPE_UINT8: return "u8";
    case CU_TENSOR_MAP_DATA_TYPE_UINT16: return "u16";
    case CU_TENSOR_MAP_DATA_TYPE_UINT32: return "u32";
    case CU_TENSOR_MAP_DATA_TYPE_INT32: return "s32";
    case CU_TENSOR_MAP_DATA_TYPE_UINT64: return "u64";
    case CU_TENSOR_MAP_DATA_TYPE_INT64: return "s64";
    case CU_TENSOR_MAP_DATA_TYPE_FLOAT16: return "f16";
    case CU_TENSOR_MAP_DATA_TYPE_FLOAT32: return "f32";
    case CU_TENSOR_MAP_DATA_TYPE_FLOAT64: return "f64";
    case CU_TENSOR_MAP_DATA_TYPE_BFLOAT16: return "bf16";
    case CU_TENSOR_MAP_DATA_TYPE_FLOAT32_FTZ: return "f32_ftz";
    case CU_TENSOR_MAP_DATA_TYPE_TFLOAT32: return "tf32";
    default: fail("tensor map of an element type Volta does not model (" + std::to_string(int(t)) + ")");
  }
}

inline std::string map_swizzle(CUtensorMapSwizzle s) {
  switch (s) {
    case CU_TENSOR_MAP_SWIZZLE_NONE: return "\"swizzle\": \"none\"";
    case CU_TENSOR_MAP_SWIZZLE_32B: return "\"swizzle\": \"32B\"";
    case CU_TENSOR_MAP_SWIZZLE_64B: return "\"swizzle\": \"64B\"";
    case CU_TENSOR_MAP_SWIZZLE_128B: return "\"swizzle\": \"128B\"";
    case CU_TENSOR_MAP_SWIZZLE_128B_ATOM_32B: return "\"swizzle\": \"128B\", \"swizzle_atomicity\": \"32B\"";
    case CU_TENSOR_MAP_SWIZZLE_128B_ATOM_32B_FLIP_8B:
      return "\"swizzle\": \"128B\", \"swizzle_atomicity\": \"32B_flip_8B\"";
    case CU_TENSOR_MAP_SWIZZLE_128B_ATOM_64B: return "\"swizzle\": \"128B\", \"swizzle_atomicity\": \"64B\"";
    default: fail("unknown swizzle mode");
  }
}

// One launch: the arrays a unit hands the kernel and, at `write`, its `Params`.
class Launch {
 public:
  explicit Launch(std::string description) : description_(std::move(description)) {}

  // A fake device pointer to a new array, 256 MiB apart so no TMA box leaves its own.
  template <class T>
  T* array(std::string name, std::string kind, std::string dtype, std::vector<long> shape,
           std::vector<long> contents = {}) {
    uint64_t base = 0x10000000ull * (arrays_.size() + 1);
    arrays_.push_back({std::move(name), std::move(kind), std::move(dtype), std::move(shape), base,
                       std::move(contents)});
    return reinterpret_cast<T*>(base);
  }

  void spec(std::string file, std::map<std::string, long> dims) {
    spec_ = std::move(file);
    dims_ = std::move(dims);
  }

  void cta(int x, int y = 0, int z = 0) {
    cta_[0] = x;
    cta_[1] = y;
    cta_[2] = z;
  }

  template <class Kernel, class Params>
  void write(std::string const& path, Params const& params, dim3 grid, dim3 block, int smem,
             dim3 cluster = dim3(1, 1, 1)) const {
    std::ofstream out(path);
    if (!out) fail("cannot write " + path);
    out << "{\n  \"description\": " << json_string(description_) << ",\n";
    out << "  \"kernel\": " << json_string(std::string("@type:") + typeid(Kernel).name()) << ",\n";
    out << "  \"grid\": [" << grid.x << ", " << grid.y << ", " << grid.z << "],\n";
    out << "  \"block\": [" << block.x << ", " << block.y << ", " << block.z << "],\n";
    out << "  \"cluster\": [" << cluster.x << ", " << cluster.y << ", " << cluster.z << "],\n";
    out << "  \"cta\": [" << cta_[0] << ", " << cta_[1] << ", " << cta_[2] << "],\n";
    out << "  \"dynamic_shared_bytes\": " << smem << ",\n  \"arrays\": [\n";
    for (size_t i = 0; i < arrays_.size(); ++i) {
      auto const& a = arrays_[i];
      out << "    {\"name\": " << json_string(a.name) << ", \"kind\": " << json_string(a.kind)
          << ", \"dtype\": " << json_string(a.dtype) << ", \"shape\": " << json_list(a.shape)
          << ", \"base\": \"0x" << std::hex << a.base << std::dec << "\"";
      if (!a.contents.empty()) out << ", \"contents\": " << json_list(a.contents);
      out << "}" << (i + 1 < arrays_.size() ? "," : "") << "\n";
    }
    out << "  ],\n  \"params\": [{\"name\": \"params\", \"struct\": [\n";
    out << fields(reinterpret_cast<unsigned char const*>(&params), sizeof(Params));
    out << "  ]}]";
    if (!spec_.empty()) {
      out << ",\n  \"spec\": " << json_string(spec_) << ",\n  \"dims\": {";
      size_t i = 0;
      for (auto const& [name, value] : dims_) out << (i++ ? ", " : "") << json_string(name) << ": " << value;
      out << "}";
    }
    out << "\n}\n";
  }

 private:
  std::string array_at(uint64_t address) const {
    for (auto const& a : arrays_)
      if (a.base == address) return a.name;
    return "";
  }

  std::string map_field(size_t offset, MapRecord const& m) const {
    std::string array = array_at(m.address);
    if (array.empty()) {
      std::ostringstream at;
      at << "a tensor map at 0x" << std::hex << m.address << " is based at no array's start";
      fail(at.str());
    }
    std::ostringstream f;
    f << "    {\"offset\": " << offset << ", \"tensor_map\": {\"array\": " << json_string(array)
      << ", \"dtype\": \"" << map_dtype(m.dtype) << "\", \"dims\": " << json_list(m.dims)
      << ", \"strides\": " << json_list(m.strides);
    if (m.im2col) {
      f << ", \"im2col\": {\"lower_corner\": " << json_list(m.lower) << ", \"upper_corner\": "
        << json_list(m.upper) << ", \"channels_per_pixel\": " << m.channels_per_pixel
        << ", \"pixels_per_column\": " << m.pixels_per_column << "}";
    } else {
      f << ", \"box\": " << json_list(m.box);
    }
    f << ", \"element_strides\": " << json_list(m.element_strides) << ", " << map_swizzle(m.swizzle);
    if (m.interleave != CU_TENSOR_MAP_INTERLEAVE_NONE) fail("interleaved tensor map");
    f << ", \"fill\": \"" << (m.fill == CU_TENSOR_MAP_FLOAT_OOB_FILL_NONE ? "zero" : "nan") << "\"}}";
    return f.str();
  }

  // Every byte of the struct: tensor maps by their marker, array bases as pointers, else words.
  std::string fields(unsigned char const* bytes, size_t size) const {
    std::vector<std::string> out;
    size_t offset = 0;
    while (offset < size) {
      uint64_t word64 = 0;
      if (offset % 8 == 0 && offset + 8 <= size) std::memcpy(&word64, bytes + offset, 8);
      if (offset % 64 == 0 && offset + 128 <= size && word64 == kMapMarker) {
        uint64_t index;
        std::memcpy(&index, bytes + offset + 16, 8);
        out.push_back(map_field(offset, maps().at(index)));
        offset += 128;
      } else if (offset % 8 == 0 && offset + 8 <= size && !array_at(word64).empty()) {
        out.push_back("    {\"offset\": " + std::to_string(offset) + ", \"ptr\": " +
                      json_string(array_at(word64)) + "}");
        offset += 8;
      } else if (offset % 4 == 0 && offset + 4 <= size) {
        uint32_t word;
        std::memcpy(&word, bytes + offset, 4);
        out.push_back("    {\"offset\": " + std::to_string(offset) + ", \"u32\": " + std::to_string(word) + "}");
        offset += 4;
      } else {
        out.push_back("    {\"offset\": " + std::to_string(offset) + ", \"u8\": " +
                      std::to_string(bytes[offset]) + "}");
        offset += 1;
      }
    }
    std::string text;
    for (size_t i = 0; i < out.size(); ++i) text += out[i] + (i + 1 < out.size() ? ",\n" : "\n");
    return text;
  }

  std::string description_;
  std::vector<ArrayDef> arrays_;
  std::string spec_;
  std::map<std::string, long> dims_;
  int cta_[3] = {0, 0, 0};
};

// The launch file of case `name`, in the directory the unit's first argument names.
inline std::string case_path(char** argv, std::string const& name) {
  return std::string(argv[1]) + "/" + name + ".launch.json";
}

}  // namespace volta

extern "C" CUresult CUDAAPI cuTensorMapEncodeTiled(
    CUtensorMap* map, CUtensorMapDataType dtype, cuuint32_t rank, void* address, cuuint64_t const* dims,
    cuuint64_t const* strides, cuuint32_t const* box, cuuint32_t const* element_strides,
    CUtensorMapInterleave interleave, CUtensorMapSwizzle swizzle, CUtensorMapL2promotion,
    CUtensorMapFloatOOBfill fill) {
  volta::MapRecord r;
  r.dtype = dtype;
  r.address = reinterpret_cast<uint64_t>(address);
  r.dims.assign(dims, dims + rank);
  r.strides.assign(strides, strides + rank - 1);
  r.box.assign(box, box + rank);
  r.element_strides.assign(element_strides, element_strides + rank);
  r.interleave = interleave;
  r.swizzle = swizzle;
  r.fill = fill;
  return volta::stamp(map, std::move(r));
}

extern "C" CUresult CUDAAPI cuTensorMapEncodeIm2col(
    CUtensorMap* map, CUtensorMapDataType dtype, cuuint32_t rank, void* address, cuuint64_t const* dims,
    cuuint64_t const* strides, int const* lower, int const* upper, cuuint32_t channels_per_pixel,
    cuuint32_t pixels_per_column, cuuint32_t const* element_strides, CUtensorMapInterleave interleave,
    CUtensorMapSwizzle swizzle, CUtensorMapL2promotion, CUtensorMapFloatOOBfill fill) {
  volta::MapRecord r;
  r.dtype = dtype;
  r.address = reinterpret_cast<uint64_t>(address);
  r.dims.assign(dims, dims + rank);
  r.strides.assign(strides, strides + rank - 1);
  r.element_strides.assign(element_strides, element_strides + rank);
  r.im2col = true;
  r.lower.assign(lower, lower + rank - 2);
  r.upper.assign(upper, upper + rank - 2);
  r.channels_per_pixel = channels_per_pixel;
  r.pixels_per_column = pixels_per_column;
  r.interleave = interleave;
  r.swizzle = swizzle;
  r.fill = fill;
  return volta::stamp(map, std::move(r));
}
