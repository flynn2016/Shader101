Shader "Shader104/Kernal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Matrix00 ("Matrix00",float) = 1
        _Matrix01 ("Matrix01",float) = 1
        _Matrix02 ("Matrix02",float) = 1
        _Matrix10 ("Matrix10",float) = 1
        _Matrix11 ("Matrix11",float) = -8
        _Matrix12 ("Matrix12",float) = 1
        _Matrix20 ("Matrix20",float) = 1
        _Matrix21 ("Matrix21",float) = 1
        _Matrix22 ("Matrix22",float) = 1
        _Slider("Slider",Range(0,1)) = 0.5
        _Threshold("_Threshold",Range(0,1)) = 0.1
        _EdgeColor("_EdgeColor",Color) = (1,1,1,1)
        _BackColor("_BackColor",Color) = (0,0,0,0)

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
            float4 _MainTex_TexelSize;
            float _Matrix00;
            float _Matrix01;
            float _Matrix02;
            float _Matrix10;
            float _Matrix11;
            float _Matrix12;
            float _Matrix20;
            float _Matrix21;
            float _Matrix22;
            float _Slider;
            float _Threshold;
            float4 _EdgeColor;
            float4 _BackColor;

            float4 box(sampler2D tex, float2 uv, float4 size)
            {
                float4 c = tex2D(tex, uv + float2(-size.x, size.y))*_Matrix00 + tex2D(tex, uv + float2(0, size.y))*_Matrix01 
                + tex2D(tex, uv + float2(size.x, size.y)) *_Matrix02 + tex2D(tex, uv + float2(-size.x, 0)) * _Matrix10
                + tex2D(tex, uv + float2(0, 0))*_Matrix11 + tex2D(tex, uv + float2(size.x, 0))*_Matrix12 
                + tex2D(tex, uv + float2(-size.x, -size.y))*_Matrix20 + tex2D(tex, uv + float2(0, -size.y))*_Matrix21
                + tex2D(tex, uv + float2(size.x, -size.y))*_Matrix22;

                return c / (_Matrix00+_Matrix01+_Matrix02+_Matrix10+_Matrix11+_Matrix12+_Matrix20+_Matrix21+_Matrix22);
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = tex2D(_MainTex, i.uv);
                if(i.uv.x>_Slider){
                    color = box(_MainTex, i.uv, _MainTex_TexelSize);
                    if (color.r <= _Threshold && color.g <= _Threshold && color.b <= _Threshold)
                        return _EdgeColor;
                    else
                        return _BackColor;
                }
                else
                    if (color.r <= _Threshold && color.g <= _Threshold && color.b <= _Threshold)
                        return color;
                    else
                        return float4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}

