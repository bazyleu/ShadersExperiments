Shader "MyShaders/PolygonColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #pragma geometry geom
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2g
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR;
            };

            sampler2D _MainTex;

            float4 _MainTex_ST;

            float random(float2 x)
            {
                return frac(sin(dot(x, float2(12.9898,78.233)))*43758.5453123);
            }

            v2g vert (appdata v)
            {
                v2g o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g input[3], inout TriangleStream<g2f> tristream)
            {
                g2f o;

                for (int i = 0; i < 3; i++)
                {
                    o.pos = input[i].vertex;
                    o.uv = input[i].uv;
                    o.col = float4(random(input[0].vertex.x), random(input[0].vertex.y), random(input[1].vertex.x), 1);
                    tristream.Append(o);
                }
            }

            fixed4 frag (g2f i) : SV_Target
            {
                return i.col;
            }

            ENDCG
        }
    }
}
