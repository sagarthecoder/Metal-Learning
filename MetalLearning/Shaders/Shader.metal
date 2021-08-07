//
//  Shader.metal
//  MetalLearning
//
//  Created by sz ashik on 6/8/21.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
    float animateBy;
};

vertex float4 vertex_shader(const device packed_float3 *vertices [[ buffer(0) ]], constant Constants &constants [[ buffer(1) ]], uint vertex_id [[ vertex_id ]]) {
    
    float4 position = float4(vertices[vertex_id], 1);
    position.x += constants.animateBy;
    //return float4(vertices[vertex_id], 1);
    return position;
}

fragment half4 fragment_shader() {
    return half4(1,0,0,1);
}


