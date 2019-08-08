// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Misc/Greenscreen Shader" {//The Shaders Name
//The inputs shown in the material panel
Properties {
	_MainTex ("Texture", 2D) = "white" {}
	_Green_Despill ("Green Despill", Range(0.000000000,1.000000000)) = 1.000000000
	_Bias ("Bias", Range(0.000000000,-1.000000000)) = -0.281250000
	_Hardness ("Hardness", Range(1.000000000,20.000000000)) = 10.500000000
}

SubShader {
	Tags { "RenderType"="Opaque" "Queue"="Transparent" }//A bunch of settings telling Unity a bit about the shader.
	LOD 200
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
	ZTest LEqual
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha
	Cull Back//Culling specifies which sides of the models faces to hide.

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma target 3.0
				#pragma multi_compile_fog
				#pragma multi_compile __ UNITY_COLORSPACE_GAMMA
				#pragma multi_compile_fwdbase
				#include "HLSLSupport.cginc"
				#include "UnityShaderVariables.cginc"
				#define UNITY_PASS_FORWARDBASE
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal
			//Make our inputs accessible by declaring them here.
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float _Green_Despill;
				float _Bias;
				float _Hardness;

	float4 GammaToLinear(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float4 GammaToLinearForce(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float4 LinearToGamma(float4 col){
		return col;
	}

	float4 LinearToGammaForWeirdSituations(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float3 GammaToLinear(float3 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

	float3 GammaToLinearForce(float3 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

	float3 LinearToGamma(float3 col){
		return col;
	}

	float GammaToLinear(float col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

















struct VertexShaderInput{
	float4 vertex : POSITION;
	float4 texcoord : TEXCOORD0;
};
struct VertexToPixel{
	float4 position : POSITION;
	float2 uv_MainTex : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
	#undef pos
};

struct VertexData{
	float4 position;
	float2 uv_MainTex;
	float Mask0;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture
				//Sample parts of the layer:
					half4 TextureSurface_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(min(Surface.rgb,TextureSurface_Sample1.rgb),1) ;//0
	
	
			//Generate Layer: Texture3
				//Sample parts of the layer:
					half4 Texture3Surface_Sample1 = GammaToLinear(float4(0, 1, 0.213793, 1));
	
	Surface = lerp(Surface,half4((Surface.rgb - Texture3Surface_Sample1.rgb), 1),_Green_Despill * vd.Mask0);//2
	
	
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( VertexData vd, half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy
				//Sample parts of the layer:
					half4 Mask0_CopyTransparency_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
				//Apply Effects:
					Mask0_CopyTransparency_Sample1.rgb = float4(dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))));
					Mask0_CopyTransparency_Sample1.rgb = (float3(1,1,1)-Mask0_CopyTransparency_Sample1.rgb);
					Mask0_CopyTransparency_Sample1.rgb = (Mask0_CopyTransparency_Sample1.rgb+_Bias);
					Mask0_CopyTransparency_Sample1.rgb = lerp(float3(0.5,0.5,0.5),Mask0_CopyTransparency_Sample1.rgb,_Hardness);
					Mask0_CopyTransparency_Sample1.rgb = clamp(Mask0_CopyTransparency_Sample1.rgb,0,1);
	
	Surface = Mask0_CopyTransparency_Sample1.r;//0
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor.a *= 1;
	return outputColor;
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0 Copy Copy
				//Sample parts of the layer:
					half4 Mask0_Copy_CopyMask0_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
				//Apply Effects:
					Mask0_Copy_CopyMask0_Sample1.rgb = float4(dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))));
	
	Mask0 = Mask0_Copy_CopyMask0_Sample1.r;//2
	
	
	return Mask0;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	
	
	
	
	vtp.position = vd.position;
	vtp.uv_MainTex = vd.uv_MainTex;
	#define pos position
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
	#undef pos
	return vtp;
}
			half4 Pixel (VertexToPixel vtp) : SV_Target {
				half4 outputColor = half4(0,0,0,0);
				half3 outputNormal = half3(0,0,1);
				half3 depth = half3(0,0,0);//Tangent Corrected depth, World Space depth, Normalized depth
				half3 tempDepth = half3(0,0,0);
				VertexData vd;
				UNITY_INITIALIZE_OUTPUT(VertexData,vd);
				vd.uv_MainTex = vtp.uv_MainTex;
vd.Mask0 = Mask_Mask0 ( vd);
				half4 outputUnlit = Unlit ( vd);
				outputColor = outputUnlit;//10
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( vd, outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
				UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				return outputColor;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "ShadowCaster"
		Tags { "LightMode" = "ShadowCaster" }
	ZTest LEqual
	ZWrite On
	Blend Off//No transparency
	Cull Back//Culling specifies which sides of the models faces to hide.

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma target 3.0
				#pragma multi_compile_fog
				#pragma multi_compile __ UNITY_COLORSPACE_GAMMA
				#pragma multi_compile_shadowcaster
				#include "HLSLSupport.cginc"
				#include "UnityShaderVariables.cginc"
				#define SHADERSANDWICH_SHADOWCASTER
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal
			//Make our inputs accessible by declaring them here.
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float _Green_Despill;
				float _Bias;
				float _Hardness;

	//From UnityCG.inc, Unity 2017.01 - works better than any of the earlier ones
	inline float3 UnityObjectToWorldNormalNew( in float3 norm ){
		#ifdef UNITY_ASSUME_UNIFORM_SCALING
			return UnityObjectToWorldDir(norm);
		#else
			// mul(IT_M, norm) => mul(norm, I_M) => {dot(norm, I_M.col0), dot(norm, I_M.col1), dot(norm, I_M.col2)}
			return normalize(mul(norm, (float3x3)unity_WorldToObject));
		#endif
	}
	float4 GammaToLinear(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float4 GammaToLinearForce(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float4 LinearToGamma(float4 col){
		return col;
	}

	float4 LinearToGammaForWeirdSituations(float4 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			col.rgb = pow(col,2.2);
		#endif
		return col;
	}

	float3 GammaToLinear(float3 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

	float3 GammaToLinearForce(float3 col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

	float3 LinearToGamma(float3 col){
		return col;
	}

	float GammaToLinear(float col){
		#if defined(UNITY_COLORSPACE_GAMMA)
			//Best programming evar XD
		#else
			col = pow(col,2.2);
		#endif
		return col;
	}

















struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
};
struct VertexToPixel{
	float4 position : POSITION;
	float2 uv_MainTex : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
#undef pos
	#ifdef SHADOWS_CUBE
		float3 vec : TEXCOORD2;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos : TEXCOORD3;
		#endif
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float2 uv_MainTex;
	#ifdef SHADOWS_CUBE
		float3 vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos;
		#endif
	#endif
	float Mask0;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture
				//Sample parts of the layer:
					half4 TextureSurface_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(min(Surface.rgb,TextureSurface_Sample1.rgb),1) ;//0
	
	
			//Generate Layer: Texture3
				//Sample parts of the layer:
					half4 Texture3Surface_Sample1 = GammaToLinear(float4(0, 1, 0.213793, 1));
	
	Surface = lerp(Surface,half4((Surface.rgb - Texture3Surface_Sample1.rgb), 1),_Green_Despill * vd.Mask0);//2
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( VertexData vd, half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy
				//Sample parts of the layer:
					half4 Mask0_CopyTransparency_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
				//Apply Effects:
					Mask0_CopyTransparency_Sample1.rgb = float4(dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_CopyTransparency_Sample1.rgb,float3((-0.39),1,(-0.59))));
					Mask0_CopyTransparency_Sample1.rgb = (float3(1,1,1)-Mask0_CopyTransparency_Sample1.rgb);
					Mask0_CopyTransparency_Sample1.rgb = (Mask0_CopyTransparency_Sample1.rgb+_Bias);
					Mask0_CopyTransparency_Sample1.rgb = lerp(float3(0.5,0.5,0.5),Mask0_CopyTransparency_Sample1.rgb,_Hardness);
					Mask0_CopyTransparency_Sample1.rgb = clamp(Mask0_CopyTransparency_Sample1.rgb,0,1);
	
	Surface = Mask0_CopyTransparency_Sample1.r;//0
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	clip (outputColor.a - 0.3333333);
	outputColor.a *= 1;
	return outputColor;
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0 Copy Copy
				//Sample parts of the layer:
					half4 Mask0_Copy_CopyMask0_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
				//Apply Effects:
					Mask0_Copy_CopyMask0_Sample1.rgb = float4(dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))),dot(Mask0_Copy_CopyMask0_Sample1.rgb,float3((-0.39),1,(-0.59))));
	
	Mask0 = Mask0_Copy_CopyMask0_Sample1.r;//2
	
	
	return Mask0;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	
	
	
	
	vtp.position = vd.position;
	vtp.uv_MainTex = vd.uv_MainTex;
	#define pos position
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
#undef pos
	#ifdef SHADOWS_CUBE
	vtp.vec = vd.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
	vtp.hpos = vd.hpos;
		#endif
	#endif
	return vtp;
}
			half4 Pixel (VertexToPixel vtp) : SV_Target {
				half4 outputColor = half4(0,0,0,0);
				half3 outputNormal = half3(0,0,1);
				half3 depth = half3(0,0,0);//Tangent Corrected depth, World Space depth, Normalized depth
				half3 tempDepth = half3(0,0,0);
				VertexData vd;
				UNITY_INITIALIZE_OUTPUT(VertexData,vd);
				vd.uv_MainTex = vtp.uv_MainTex;
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
vd.Mask0 = Mask_Mask0 ( vd);
				half4 outputUnlit = Unlit ( vd);
				outputColor = outputUnlit;//10
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( vd, outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
				UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				SHADOW_CASTER_FRAGMENT(vd)
				return outputColor;

			}
		ENDCG
	}
}

Fallback "Legacy Shaders/Diffuse"
}


/*
Shader Sandwich Shader
	File Format Version(Float): 3.0
	Begin Shader Base

		Begin Shader Input
			Type(Text): "Image"
			VisName(Text): "Texture"
			ImageDefault(Float): 0
			Image(Text): "dc3f8350ad07d0443b4dc300584d813a"
			NormalMap(Float): 0
			DefaultTexture(Text): "White"
			SeeTilingOffset(Toggle): True
			TilingOffset(Vec): 1,1,0,0
			MainType(Text): "MainTexture"
			CustomFallback(Text): "_MainTex"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Green Despill"
			Number(Float): 1
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Green_Despill"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Bias"
			Number(Float): -0.28125
			Range0(Float): 0
			Range1(Float): -1
			CustomFallback(Text): "_Bias"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Hardness"
			Number(Float): 10.5
			Range0(Float): 1
			Range1(Float): 20
			CustomFallback(Text): "_Hardness"
		End Shader Input

		ShaderName(Text): "Shader Sandwich/Specific/Greenscreen"
		Tech Lod(Float): 200
		Fallback(Type): Diffuse - {TypeID = 0}
		CustomFallback(Text): "\qLegacy Shaders/Diffuse\q"
		Queue(Type): Auto - {TypeID = 0}
		Custom Queue(Float): 2000
		QueueAuto(Toggle): True
		Replacement(Type): Auto - {TypeID = 0}
		ReplacementAuto(Toggle): True
		Tech Shader Target(Float): 3
		Exclude DX9(Toggle): False

		Begin Masks

			Begin Shader Layer List

				LayerListUniqueName(Text): "Mask0"
				LayerListName(Text): "Mask0"
				Is Mask(Toggle): True
				EndTag(Text): "r"

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy Copy"
					Layer Type(ObjectArray): SLTTexture - {ObjectID = 1}
					UV Map(Type): UV Map - {TypeID = 0}
					Map Local(Toggle): False
					Map Space(Type): World - {TypeID = 0}
					Map Generate Space(Type): Object - {TypeID = 1}
					Map Inverted(Toggle): True
					Map UV Index(Float): 1
					Map Direction(Type): Normal - {TypeID = 0}
					Map Screen Space(Type): Screen Position - {TypeID = 4}
					Use Fadeout(Toggle): False
					Fadeout Limit Min(Float): 0
					Fadeout Limit Max(Float): 10
					Fadeout Start(Float): 3
					Fadeout End(Float): 5
					Use Alpha(Toggle): False
					Alpha Blend Mode(Type): Blend - {TypeID = 0}
					Mix Amount(Float): 1
					Mix Type(Type): Mix - {TypeID = 0}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Texture(Texture): dc3f8350ad07d0443b4dc300584d813a - {Input = 0}
					Cubemap(Cubemap): 
					Noise Dimensions(Type): SSN/A - {TypeID = 0}
					Color(Vec): 1,1,1,1
					Color 2(Vec): 0,0,0,1
					Jitter(Float): 0
					Fill(Float): 0
					MinSize(Float): 0
					Edge(Float): 1
					MaxSize(Float): 1
					Square(Toggle): False
					Begin Shader Effect
						TypeS(Text): "SSEMathDot"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						R(Float): -0.39
						G(Float): 1
						B(Float): -0.59
						A(Float): 0
					End Shader Effect

					Begin Shader Effect
						TypeS(Text): "SSEInvert"
						IsVisible(Toggle): False
						UseAlpha(Float): 0
					End Shader Effect

				End Shader Layer

			End Shader Layer List

		End Masks

		Begin Shader Pass
			Name(Text): "Base"
			Visible(Toggle): True

			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceUnlit"
				User Name(Text): "Unlit"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Blend - {TypeID = 0}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): True
				RenderForEachLight(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Unlit"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "Texture"
						Layer Type(ObjectArray): SLTTexture - {ObjectID = 1}
						UV Map(Type): UV Map - {TypeID = 0}
						Map Local(Toggle): False
						Map Space(Type): World - {TypeID = 0}
						Map Generate Space(Type): Object - {TypeID = 1}
						Map Inverted(Toggle): True
						Map UV Index(Float): 1
						Map Direction(Type): Normal - {TypeID = 0}
						Map Screen Space(Type): Screen Position - {TypeID = 4}
						Use Fadeout(Toggle): False
						Fadeout Limit Min(Float): 0
						Fadeout Limit Max(Float): 10
						Fadeout Start(Float): 3
						Fadeout End(Float): 5
						Use Alpha(Toggle): False
						Alpha Blend Mode(Type): Blend - {TypeID = 0}
						Mix Amount(Float): 1
						Mix Type(Type): Darken - {TypeID = 6}
						Stencil(ObjectArray): SSNone - {ObjectID = -1}
						Texture(Texture): dc3f8350ad07d0443b4dc300584d813a - {Input = 0}
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 0.627451,0.8,0.8823529,1
						Color 2(Vec): 0,0,0,1
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Texture3"
						Layer Type(ObjectArray): SLTColor - {ObjectID = 0}
						UV Map(Type): UV Map - {TypeID = 0}
						Map Local(Toggle): False
						Map Space(Type): World - {TypeID = 0}
						Map Generate Space(Type): Object - {TypeID = 1}
						Map Inverted(Toggle): True
						Map UV Index(Float): 1
						Map Direction(Type): Normal - {TypeID = 0}
						Map Screen Space(Type): Screen Position - {TypeID = 4}
						Use Fadeout(Toggle): False
						Fadeout Limit Min(Float): 0
						Fadeout Limit Max(Float): 10
						Fadeout Start(Float): 3
						Fadeout End(Float): 5
						Use Alpha(Toggle): False
						Alpha Blend Mode(Type): Blend - {TypeID = 0}
						Mix Amount(Float): 1 - {Input = 1}
						Mix Type(Type): Subtract - {TypeID = 2}
						Stencil(ObjectArray): Mask0 - {ObjectID = 0}
						Color(Vec): 0,1,0.213793,1
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color 2(Vec): 0,0,0,1
						Texture(Texture): 
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
					End Shader Layer

				End Shader Layer List

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceTransparency"
				User Name(Text): "Transparency"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Replace - {TypeID = 3}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Transparency"
					LayerListName(Text): "Transparency"
					Is Mask(Toggle): False
					EndTag(Text): "r"

					Begin Shader Layer
						Layer Name(Text): "Legacy Transparency Base"
						Layer Type(ObjectArray): SLTNumber - {ObjectID = 7}
						UV Map(Type): UV Map - {TypeID = 0}
						Map Local(Toggle): False
						Map Space(Type): World - {TypeID = 0}
						Map Generate Space(Type): Object - {TypeID = 1}
						Map Inverted(Toggle): True
						Map UV Index(Float): 1
						Map Direction(Type): Normal - {TypeID = 0}
						Map Screen Space(Type): Screen Position - {TypeID = 4}
						Use Fadeout(Toggle): False
						Fadeout Limit Min(Float): 0
						Fadeout Limit Max(Float): 10
						Fadeout Start(Float): 3
						Fadeout End(Float): 5
						Use Alpha(Toggle): False
						Alpha Blend Mode(Type): Blend - {TypeID = 0}
						Mix Amount(Float): 1
						Mix Type(Type): Mix - {TypeID = 0}
						Stencil(ObjectArray): SSNone - {ObjectID = -2}
						Number(Float): 1
						Color(Vec): 0.5,0.8823529,1,1
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Mask0 Copy"
						Layer Type(ObjectArray): SLTTexture - {ObjectID = 1}
						UV Map(Type): UV Map - {TypeID = 0}
						Map Local(Toggle): False
						Map Space(Type): World - {TypeID = 0}
						Map Generate Space(Type): Object - {TypeID = 1}
						Map Inverted(Toggle): True
						Map UV Index(Float): 1
						Map Direction(Type): Normal - {TypeID = 0}
						Map Screen Space(Type): Screen Position - {TypeID = 4}
						Use Fadeout(Toggle): False
						Fadeout Limit Min(Float): 0
						Fadeout Limit Max(Float): 10
						Fadeout Start(Float): 3
						Fadeout End(Float): 5
						Use Alpha(Toggle): False
						Alpha Blend Mode(Type): Blend - {TypeID = 0}
						Mix Amount(Float): 1
						Mix Type(Type): Mix - {TypeID = 0}
						Stencil(ObjectArray): SSNone - {ObjectID = -1}
						Texture(Texture): dc3f8350ad07d0443b4dc300584d813a - {Input = 0}
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 1,1,1,1
						Color 2(Vec): 0,0,0,1
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
						Begin Shader Effect
							TypeS(Text): "SSEMathDot"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							R(Float): -0.39
							G(Float): 1
							B(Float): -0.59
							A(Float): 0
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEInvert"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEMathAdd"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Add(Float): -0.28125 - {Input = 2}
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEContrast"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Contrast(Float): 10.5 - {Input = 3}
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEMathClamp"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Min(Float): 0
							Max(Float): 1
						End Shader Effect

					End Shader Layer

				End Shader Layer List

			End Shader Ingredient

			Geometry Ingredients

			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierMisc"
				User Name(Text): "Misc Settings"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				ZWriteMode(Type): Auto - {TypeID = 0}
				ZTestMode(Type): Closer or Equal - {TypeID = 3}
				CullMode(Type): Back Faces - {TypeID = 0}
				ShaderModel(Type): Shader Model 3.0 - {TypeID = 3}
				Use Fog(Toggle): True
				Use Lightmaps(Toggle): True
				Use Forward Full Shadows(Toggle): True
				Use Forward Vertex Lights(Toggle): True
				Use Shadows(Toggle): True
				Generate Forward Base Pass(Toggle): True
				Generate Forward Add Pass(Toggle): False
				Generate Deferred Pass(Toggle): False
				Generate Shadow Caster Pass(Toggle): True

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierTransparency"
				User Name(Text): "Transparency"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				Transparency Type(Type): Fade - {TypeID = 1}
				Transparency ZWrite(Type): Off - {TypeID = 0}
				Shadow Type Fade(Type): Cutout - {TypeID = 1}
				Cutout Amount(Float): 0.3333333
				Transparency(Float): 1
				Blend Mode(Type): Mix - {TypeID = 0}

			End Shader Ingredient

		End Shader Pass

	End Shader Base
End Shader Sandwich Shader
*/
