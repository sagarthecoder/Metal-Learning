//
//  Shader.metal
//  MetalLearning
//
//  Created by sz ashik on 6/8/21.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]], uint vertex_id [[ vertex_id ]]) {
    
    return float4(vertices[vertex_id], 1);
}

fragment half4 fragment_shader() {
    return half4(1,0,0,1);
}


