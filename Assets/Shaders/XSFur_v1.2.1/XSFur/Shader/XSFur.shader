// Upgrade NOTE: replaced tex2D unity_Lightmap with UNITY_SAMPLE_TEX2D

Shader "Custom/Avatar Shaders/Fur Shader (Advance)" {
    Properties {
		[Header(Base Layer Settings)]
			_MainTex ("Main Texture", 2D) = "gray" {}
			_Color ("Skin Tint", Color) = (1,1,1,1) 
			_RampSkin ("Skin Ramp", 2D) = "white" {}

		[Space(8)]
		[Header(Fur Settings)]
			[Enum(UV1, 0, UV2, 1)] _UVSet("UV Channel", Int) = 0
			_furTex ("Fur Texture", 2D) = "white" {}
			_Color2 ("Fur Tint", Color) = (1,1,1,1)
			_Color3 ("Undercoat Tint", Color) = (0,0,0,1)
			_RampFur ("Fur Ramp", 2D) = "white" {}
			[NoScaleOffset]_CutoutMap("Fur Pattern (Noise)", 2D) = "white" {}
			_lengthMask ("Length Mask", 2D) = "white" {}
			[IntRange]_layers ("Fur Layers", range(1,16)) = 10
			_offset ("Fur Length", range(0, 0.01)) = 0.0014
			_Cutout ("Fur Density", range(0.01,.5)) = 0.15
			_density ("Strand Amount", range(1, 200)) = 10
			_x("X Comb", range(-1, 1)) = 0
			_y("Y Comb", range(-1, 1)) = 0
			_Reflectance("Reflectance", range(0,1)) = 0
			_smoothness ("Smoothness", range(0,1)) = 0
			_gravity ("Gravity", range(0,1)) = 0

		[Space(8)]
		[Header(Emission)]
			_Emission ("Skin Emission Texture", 2D) = "white" {}
			[HDR]_EmissionColor ("Skin Emission Color", Color) = (0,0,0,0) 
			_Emission2 ("Fur Emission Texture", 2D) = "white" {}
			[HDR]_EmissionColor2 ("Fur Emission Color", Color) = (0,0,0,0) 

		[Space(8)]
		[Header(Light Settings)]
			[Toggle] _useRampColor ("Use Ramp Color", Int) = 0
			[Toggle] _fakeLight ("Use Fake Light Only", Int) = 0
			_fakeLightDir ("Fake Light Direction", Vector) = (0,0,0,1)
			_furOcclusionStrength("Occlusion Strength", range(0,1)) = 1

			
    }
    SubShader {
			
			Pass{ Name "FORWARD" 
				  Tags{"LightMode" = "ForwardBase" 
					   "RenderType"="TransparentCutout" 
				 	   "Queue"="AlphaTest"}

			Cull Off
			AlphaToMask On

			CGPROGRAM
			#pragma exclude_renderers d3d11 gles
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#define UNITY_PASS_FORWARDBASE
			//#pragma multi_compile_fwdbase_fullshadows
			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0
			#include "AutoLight.cginc"
			#include "Lighting.cginc"			

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
				float3 color : COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float3 worldPos: TEXCOORD3;
				float3 viewDir : TEXCOORD4;
				float3 color : TEXCOORD5;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 furUV : TEXCOORD2;
				float3 normal : TEXCOORD3; 
				float4 worldPos : TEXCOORD4;
				float3 viewDir : TEXCOORD5;
				float4 multiOutput : TEXCOORD6;
			};

		 	sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CutoutMap;
			float4 _CutoutMap_ST;
			sampler2D _lengthMask;
			float4 _lengthMask_ST;
			sampler2D _furTex;
			float4 _furTex_ST;
			sampler2D _Emission;
			float4 _Emission_ST;
			sampler2D _Emission2;
			float4 _Emission2_ST;
			sampler2D _RampFur;
			sampler2D _RampSkin;

			float3 _Color;
			float3 _Color2;
			float3 _Color3;
			float4 _EmissionColor;
			float4 _EmissionColor2;
			float4 _fakeLightDir;
			
			int _fakeLight;
			int _useRampColor;
			int _UVSet;

			float _offset;
			float _layers;
			float _Cutout;
			float _offsetLayers;
			float _density;
			float _patternIntensity;
			float _smoothness;
			float _Reflectance;
			float _x;
			float _y;
			float _gravity;
			float _furOcclusionStrength;

			#include "XSFHelperFunctions.cginc"
			#include "XSFGeometry.cginc"
			#include "XSFLighting.cginc"
			#include "XSFVertFrag.cginc"
			
			ENDCG
			}
			
			Pass{ Name "FORWARD_DELTA" 
				  Tags{"LightMode" = "ForwardAdd" 
					   "RenderType"="TransparentCutout" 
				 	   "Queue"="AlphaTest"}
			Blend One One
			Cull Off
			AlphaToMask On
			ZWrite Off

			CGPROGRAM
			#pragma exclude_renderers d3d11 gles
			#pragma vertex vert
			#pragma fragment frag
			#pragma geometry geom
			#define UNITY_PASS_FORWARDBASE
			#pragma multi_compile_fwdadd
			#pragma only_renderers d3d11 glcore gles
			#pragma target 4.0
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			struct VertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 worldPos : TEXCOORD2;
				float3 viewDir : TEXCOORD3;
				float3 color : COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float3 worldPos: TEXCOORD3;
				float3 viewDir : TEXCOORD4;
				float3 color : TEXCOORD5;
			};

			struct g2f
			{
				float4 pos : SV_POSITION;
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 furUV : TEXCOORD2;
				float3 normal : TEXCOORD3; 
				float4 worldPos : TEXCOORD4;
				float3 viewDir : TEXCOORD5;
				float4 multiOutput : TEXCOORD6;
			};

		 	sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _CutoutMap;
			float4 _CutoutMap_ST;
			sampler2D _lengthMask;
			float4 _lengthMask_ST;
			sampler2D _furTex;
			float4 _furTex_ST;
			sampler2D _Emission;
			float4 _Emission_ST;
			sampler2D _Emission2;
			float4 _Emission2_ST;
			sampler2D _RampFur;
			sampler2D _RampSkin;

			float3 _Color;
			float3 _Color2;
			float3 _Color3;
			float4 _EmissionColor;
			float4 _EmissionColor2;
			float4 _fakeLightDir;
			
			int _fakeLight;
			int _useRampColor;
			int _UVSet;

			float _offset;
			float _layers;
			float _Cutout;
			float _offsetLayers;
			float _density;
			float _patternIntensity;
			float _smoothness;
			float _Reflectance;
			float _x;
			float _y;
			float _gravity;
			float _furOcclusionStrength;

			#include "XSFHelperFunctions.cginc"
			#include "XSFGeometry.cginc"
			#include "XSFLighting.cginc"
			#include "XSFVertFrag.cginc"
			
			ENDCG
			}
    }
    FallBack "Transparent/Cutout/Diffuse"
}