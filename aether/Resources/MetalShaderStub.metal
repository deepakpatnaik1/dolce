//
//  MetalShaderStub.metal
//  Aether
//
//  Empty Metal shader to generate default.metallib
//
//  ATOMIC RESPONSIBILITY: Provide minimal Metal shader
//  - Satisfies Metal compiler requirements
//  - Generates default.metallib to prevent fopen errors
//  - Contains only placeholder functionality
//  - No actual rendering logic
//

#include <metal_stdlib>
using namespace metal;

// Placeholder vertex function
vertex float4 placeholder_vertex(uint vertexID [[vertex_id]]) {
    return float4(0.0, 0.0, 0.0, 1.0);
}

// Placeholder fragment function
fragment float4 placeholder_fragment() {
    return float4(0.0, 0.0, 0.0, 0.0);
}

// Placeholder compute kernel
kernel void placeholder_compute(uint id [[thread_position_in_grid]]) {
    // Empty kernel to satisfy compilation
}