Shader "Glitch/Scenetransition"
{
    Properties
    {
        _MainTex("-", 2D) = "" {}
        _NoiseTex("-", 2D) = "" {}
        _NoiseTex_2("-", 2D) = "" {}
    }

    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            float4 _WorldSpaceScannerPos; 
            sampler2D _NoiseTex;
            sampler2D _NoiseTex_2;
            sampler2D _Test;
            float _Intensity;
            float _BlackScreen_Slider;
            float _uv_Slider;
            float _Edge_Slider;
            float _Offset;
            float _Blend_toggle;
            float4 box(sampler2D tex, float2 uv, float4 size)
            {
                float4 c = tex2D(tex, uv + float2(-size.x, size.y)) * 1 + tex2D(tex, uv + float2(0, size.y)) * 1
                    + tex2D(tex, uv + float2(size.x, size.y)) * 1 + tex2D(tex, uv + float2(-size.x, 0)) * 1
                    + tex2D(tex, uv + float2(0, 0)) * -7 + tex2D(tex, uv + float2(size.x, 0)) * 1
                    + tex2D(tex, uv + float2(-size.x, -size.y)) * 1 + tex2D(tex, uv + float2(0, -size.y)) * 1
                    + tex2D(tex, uv + float2(size.x, -size.y)) * 1;

                return c;
            }

            float4 frag(v2f_img i) : SV_Target
            {
                float4 source = tex2D(_MainTex, i.uv);
                float4 glitch = tex2D(_NoiseTex_2, i.uv);
                
                //edge detection
                float4 edge = box(_MainTex, float2(i.uv.x + glitch.g/10, i.uv.y - glitch.b/10), _MainTex_TexelSize);
                if (edge.r > _Edge_Slider) {
                    edge = edge / 5;
                    if(_Blend_toggle)
                    glitch = float4(0, 0, 0, 0);
                }
                else
                    edge = source;

                //distorted souce
                float2 uv = i.uv + float2(0.1, 0.1);
                float4 distort = tex2D(_MainTex, uv);

                // random movement
                if (glitch.g > 0.8)
                    i.uv += float2(_Offset * glitch.b * 2 - 1, 0);
                else if (glitch.g < 0.2)
                    i.uv += float2(0, -_Offset * glitch.b * 2 - 1);

                float4 noise = tex2D(_NoiseTex, i.uv);

                float step_value_1 = step(1.001 - _Intensity*1.001, pow(glitch.w, 2.5)); // step_value_1
                float step_value_2 = step(_BlackScreen_Slider*1.001, pow(glitch.w, 2.5)); // step_value_2
                float step_value_3 = step(1.001- _uv_Slider*1.001, pow(glitch.g, 2.5)); // step_value_3
                float step_value_4 = step(0.001, 1-_Edge_Slider);

                float3 color;
                //lerp all the color
                color = lerp(source, edge, step_value_4);
                color = lerp(color, distort.rgb, step_value_3);
                color = lerp(color, noise.rgb * glitch.b, step_value_1);
                color = lerp(color, glitch.r, step_value_2);

                return float4(color.rgb,source.a);
            }
            ENDCG

        }
    }
}
