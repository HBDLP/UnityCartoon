// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "CartoonVF/Foward Diffuse"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpTex("Bump Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque"}


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

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float4 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float3 lightDirection : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
				LIGHTING_COORDS(4, 5)
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			float4 _MainTex_ST;
			float4 _BumpTex_ST;

			v2f vert (appdata v)
			{
				v2f o;

				
				
				o.pos = UnityObjectToClipPos(v.vertex);				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _BumpTex);
				
				TANGENT_SPACE_ROTATION;
				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
				//o.lightDirection = ObjSpaceLightDir(v.vertex);
				//o.lightDirection = mul((float3x3)unity_ObjectToWorld, ObjSpaceLightDir(v.vertex));
				o.worldNormal = mul(SCALED_NORMAL,  (float3x3)unity_WorldToObject);

				//TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 normal = UnpackNormal(tex2D(_BumpTex, i.uv2));
				
				float3 ambi = UNITY_LIGHTMODEL_AMBIENT.xyz;
				float atten = LIGHT_ATTENUATION(i);
				fixed3 lambert = 0.5 * dot(normal, normalize(i.lightDirection)) + 0.5;

				float diff = _LightColor0.rgb * lambert  * 1;

				col.rgb = col.rgb * (ambi + diff);
				col.a = 1;
				return col;
			}
			ENDCG
		}
	}
}
