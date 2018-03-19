Shader "CartoonVF/Cartoon"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			
			#include "UnityCG.cginc"

			float _Outline;
			sampler2D _MainTex;

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
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				//将法线在法线空间下的坐标转换成View下的坐标
				float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);				
				//法线z值扁平化
				normal.z = -0.4;
				//描边
				pos = pos + float4(normalize(normal), 0) * _Outline;
						
				//o.vertex = UnityObjectToClipPos(v.vertex);
				//o.uv = v.uv;
				//将View下的顶点坐标转换到投影空间
				o.vertex = UnityObjectToClipPos(pos);

				
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
			
			#pragam vertex vert
			#pragam frament frag
			#pragam multi_compile_fwdbase
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityShaderVariables.cginc"

			sampler2D _MainTex;
			float _Outline;

			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
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

			v2f vert(a2v v)
			{
				v2f o;

			}

			ENDCG
		}
	}
}
