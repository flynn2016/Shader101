Shader "Shader103/BasicLighting"
{
	Properties
	{
		_MainTex("Base texture", 2D) = "white" {}
		_AmbientStrength("Ambient Strength",Range(0,1.0)) = 0.1


		_DiffStrength("Diff Strength",Range(0,1.0)) = 0.1
		_SpecStrength("Spec Strength",Range(0,5.0)) = 0.1
		_SpecPow("Specular Pow",Range(0.1,256)) = 1
		_Brightness("Brightness",Range(0,2.0)) = 0.5
	}

	SubShader
	{
		Tags { 
			"LightMode" = "ForwardBase"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityLightingCommon.cginc" // for _LightColor0
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv: TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv: TEXCOORD0;			
				float3 viewDir : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld, v.vertex).xyz);
				return o;
			}

			sampler2D _MainTex;
			float _AmbientStrength;
			float _DiffStrength;
			float _SpecStrength;
			float _SpecPow;
			float _Brightness;

			float4 frag(v2f i) : SV_Target
			{
				//texture
				float4 baseColor = tex2D(_MainTex, i.uv) ;

				//ambient 
				float3 ambient = _LightColor0 * _AmbientStrength;

				//diffuse
				float3 diff = dot(i.normal,_WorldSpaceLightPos0) * _LightColor0 * _DiffStrength;

				//specular
				float3 reflectDir = reflect(-_WorldSpaceLightPos0, i.normal);
				float3 spec = pow(max(dot(i.viewDir, reflectDir), 0.0), _SpecPow) * _LightColor0 * _SpecStrength;
				
				//final color
				float4 final_color = float4((spec + diff + ambient),1.0)* baseColor* _Brightness;
				return final_color ;
			}
			ENDCG
		}
	}
}
