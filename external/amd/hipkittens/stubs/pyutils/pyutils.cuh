// A stand-in for HipKittens' pybind11 bindings: binding a dispatch function still instantiates it,
// and with it the kernel it launches, which is all a device-only compilation needs.
#pragma once

namespace kittens::py {
template<auto function, typename TGlobal>
static void bind_function(auto, auto, auto TGlobal::*...) { auto bound = function; (void)bound; }
template<auto kernel, typename TGlobal>
static void bind_kernel(auto, auto, auto TGlobal::*...) { auto bound = kernel; (void)bound; }
}

struct pybind11_module_stub {
    const char *doc_text = nullptr;
    const char *&doc() { return doc_text; }
};
#define PYBIND11_MODULE(name, m) [[maybe_unused]] static void pybind11_module_##name(pybind11_module_stub &m)
