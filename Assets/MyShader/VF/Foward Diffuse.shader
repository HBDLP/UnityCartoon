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
				LIGHTING_COORDS(3, 4)
			};

			sampler2D _MainTex;
			sampler2D _BumpTex;
			
			float4 _MainTex_ST;
			float4 _BumpTex_ST;

			v2f vert (appdata v)
			{
				v2f o;

				TANGENT_SPACE_ROTATION;
				o.lightDirection = mul(rotation, ObjSpaceLightDir(v.vertex));
				o.pos = UnityObjectToClipPos(v.vertex);				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2 = TRANSFORM_TEX(v.uv, _BumpTex);
				
				TRANSFER_VERTEX_TO_FRAGMENT(o);

				return o;
			}

			fixed4 frag (v2f i) : COLOR
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				float3 n = UnpackNormal(tex2D(_BumpTex, i.uv2));

				float3 lightColor = UNITY_LIGHTMODEL_AMBIENT.xyz * 2;
				float atten = LIGHT_ATTENUATION(i);

				float diff = max(0, dot(n, normalize(_WorldSpaceLightPos0.xyz)));
				lightColor += _LightColor0.rgb *  diff * atten;

				col.rgb = col.rgb * lightColor * 2;
			
				return col;
			}
			ENDCG
		}
	}
}
