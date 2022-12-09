//Created by Hung Bui
Shader "Custom/HBToon"
{
    
    Properties
    {
        [Header(Color Settings)]
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (.5,.5,.5,1)

        [Header(Shadow Settings)]
        [MaterialToggle]_EnableShadows("Enable Shadows", Float) = 1
        _ShadowThreshold("Shadow Treshold", Range(-1.0, 1.0)) = 0.0
        _ShadowSmoothness("Shadow Smoothness", Range(0.01, 0.5)) = 0.01

        [Header(Specular Settings)]
        [MaterialToggle]_EnableSpecularLight("Enable Specular Light", Float) = 0
        _SpecularColor("Specular Color", Color) = (1,1,1,1)
        _SpecularSmoothness("Specular Smoothness", Range(0.001, 0.02)) = 0.001
        _SpecularIntensity("Specular Intensity", Range(0,32)) = 32

        [Header(Rimlight Settings)]
        [MaterialToggle]_EnableRimlight("Enable Rimlight", Float) = 0
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimSmoothness("Rim Smoothness", Range(0.01, 0.5)) = 0.01
        _RimAmount("Rim Amount", Range(0,1))= .5
        _RimIntensity("Rim Intensity", Range(0, 1)) = 1

        [Header(Outline Settings)]
        [MaterialToggle]_EnableOutline("Enable Outline", Float) = 0
        _OutlineSize("Outline Size", Range(0, 0.1)) = 0
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _DepthOffset("Outline Depth", Range(0, .2)) = 0

        [MaterialToggle]_EnableCastShadows("Enable Cast Shadows", Float) = 1



    }
    SubShader
    {
        Pass{
            Cull Front
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag

            uniform float _OutlineSize;
            uniform float4 _OutlineColor;
            uniform float _EnableOutline;
            uniform float _DepthOffset;

            struct vertexInput{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            //output of vertex shader, input of fragment shader
            struct v2f{
                float4 pos: SV_POSITION;
                float3 normal: NORMAL;
                float3 viewDir: TEXCOORD1;
            };


            v2f vert(vertexInput v){
                v2f o;
                //Computer correct normals, positions, and the view direction
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                if (_EnableOutline){
                    o.pos = v.vertex + _OutlineSize * normalize(float4(v.normal, 0.0));
                }
                else{
                    o.pos = v.vertex;
                }
                float depthOffset = _DepthOffset;
                o.pos = UnityObjectToClipPos(o.pos);
                o.pos.z -= _DepthOffset;
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            float4 frag(v2f i): Color{
                return _OutlineColor;
            }
            ENDCG
            

        }

        Pass {
            Tags{ 
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }

            CGPROGRAM

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            



            //user defined variables
            uniform float4 _Color;
            uniform float4 _AmbientColor;
            uniform float _ShadowThreshold; 
            uniform float _ShadowSmoothness;
            uniform float _SpecularIntensity;
            uniform float4 _SpecularColor;
            uniform float _SpecularSmoothness;
            uniform float4 _RimColor;
            uniform float _RimAmount;
            uniform float _RimIntensity;
            uniform float _RimSmoothness;
            uniform sampler2D _MainTex;
            //user defined variables: toggle variables
            uniform float _EnableShadows;
            uniform float _EnableSpecularLight;
            uniform float _EnableRimlight;
            uniform float _EnableCastShadows;

            //unity defined variables
            uniform float3 _LightColor0;

            //same as appdata, input for vertex shader
            struct vertexInput{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float2 uv : TEXCOORD0;
                
            };
            //output of vertex shader, input of fragment shader
            struct v2f{
                float4 pos: SV_POSITION;
                float3 normal: NORMAL;
                float3 viewDir: TEXCOORD1;
                float2 uv : TEXCOORD0;
                LIGHTING_COORDS(2,3)
            };

            v2f vert(vertexInput v){
                v2f o;
                //Computer correct normals, positions, and the view direction
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.pos = v.vertex;
                o.pos = UnityObjectToClipPos(o.pos);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.uv = v.uv;
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }


            float4 frag(v2f i): Color{
                float shadow = LIGHT_ATTENUATION(i);
                float3 lightDir;
                //normalize the lighting direction
                lightDir = normalize(_WorldSpaceLightPos0.xyz);

                //calculate light intensity at fragment using dot product
                //smoothstep allows us to create abrupt changes in color, to "toonify"
                float3 lightIntensity = smoothstep(-_ShadowSmoothness + _ShadowThreshold, _ShadowSmoothness + _ShadowThreshold, dot(i.normal, lightDir) * (_EnableCastShadows?shadow:1)); 
                float3 light = lightIntensity * _LightColor0;

                //Calculate specular highlight
                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(lightDir + viewDir);
                float specularIntensity = smoothstep(.01 - _SpecularSmoothness, .01 + _SpecularSmoothness,  _SpecularColor * pow(dot(i.normal, halfVector) * lightIntensity, _SpecularIntensity * _SpecularIntensity ));
                float4 specular = specularIntensity * _SpecularColor;

                //Calculate rim shading
                float rimIntensity = smoothstep((1 -_RimAmount) - _RimSmoothness, (1 - _RimAmount) + _RimSmoothness, 1.0 - dot(viewDir, i.normal)) * (lightIntensity * _RimIntensity);
                float4 rim = rimIntensity * _RimColor;

                //combine lighting, color, etc. depending on toggles
                float4 final = _Color;
                if (_EnableShadows){final *= float4(light, 0.0);}
                if (_EnableSpecularLight){final += specular;}
                if (_EnableRimlight){final += rim;}
                return final + _AmbientColor;
            }
            ENDCG
        }
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
        
    }
    //fallback in case subshader fails
    FallBack "Diffuse"
}
