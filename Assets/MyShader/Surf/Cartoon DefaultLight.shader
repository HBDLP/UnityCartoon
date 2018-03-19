Shader "CartoonSurface/Default Light" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap("Bumpmap", 2D) = "bump"{}
		_Tooniness("Tooniess", Range(0.1, 20)) = 4
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows
		
		#pragma surface surf Lambert finalcolor:final
		//#pragma surface surf BasicDiffuse

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BumpMap;
		float _Tooniness;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;


		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			
			o.Albedo = floor(o.Albedo * _Tooniness) / _Tooniness;
			
			// Metallic and smoothness come from slider variables
			//o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness;
			
			o.Alpha = c.a;

			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
		}

		void final(Input IN, SurfaceOutput o, inout fixed4 color)
		{
			color = floor(color * _Tooniness) / _Tooniness;
		}

		//float4 LightingBasicDiffuse(SurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		//{
		//	float difLight = max(0, dot(o.Normal, lightDir));
		//	float4 col;
		//	col.rgb = o.Albedo * _LightColor0.rgb * (difLight * atten * 2);
		//	col.a = o.Alpha;
		//	
		//	return col;
		//}	

		ENDCG
	}
	FallBack "Diffuse"
}
