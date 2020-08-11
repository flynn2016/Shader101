Shader "Shader103/Toon"
{
	Properties
	{
		_MainTex("Base texture", 2D) = "white" {}
		_RampTex("Ramp texture", 2D) = "white" {}

		_AmbientStrength("Ambient Strength",Range(0,1.0)) = 0.1
		_DiffStrength("Diff Strength",Range(0,1.0)) = 0.1
		_SpecStrength("Spec Strength",Range(0,5.0)) = 0.1

		_SpecPow("Specular Pow",int) = 0.5
		_Brightness("Brightness",Range(0,1.0)) = 0.5
		_TintColor("Tint Color",Color) = (1.0,1.0,1.0,1.0)

	}

	SubShader
	{
		Tags
		{
			"LightMode" = "ForwardBase"
			"PassFlags" = "OnlyDirectional"
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
			sampler2D _RampTex;

			float _AmbientStrength;
			float _SpecStrength;
			float _DiffStrength;

			float4 _TintColor;
			float _SpecPow;
			float _Brightness;

			float4 frag(v2f i) : SV_Target
			{
				float4 baseColor = tex2D(_MainTex, i.uv) ;
				float3 normal = normalize(i.normal);
				//ambient
				float3 ambient = _LightColor0 * _AmbientStrength;

				//diffuse
				float NdotL = dot(i.normal, _WorldSpaceLightPos0);
				float2 uv = float2((NdotL * 0.5 + 0.5), 0);
				float3 ramp = tex2D(_RampTex, uv);

				float3 diff = (NdotL < 0) ? 0 : 1 * _LightColor0 * _DiffStrength;// 把(NdotL < 0) ? 0 : 1 改成ramp 如果需要用自己的texture

				//specular
				float3 reflectDir = reflect(-_WorldSpaceLightPos0, normal);
				float spec = pow(max(dot(i.viewDir, reflectDir), 0.0), _SpecPow);
				float3 specSmooth = smoothstep(0.005, 0.01, spec) * _LightColor0 * _SpecStrength;

				//final color
				float4 final_color = float4((diff + ambient+ specSmooth),1.0) * _Brightness * baseColor * _TintColor;
				return final_color ;
			}
			ENDCG
		}
	}
}
