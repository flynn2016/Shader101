Shader "Shader102/Depth"
{
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
		}

		ZWrite On


		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float depth : DEPTH;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.depth = -(mul(UNITY_MATRIX_MV, v.vertex).z) * _ProjectionParams.w;
				return o;
			}

			float4 _Color_1;
			float _Temp;

			fixed4 frag(v2f i) : SV_Target
			{
				float invert = 1 - i.depth;

			if (abs(i.depth- _Temp / 2)<0.005)
				return fixed4(invert*2, 0.2, 0.2, 1);
			else
				return fixed4(invert, 0.3, 0.3,1) ;
			}
			ENDCG
		}
	}
}
