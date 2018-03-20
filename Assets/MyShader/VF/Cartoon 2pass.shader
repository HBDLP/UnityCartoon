// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "CartoonVF/Cartoon 2pass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_RampTex ("Tamp Texture", 2D) = "white"{}
		_Tooniness ("Tooniness", range(0.1, 20)) = 4
		_Outline ("Outline", float) = 0.4
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque"}

		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			Cull Front
			Lighting Off
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "UnityCG.cginc"

			float _Outline;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;

				//将顶点在模型空间下的坐标转换成View下的坐标
				float3 pos = UnityObjectToViewPos(v.vertex);
				//将法线在法线空间下的坐标转换成View下的坐标
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);				
				//法线z值扁平化
				normal.z = -0.4;
				//描边
				pos.xy = pos.xy + float3(normalize(normal)).xy * _Outline;
						
				//o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = v.uv;
				//将View下的顶点坐标转换到投影空间
				o.vertex = mul(UNITY_MATRIX_P, pos);

				o.uv = v.uv;

				return o;
			}
			
			
			fixed4 frag (v2f i) : SV_Target
			{
				return float4(0, 0, 0, 1);
			}
			ENDCG
		}

		Pass
		{
			Tags {"LightMode" = "ForwardBase"}
			
			Cull Back
			Lighting On

			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			sampler2D _MainTex;
			sampler2D _RampTex;
			float _Outline;
			float4 _MainTex_ST;
			float _Tooniness;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float2 normal : TEXCOORD1;
				LIGHTING_COORDS(2, 3)
				float3 lightDirection : TEXCOORD4;
			};

			v2f vert(a2v v)
			{
				v2f o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.normal = mul((float3x3)unity_ObjectToWorld, SCALED_NORMAL);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.lightDirection = WorldSpaceViewDir(v.vertex);

				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			float4 frag(v2f v) : COLOR
			{
				float4 color = tex2D(_MainTex, v.uv);
				color.rgb = (floor(color.rgb * _Tooniness) / _Tooniness);

				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float atten = LIGHT_ATTENUATION(v);

				float diff = dot(normalize(v.normal), normalize(v.lightDirection));
				diff = diff * 0.5 + 0.5;

				diff = tex2D(_RampTex, float2(diff, diff));

				lightColor += _LightColor0.rgb * (diff * atten);

				color.rgb = lightColor * color.rgb * 2;
				color.a = 1;

				return color;
			}

			ENDCG
		}
	}
}
