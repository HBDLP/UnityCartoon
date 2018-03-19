Shader "CartoonSurface/HalfLambert Light" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_BumpMap("Bumpmap", 2D) = "bump"{}
		_Tooniness("Tooniess", Range(0.1, 20)) = 4
		_RampTex("Ramp Texture", 2D) = "white" {}
		_Outline("Outline", Range(0, 1)) = 0.4
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		//#pragma surface surf Standard fullforwardshadows
		
		//#pragma surface surf Lambert finalcolor:final
		#pragma surface surf BasicDiffuse

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
	
		sampler2D _MainTex;
		sampler2D _BumpMap;
		sampler2D _RampTex;	
		float _Tooniness;
		float _Outline;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BumpMap;
			float3 viewDir;
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
			
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));

			half edge = saturate(dot(normalize(IN.viewDir), o.Normal));
			edge = edge < _Outline ? edge / 4 : 1;

			o.Albedo = (floor(o.Albedo * _Tooniness) / _Tooniness) * edge;
			
			// Metallic and smoothness come from slider variables
			//o.Metallic = _Metallic;
			//o.Smoothness = _Glossiness;
			
			o.Alpha = c.a;

			
		}

		//void final(Input IN, SurfaceOutput o, inout fixed4 color)
		//{
		//	color = floor(color * _Tooniness) / _Tooniness;
		//}

		float4 LightingBasicDiffuse(SurfaceOutput o, half3 lightDir, half3 viewDir, half atten)
		{
			//float difLight = max(0, dot(o.Normal, lightDir));
			float difLight = dot(o.Normal, lightDir);
			float difLightHalf = difLight * 0.5 + 0.5;
			
			//float rimLight = max(0, dot(o.Normal, viewDir));
			float rimLight = dot(o.Normal, viewDir);
			float rimLightHalf = rimLight * 0.5 + 0.5;

			float3 ramp = tex2D(_RampTex, float2(rimLightHalf, difLightHalf)).rgb;

			float4 col;
			col.rgb = o.Albedo * _LightColor0.rgb * ramp;
			col.a = o.Alpha;
			
			return col;
		}	

		ENDCG
	}
	FallBack "Diffuse"
}
