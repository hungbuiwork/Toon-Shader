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
    }
    SubShader
    {
        Pass {
            Tags{ "LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            //user defined variable
            uniform float4 _Color;
            uniform float4 _AmbientColor;
            uniform float _ShadowThreshold;
            //unity defined variable
            uniform float3 _LightColor0;


            struct vertexInput{
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                float4 col: COLOR;
            };
            struct vertexOutput{
                float4 pos: SV_POSITION;
                float4 col: COLOR;
            };

            vertexOutput vert(vertexInput v){
                vertexOutput o;
                float3 normalDirection = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
                float3 lightDirection;
                //float atten = 1.0;
                lightDirection = normalize(_WorldSpaceLightPos0.xyz);

                float3 lightIntensity = dot(normalDirection, lightDirection);
                float3 light = lightIntensity * _LightColor0;
                o.col = float4(lightIntensity, 1.0);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag(vertexOutput i): Color{
                return i.col > _ShadowThreshold ? _Color: _AmbientColor * _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
