Shader "Unlit/PlayerSightTile"
{
    Properties
    {
        [PerRendererData]_MainTex ("Outside Texture", 2D) = "white" {}
        _MaskTex ("Mask Texture", 2D) = "white" {}
        _FadeWidth ("Fade Width", Float) = 1.0 // 부드럽게 전환될 영역의 너비
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        LOD 100
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // get from properties
            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _Radius;
            float _FadeWidth;

            // get from global value
            float3 _PlayerPos;
            float _PlayerSightRadius;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD1;
                fixed4 color : COLOR;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.color = v.color;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // float dist = distance(i.worldPos.xy, _PlayerPos.xy);
                // float alpha = 1.0 -  smoothstep(_PlayerSightRadius, _PlayerSightRadius + _FadeWidth, dist);
                // fixed4 col = tex2D(_MainTex, i.uv);
                // col.a *= alpha;

                float normalX = smoothstep(_PlayerPos.x - _PlayerSightRadius, _PlayerPos.x + _PlayerSightRadius, i.worldPos.x);
                float normalY = smoothstep(_PlayerPos.y - _PlayerSightRadius, _PlayerPos.y + _PlayerSightRadius, i.worldPos.y);
                float2 maskUV = float2(normalX, normalY);
                
                float alpha = tex2D(_MaskTex, maskUV).a;
                if (alpha < 0.5)
                    alpha = 0.0;
                
                fixed4 col = tex2D(_MainTex, i.uv);
                col.a *= alpha;
                
                return col * i.color;
            }

            ENDHLSL
        }
    }
}
