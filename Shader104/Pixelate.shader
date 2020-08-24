Shader "Shader104/Pixelate"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Slider("Slider",Range(0,1)) = 0.5
        _PixelateAmt("Amount", Range(0,500)) = 1
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
            float _Slider;
            float _PixelateAmt;

            float4 frag (v2f i) : SV_Target
            {
                
                float4 col;

                //pixelate
                float2 uv = i.uv;
                uv.x *= _PixelateAmt;
                uv.y *= _PixelateAmt;
                uv.x = round(uv.x);
                uv.y = round(uv.y);
                uv.x /= _PixelateAmt;
                uv.y /= _PixelateAmt;

                if(i.uv.x>_Slider){
                    col = tex2D(_MainTex , uv);
                }
                else{
                    col = tex2D(_MainTex , i.uv);
                }

                return col;
            }
            ENDCG
        }
    }
}