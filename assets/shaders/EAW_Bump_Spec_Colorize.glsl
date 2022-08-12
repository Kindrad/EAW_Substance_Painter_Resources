

import lib-sampler.glsl
import lib-defines.glsl
import lib-sparse.glsl
import lib-vectors.glsl
import lib-utils.glsl
import lib-defines.glsl


//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;

//: param auto channel_specularlevel 
uniform SamplerSparse specularlevel_tex;

//: param auto channel_blendingmask  
uniform SamplerSparse blendingmask_tex;

//: param auto environment_rotation
uniform float uniform_environment_rotation;


//: param custom {
//:  "default": 0.2,
//:   "min": 0.0,
//:   "max": 1.0,
//:   "label": "Dark brightness"
//: }
uniform float u_dark_bright;


//: param custom {
//:  "default": false,
//:   "label": "Show Team Color"
//: }
uniform bool u_show_team;

//: param custom
//: {
//:    "default": 0,
//:    "label": "Team Color",
//:    "widget": "color",
//:    "visible": "input.u_show_team" 
//: }
uniform vec3 u_team_color;


void shade(V2F inputs)
{

    vec4 oneVec = vec4(1.0,1.0,1.0,1.0);

    float y_rot = -uniform_environment_rotation * 2 * M_PI;
    
    vec3 light_pos = vec3(cos(y_rot) * 10000.0, 10000.0, sin(y_rot) * 10000.0);


    LocalVectors vectors = computeLocalFrame(inputs);

    vec3 V = normalize(vectors.eye);
    vec3 N = normalize(vectors.normal);
    vec3 L = normalize(light_pos - inputs.position);
    vec3 HV = normalize(V + L);

    float NdV = dot(N, V);
    float NdL = clamp(dot(N, L), 0.0, 1.0);
    float NdH = clamp(dot(N,HV), 0.0, 1.0);

    ////albedo
    vec3 albedo =  getBaseColor(basecolor_tex, inputs.sparse_coord);

    if(u_show_team)
    {

        float blend_mask = textureSparse(blendingmask_tex, inputs.sparse_coord).r;

        albedo = mix(albedo, u_team_color, blend_mask);
    }
    
    //diffuse lighting value
    vec3 diffuse = oneVec.rgb * clamp(NdL * 2.0, u_dark_bright, 1.0);


    ////specular lighting value
    vec3 specular = oneVec.rgb * getSpecularLevel(specularlevel_tex, inputs.sparse_coord) * pow(NdH, 16);

    //recall lighting = albedo * diffuse + specular


    //output channels
    albedoOutput(albedo);
    diffuseShadingOutput(diffuse);
    specularShadingOutput(specular);

}
