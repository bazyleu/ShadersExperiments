Shader "Unlit/WavesShader"
{
    Properties
    {
        _ShorelineTex ("Shoreline", 2D) = "black" {}
        _WaterDeep("Water Deep", Color) = (1, 1, 1)
        _WaterShallow("Water Shallow", Color) = (1, 1, 1)
        _WaveColor("Wave Color", Color) = (1, 1, 1)
        _WaveSize ("WaveSize", Float) = 0.03
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _ShorelineTex;
            float4 _ShorelineTex_ST;

            float3 _WaterDeep;
            float3 _WaterShallow;
            float3 _WaveColor;
            float _WaveSize;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _ShorelineTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float shoreline = tex2D(_ShorelineTex, i.uv).x;
                float waveSize = _WaveSize;
                float waveAmp =  (sin(shoreline/waveSize + _Time.y * 10) + 1) * 0.5;
                waveAmp *= shoreline;

                float3 waterColor = lerp(_WaterDeep, _WaterShallow, shoreline);
                float3 waterWithWaves = lerp(waterColor, _WaveColor, waveAmp);

                return float4(waterWithWaves, 1);
            }
            ENDCG
        }
    }
}
