Shader "Shader104/Inverse"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Slider("Slider",Range(0,1)) = 0.5
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
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv: TEXCOORD0;
			};

			sampler2D _MainTex;
			float _Slider;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 color = tex2D(_MainTex,i.uv);
				if (i.uv.x > _Slider)
					return float4(1-color.r, 1-color.g, 1-color.b, 1);
				else
					return color;
			}
			ENDCG
		}
	}
}
