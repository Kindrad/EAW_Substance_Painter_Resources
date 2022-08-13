

import lib-sampler.glsl
import lib-defines.glsl
import lib-sparse.glsl
import lib-vectors.glsl
import lib-utils.glsl
import lib-defines.glsl




//: param auto channel_basecolor
uniform SamplerSparse basecolor_tex;

//: param auto channel_specular 
uniform SamplerSparse specularcolor_tex;

//: param auto channel_blendingmask  
uniform SamplerSparse blendingmask_tex;

//: param auto environment_rotation
uniform float uniform_environment_rotation;


//: param auto main_light
uniform vec4 light_main;



//: param custom {
//:  "default": 10.0,
//:   "min": 0.0,
//:   "max": 30.0,
//:   "label": "Light Strength"
//: }
uniform float u_brightness;



//: param custom {
//:  "default": 0.3,
//:   "min": 0.0,
//:   "max": 30.0,
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
//:    "default": [1.0, 0.5, 0.0],
//:    "label": "Team Color",
//:    "widget": "color",
//:    "visible": "input.u_show_team" 
//: }
uniform vec3 u_team_color;


void shade(V2F inputs)
{

    vec4 oneVec = vec4(1.0,1.0,1.0,1.0);

    LocalVectors vectors = computeLocalFrame(inputs);

    float NdotL = max(0.0, dot(vectors.normal, light_main.xyz));
    float NdotV = clamp(dot(vectors.normal, vectors.eye), 0.0, 1.0);
    float NdotH = max(0.0, dot(vectors.normal, normalize(light_main.xyz + vectors.eye)));

    ////albedo
    vec3 albedo =  getBaseColor(basecolor_tex, inputs.sparse_coord);

    if(u_show_team)
    {
        float blend_mask = textureSparse(blendingmask_tex, inputs.sparse_coord).r;
        albedo = mix(albedo, u_team_color, blend_mask);
    }

    
    //diffuse lighting value
    vec3 diffuse = oneVec.rgb * clamp(NdotL * 2.0, u_dark_bright, u_brightness);


    ////specular lighting value
    vec3 specular = getSpecularColor(specularcolor_tex, inputs.sparse_coord).rgb * pow(NdotH, 16) * u_brightness;

    //recall lighting = albedo * diffuse + specular

    //output channels
    albedoOutput(albedo);
    diffuseShadingOutput(diffuse);
    specularShadingOutput(specular);

}
