// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/HBToon"
{
    
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _AmbientColor("Ambient Color", Color) = (0,0,0,1)
        _ShadowThreshold("Shadow Treshold", Range(-1.0, 1.0)) = 0.0
        _EdgeSmoothness("Edge Smoothness", Range(0.01, 0.5)) = 0.01
        _SpecularColor("Specular Color", Color) = (0,0,0,0)
        _SpecularSmoothness("Specular Smoothness", Range(0.001, 0.01)) = 0.001
        _Glossiness("Glossiness", Float) = 32
    }
    SubShader
    {
        Pass {
            Tags{ 
                "LightMode" = "ForwardBase"
                "PassFlags" = "OnlyDirectional"
            }

            CGPROGRAM

            #include "UnityCG.cginc"
            //pragmas
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            //user defined variable
            uniform float4 _Color;
            uniform float4 _AmbientColor;
            uniform float _ShadowThreshold; //change to smoothstep later
            uniform float _EdgeSmoothness;
            uniform float _Glossiness;
            uniform float4 _SpecularColor;
            uniform float _SpecularSmoothness;
            //unity defined variable
            uniform float3 _LightColor0;


            struct vertexInput{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
            };
            struct v2f{
                float4 pos: SV_POSITION;
                float3 normal: NORMAL;
                float3 viewDir: TEXCOORD1;
            };

            v2f vert(vertexInput v){
                v2f o;
                o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                return o;
            }

            float4 frag(v2f i): Color{
                float3 lightDir;
                //calculate Blinn-Phong Shading
                lightDir = normalize(_WorldSpaceLightPos0.xyz);
                //This step creates a sharp line seen in toon shading
                float3 lightIntensity = smoothstep(-_EdgeSmoothness + _ShadowThreshold, _EdgeSmoothness + _ShadowThreshold, dot(i.normal, lightDir)); 
                float3 light = lightIntensity * _LightColor0;
                //Calculate Specular highlight
                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(lightDir + viewDir);
                float specularIntensity = smoothstep(.01 - _SpecularSmoothness, .01 + _SpecularSmoothness,  _SpecularColor * pow(dot(i.normal, halfVector) * lightIntensity, _Glossiness * _Glossiness));
                float4 specular = specularIntensity * _SpecularColor;
                //combine lighting, color, etc.
                return _Color * (float4(light, 0.0) + _AmbientColor + specular);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
