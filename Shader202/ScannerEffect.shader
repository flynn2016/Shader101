Shader "Shader 202/SceneTransition"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_ScanDistance("Scan Distance", float) = 0
		_ScanWidth("Scan Width", float) = 10

		_Matrix00("Matrix00",float) = 1
		_Matrix01("Matrix01",float) = 1
		_Matrix02("Matrix02",float) = 1
		_Matrix10("Matrix10",float) = 1
		_Matrix11("Matrix11",float) = -7.5
		_Matrix12("Matrix12",float) = 1
		_Matrix20("Matrix20",float) = 1
		_Matrix21("Matrix21",float) = 1
		_Matrix22("Matrix22",float) = 1

		_EdgeColor("_EdgeColor",Color) = (1,1,1,1)
		_BackColor("_BackColor",Color) = (0,0,0,0)
		_Threshold("_Threshold",Range(0,1)) = 0.1

	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct VertIn
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 ray : TEXCOORD1;
			};

			struct VertOut
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float2 uv_depth : TEXCOORD1;
				float4 interpolatedRay : TEXCOORD2;
			};

			float4 _MainTex_TexelSize;
	
			VertOut vert(VertIn v)
			{
				VertOut o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv.xy;
				o.uv_depth = v.uv.xy;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
					o.uv.y = 1 - o.uv.y;
				#endif				

				o.interpolatedRay = v.ray;

				return o;
			}

			sampler2D _MainTex;
			sampler2D_float _CameraDepthTexture;
			float4 _WorldSpaceScannerPos;
			float _ScanDistance;
			float _ScanWidth;

			float _Matrix00;
			float _Matrix01;
			float _Matrix02;
			float _Matrix10;
			float _Matrix11;
			float _Matrix12;
			float _Matrix20;
			float _Matrix21;
			float _Matrix22;

			float4 _EdgeColor;
			float4 _BackColor;
			float _Threshold;

			float4 horizBars(float2 p)
			{
				return 1 - saturate(round(abs(frac(p.y * 100) * 2)));
			}

			float4 box(sampler2D tex, float2 uv, float4 size)
			{
				float4 c = tex2D(tex, uv + float2(-size.x, size.y)) * _Matrix00 + tex2D(tex, uv + float2(0, size.y)) * _Matrix01
					+ tex2D(tex, uv + float2(size.x, size.y)) * _Matrix02 + tex2D(tex, uv + float2(-size.x, 0)) * _Matrix10
					+ tex2D(tex, uv + float2(0, 0)) * _Matrix11 + tex2D(tex, uv + float2(size.x, 0)) * _Matrix12
					+ tex2D(tex, uv + float2(-size.x, -size.y)) * _Matrix20 + tex2D(tex, uv + float2(0, -size.y)) * _Matrix21
					+ tex2D(tex, uv + float2(size.x, -size.y)) * _Matrix22;

				return c / (_Matrix00 + _Matrix01 + _Matrix02 + _Matrix10 + _Matrix11 + _Matrix12 + _Matrix20 + _Matrix21 + _Matrix22);
			}

			half4 frag (VertOut i) : SV_Target
			{
				half4 col = tex2D(_MainTex, i.uv);
				half4 edge = box(_MainTex, i.uv, _MainTex_TexelSize);
				float linearDepth = Linear01Depth(DecodeFloatRG(tex2D(_CameraDepthTexture, i.uv_depth)));

				float4 wsDir = linearDepth * i.interpolatedRay;
				float3 wsPos = _WorldSpaceCameraPos + wsDir;

				float dist = distance(wsPos, _WorldSpaceScannerPos);

				if (dist > _ScanDistance) // 范围外
				{
					//return col; //greyscale
					if (edge.r > 0)
						return _BackColor;
					else
						return _EdgeColor;
				}

				else {
					//return 0.299 * col.r + 0.587 * col.g + 0.114 * col.b; 
					_Threshold = (1-((_ScanDistance-dist)/ _ScanDistance));

					if (edge.r > 0)
						return lerp(_BackColor, col, 1 - pow(_Threshold, 4));
					else
						return lerp(_EdgeColor, col, 1 - pow(_Threshold, 4));
				}
				return col;
			}
			ENDCG
		}
	}
}
