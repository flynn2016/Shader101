// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Shader105/TwoPass"
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
		Pass
		{
			Tags {
			"LightMode" = "ForwardBase"
			}

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

		Pass
		{
			Blend One One
			Tags {

				"LightMode" = "ForwardAdd"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#define SPOT
			#include "AutoLight.cginc"
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
				float3 posWorld : TEXCOORD2;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.uv = v.uv;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex).xyz;
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
				//Light info
				float atten;
				float3 light_Dir;
				if (_WorldSpaceLightPos0.w == 0.0) // 0: direcitonal light  1: point light
				{
					atten = 1.0;
					light_Dir = _WorldSpaceLightPos0.xyz;
				}
				else {
					float3 frag_2_light = normalize(_WorldSpaceLightPos0.xyz - i.posWorld);
					//float dist = length(frag_2_light);
					//atten = 1 / (1+dist*dist);
					UNITY_LIGHT_ATTENUATION(temp, 0, i.posWorld);
					atten = temp;
					light_Dir = normalize(frag_2_light);
				}

				//texture
				float4 baseColor = tex2D(_MainTex, i.uv);

				//ambient 
				float3 ambient = _LightColor0 * _AmbientStrength;

				//diffuse
				float3 diff = dot(i.normal, light_Dir) * _LightColor0 * _DiffStrength;

				//specular
				float3 reflectDir = reflect(-light_Dir, i.normal);
				float3 spec = pow(max(dot(i.viewDir, reflectDir), 0.0), _SpecPow) * _LightColor0 * _SpecStrength;

				float4 final_color;
				if (_WorldSpaceLightPos0.w == 0.0) // 0: direcitonal light  1: point light
				{
					final_color = float4((spec + diff + ambient), 1.0) * baseColor * _Brightness;
				}
				else {
					final_color = float4((spec + diff), 1.0) * baseColor * _Brightness * atten;
				}
				//final color
				return final_color;
			}
			ENDCG
		}
	}
}
