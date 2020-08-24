Shader "Shader104/RGBsplit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset("Offset",Range(-0.1,0.1)) = 0
    }
    SubShader
    {
        Tags
        {
            "PreviewType" = "Plane"
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            sampler2D _MainTex;
            float _Offset;

            float4 frag (v2f i) : SV_Target
            {
                //chromatic aberration 
                float4 red = tex2D(_MainTex , i.uv - _Offset);           
                float4 green = tex2D(_MainTex, i.uv);
                float4 blue = tex2D(_MainTex, i.uv + _Offset);
                float4 color = float4(red.r,green.g,blue.b,1);

                return color;
            }
            ENDCG
        }
    }
}