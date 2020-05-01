Shader "MyShaders/HandmadeLighting"
{
    Properties
    {
           _Color ("Color", Color) = (1, 1, 1, 0)
           _Gloss ("Gloss", Float) = 1
    }
    SubShader
    {
        Tags { "LightMode" = "ForwardBase" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #include "UnityDeferredLibrary.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
                float2 uv0 : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv0 : TEXCOORD0;
                float3 normal: NORMAL;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv0 = v.uv0;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv0;
                float3 normal = normalize(i.normal);

                // Ligting

                // Direct diffuse light
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.rgb;
                float simpleLight = max(0, dot(lightDir, normal));
                float3 directDiffuseLight = simpleLight * lightColor;

                // Ambient
                float3 ambientLight = float3(0.1, 0.1, 0.1);


                //Direct specular light
                 float3 camPos = _WorldSpaceCameraPos;
                 float3 fragToCam = camPos - i.worldPos;
                 float3 viewDir = normalize(fragToCam);
                 float3 viewrReflect = reflect(-viewDir, normal);

                 // Modify gloss
                 float3 specularFalloff = max(0, dot(viewrReflect, lightDir));
                 specularFalloff = pow(specularFalloff, _Gloss);
                 float3 directSpecular = specularFalloff * lightColor;

                 // Compose
                 float3 diffuseLight = ambientLight + directDiffuseLight;
                 float3 finalSurfaceColor = diffuseLight * _Color.rgb + directSpecular;


                 return float4(finalSurfaceColor, 0);
            }
            ENDCG
        }
    }
}
