// Store the selected workgroup coordinates from kernels using one axis or all three.
// The single-axis kernels also exercise descriptors with unused workgroup-ID inputs.
__kernel void workgroup_x(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_x();
}

__kernel void workgroup_y(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_y();
}

__kernel void workgroup_z(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_z();
}

__kernel void workgroup_xyz(__global unsigned *out) {
    unsigned i = __builtin_amdgcn_workitem_id_x();
    out[i] = __builtin_amdgcn_workgroup_id_x();
    out[i + 64] = __builtin_amdgcn_workgroup_id_y();
    out[i + 128] = __builtin_amdgcn_workgroup_id_z();
}
