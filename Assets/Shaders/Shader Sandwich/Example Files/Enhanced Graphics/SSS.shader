// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'
// Upgrade NOTE: replaced 'unity_World2Shadow' with 'unity_WorldToShadow'

Shader "Custom/Object Shaders/Sub Surface Scattering Shader" {//The Shaders Name
//The inputs shown in the material panel
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Color ("Color", Color) = (1,1,1,1)
	_BumpMap ("Normal", 2D) = "white" {}
	_Normal_Height ("Normal Height", Range(0.000000000,1.000000000)) = 0.000000000
	_Shininess ("Roughness", Range(0.002000000,1.000000000)) = 0.561815400
	_SSS_Scale ("SSS Scale", Range(0.000000000,1.000000000)) = 0.064373900
	_SSS_Color ("SSS Color", Color) = (1,0.3,0.3,1)
	_SSS_Fringing ("SSS Fringing", Range(0.000000000,1.000000000)) = 0.142857200
	_Scale_GLMin ("Scale - Min", Float) = 15.000000000
	_Scale_GLMax ("Scale - Max", Float) = 20.000000000
}

SubShader {
	Tags { "RenderType"="Opaque" "Queue"="Geometry" }//A bunch of settings telling Unity a bit about the shader.
	LOD 200
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
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
				float4 _Color;
				sampler2D _BumpMap;
float4 _BumpMap_ST;
float4 _BumpMap_HDR;
				float _Normal_Height;
				float _Shininess;
				float _SSS_Scale;
				float4 _SSS_Color;
				float _SSS_Fringing;
				float _Scale_GLMin;
				float _Scale_GLMax;

#if !defined (SSUNITY_BRDF_PBS) // allow to explicitly override BRDF in custom shader
	// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
	#if SHADER_TARGET < 30
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF3)
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF2)
		#define SSUNITY_BRDF_PBS 2
	#elif defined(UNITY_PBS_USE_BRDF1)
		#define SSUNITY_BRDF_PBS 1
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define SSUNITY_BRDF_PBS 1
	#else
		#error something broke in auto-choosing BRDF (Shader Sandwich)
	#endif
#endif

inline half GGXTermNoFadeout (half NdotH, half realRoughness){
	half a2 = realRoughness * realRoughness;
	half d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
	return a2 / (UNITY_PI * d * d);
}

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
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};
struct VertexToPixel{
	float4 position : POSITION;
	float3 screenPos : TEXCOORD0;
	float3 worldViewDir : TEXCOORD1;
	float4 TtoWSpaceX : TEXCOORD2;
	float4 TtoWSpaceY : TEXCOORD3;
	float4 TtoWSpaceZ : TEXCOORD4;
	float2 uv_MainTex : TEXCOORD5;
	float2 uv_BumpMap : TEXCOORD6;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh : TEXCOORD7;
#endif
	#define pos position
		SHADOW_COORDS(8)
		UNITY_FOG_COORDS(9)
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap : TEXCOORD10;
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldTangent;
	float3 worldBitangent;
	float3 screenPos;
	float3 worldViewDir;
	float3 worldRefl;
	float4 TtoWSpaceX;
	float4 TtoWSpaceY;
	float4 TtoWSpaceZ;
	float2 uv_MainTex;
	float2 uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap;
	#endif
	float Mask0;
	float Atten;
};
half2 SSSBlurRot( half2 d, float r ) {
	half2 sc = half2(sin(r),cos(r));
	return half2( dot( d, half2(sc.y, -sc.x) ), dot( d, sc.xy ) );
}

#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH) || defined (SHADOWS_CUBE)
	float ComputeScatteredShadow_Sub_Surface_Scattering(VertexData vd,VertexToPixel vtp, float3 lightDir, float blerg){
		float colShadow = 0;
		float3 bitangent = cross(vd.worldTangent,vd.worldNormal);
		float weight = 0;
		
		float sampleCount = 5;
		static float2 asd[5] = {
			float2(-0.7957063,0.3076356),
			float2(0.09538598,0.8763882),
			float2(0.229684,-0.6201293),
			float2(-0.7097354,-0.4950111),
			float2(0.3737206,0.1264346),
		};
		static float asdL[5] = {
			1.172189,
			1.134348,
			1.512177,
			1.155656,
			2.534671,
		};
		weight = 0.2;
		half PoissonBlurRandRotationAnimated = 6.28*frac(sin(dot(vd.screenPos.xy, float2(12.9898, 78.233))+_Time.w)* 43758.5453);
		half4 PoissonBlurRotationAnimated = half4( SSSBlurRot(half2(1,0),PoissonBlurRandRotationAnimated), SSSBlurRot(half2(0,1),PoissonBlurRandRotationAnimated));
		#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH)
			float4 shadowCoord = vtp._ShadowCoord;
		#endif
		#if defined (SHADOWS_CUBE)
			float3 shadowCoord = vtp._ShadowCoord;
		#endif
		
		[unroll]
		for(float i = 0; i<sampleCount; i+=1){
			vtp._ShadowCoord = shadowCoord;
			float2 tempblah = (asd[i])*(1.0-(asdL[i]+blerg));
			#if defined (SHADOWS_SCREEN)
				float3 u = normalize(unity_WorldToShadow[0][0].xyz);
				float3 l = normalize(unity_WorldToShadow[0][1].xyz);
				vtp._ShadowCoord = ComputeScreenPos(mul (UNITY_MATRIX_VP,float4(vd.worldPos+(u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg,1)));
			#endif
			#if defined (SHADOWS_DEPTH)
				float3 u = normalize(cross(float3(1,0,0),lightDir));
				float3 l = cross(u,lightDir);
				vtp._ShadowCoord = mul (unity_WorldToShadow[0],float4(vd.worldPos+(u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg,1));
			#endif
			#if defined (SHADOWS_CUBE)
				float3 u = normalize(cross(float3(1,0,0),lightDir));
				float3 l = cross(u,lightDir);
				vtp._ShadowCoord += (u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg;
			#endif
			
			colShadow += SHADOW_ATTENUATION(vtp);
		}
		colShadow*=weight;
		return colShadow;
	}

#endif
//OutputPremultiplied: True
//UseAlphaGenerate: True
half3 Tangent_Normals ( VertexData vd){
	half3 Surface = half3(0,0,1);
		//Generate layers for the Normals channel.
			//Generate Layer: Normal Map
				//Sample parts of the layer:
					half4 Normal_MapNormals_Sample1 = tex2D(_BumpMap,vd.uv_BumpMap);
	
				//Apply Effects:
					Normal_MapNormals_Sample1 = float4(UnpackNormal(Normal_MapNormals_Sample1),Normal_MapNormals_Sample1.a);
					Normal_MapNormals_Sample1.a = 1;
	
	Surface = lerp(Surface,Normal_MapNormals_Sample1.rgb,Normal_MapNormals_Sample1.a * _Normal_Height);//1
	
	
	return normalize(half3(dot(vd.TtoWSpaceX.xyz, Surface),dot(vd.TtoWSpaceY.xyz, Surface),dot(vd.TtoWSpaceZ.xyz, Surface)));
	
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Sub_Surface_Scattering ( VertexData vd, VertexToPixel vtp, UnityGI gi, UnityGIInput giInput){
	half4 Surface = half4(0.8,0.8,0.8,1);
		//Generate layers for the SSS Color channel.
			//Generate Layer: SSS Color 2
				//Sample parts of the layer:
					half4 SSS_Color_2SSS_Color_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(SSS_Color_2SSS_Color_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: SSS Color
				//Sample parts of the layer:
					half4 SSS_ColorSSS_Color_Sample1 = _Color;
	
	Surface = half4(SSS_ColorSSS_Color_Sample1.rgb,1) ;//0
	
	
	float3 fLT = 0;
	
	
	float3 MaxScale = _SSS_Color * vd.Mask0;
	
	float Quality = 5;
	float weight = 1.0/(Quality+1);
	float iters = 1.0/Quality;
	
	#ifndef USING_DIRECTIONAL_LIGHT
		float dist = max(1,length(UnityWorldSpaceLightDir(vd.worldPos)));
		float3 BackOffset = vd.worldNormal*dot(MaxScale,float3(0.33333,0.33333,0.33333))*dist;	//Red
		float3 Offset = vd.worldNormal*MaxScale.r*dist;
		float3 ldinnerR = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterR = UnityWorldSpaceLightDir(vd.worldPos-Offset);
		//Green
		Offset = vd.worldNormal*MaxScale.g*dist;
		float3 ldinnerG = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterG = UnityWorldSpaceLightDir(vd.worldPos-Offset);
		//Blue
		Offset = vd.worldNormal*MaxScale.b*dist;
		float3 ldinnerB = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterB = UnityWorldSpaceLightDir(vd.worldPos-Offset);
	#else
		float3 BackOffset = vd.worldNormal*dot(MaxScale,float3(0.33333,0.33333,0.33333));	//Red
		float3 Offset = vd.worldNormal*MaxScale.r;
		float3 ldinnerR = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterR = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
		//Green
		Offset = vd.worldNormal*MaxScale.g;
		float3 ldinnerG = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterG = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
		//Blue
		Offset = vd.worldNormal*MaxScale.b;
		float3 ldinnerB = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterB = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
	#endif
	
	weight = 0;
	[unroll]
	for(float i = 0;i<=1;i+=iters){
		float w=1-abs(i*2-1);
		float3 a = 0;
		float3 lightDir = normalize(lerp(ldinnerR,ldouterR,i));
		a.r = (dot(vd.worldNormal,lightDir))*w;
		lightDir = normalize(lerp(ldinnerG,ldouterG,i));
		a.g = (dot(vd.worldNormal,lightDir))*w;
		lightDir = normalize(lerp(ldinnerB,ldouterB,i));
		a.b = (dot(vd.worldNormal,lightDir))*w;
		a = saturate(a);
		fLT.rgb += a;
		weight+=w;
	}
	fLT*=1.0/weight;
	float3 scatteredShadow = giInput.atten;
	#ifndef SHADOWS_SCREEN
		float4 backup = _LightShadowData;//This is fun XD
		_LightShadowData = 1;
		UNITY_LIGHT_ATTENUATION(atten, vtp, vd.worldPos)
		_LightShadowData = backup;
		scatteredShadow = atten;
	#else
		scatteredShadow = 1;
	#endif
	#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH) || defined (SHADOWS_CUBE)
		MaxScale = _SSS_Color * _SSS_Scale;
		
		scatteredShadow.r *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.r);
		scatteredShadow.g *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.g);
		scatteredShadow.b *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.b);
	#endif
	
	fLT.rgb *= gi.light.color * scatteredShadow;
	fLT.rgb *= Surface.rgb;
	Unity_GlossyEnvironmentData g;
	g.roughness = 1;
	g.reflUVW = vd.worldViewDir;
	gi = UnityGlobalIllumination(giInput, 1, vd.worldNormal,g);
	fLT += gi.indirect.diffuse*Surface.rgb;
	return float4(fLT,Surface.a);
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Specular ( VertexData vd, UnityGI gi, UnityGIInput giInput, inout half4 previousBaseColor){
	half Metalness = 0;//Metallic Mode
	half oneMinusRoughness = _Shininess;
	half perceptualRoughness = 1-oneMinusRoughness;
	half realRoughness = perceptualRoughness*perceptualRoughness;		// need to square perceptual roughness
	#if SSUNITY_BRDF_PBS==1||SSUNITY_BRDF_PBS==2
	half reflectivity = lerp (0.034-perceptualRoughness*0.01836, 1, Metalness);
	#else
	half reflectivity = lerp (0.02482, 1, Metalness);
	#endif
	half oneMinusReflectivity = 1-reflectivity;
	Unity_GlossyEnvironmentData g;
	g.roughness = (1-_Shininess);
	g.reflUVW = reflect(-vd.worldViewDir, vd.worldNormal);
	gi = UnityGlobalIllumination(giInput, 1, vd.worldNormal,g);
	half3 halfDir = normalize (gi.light.dir + vd.worldViewDir);
	//#if UNITY_BRDF_GGX 
	//	half shiftAmount = dot(vd.worldNormal, vd.worldViewDir);
	//	vd.worldNormal = shiftAmount < 0.0f ? vd.worldNormal + vd.worldViewDir * (-shiftAmount + 1e-5f) : vd.worldNormal;
	//#endif
	half nh = saturate(dot(vd.worldNormal, halfDir));
	half nl = saturate(dot(vd.worldNormal, gi.light.dir));
	half nv = abs(dot(vd.worldNormal, vd.worldViewDir));
	half lh = saturate(dot(gi.light.dir, halfDir));
	
	#if SSUNITY_BRDF_PBS==1
	half nvPow5 = Pow5 (1-nv);
	#elif SSUNITY_BRDF_PBS==2||SSUNITY_BRDF_PBS==3
	half nvPow5 = Pow4 (1-nv);
	#endif
	
	half3 Lighting;
	#if SSUNITY_BRDF_PBS==1
	half3 Surface = previousBaseColor*reflectivity;
	gi.indirect.specular *= 1 - perceptualRoughness*(nv*0.2+0.4);
	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)
	half surfaceReduction;
	if (IsGammaSpace()) surfaceReduction = 1.0 - 0.28*realRoughness*perceptualRoughness;		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	else surfaceReduction = 1.0 / (realRoughness*realRoughness + 1.0);			// fade in [0.5;1]
	half whyDoIBotherWithStandardSupport = realRoughness;
	#if UNITY_VERSION<550
		whyDoIBotherWithStandardSupport = perceptualRoughness;
	#endif
	#if UNITY_BRDF_GGX
		half V = SmithJointGGXVisibilityTerm (nl, nv, whyDoIBotherWithStandardSupport);
		half D = GGXTermNoFadeout (nh, realRoughness);
	#else
		half V = SmithBeckmannVisibilityTerm (nl, nv, whyDoIBotherWithStandardSupport);
		half D = NDFBlinnPhongNormalizedTerm (nh, RoughnessToSpecPower (perceptualRoughness));
	#endif
	
	// HACK: theoretically we should divide by Pi diffuseTerm and not multiply specularTerm!
	// BUT 1) that will make shader look significantly darker than Legacy ones
	// and 2) on engine side Non-important lights have to be divided by Pi to in cases when they are injected into ambient SH
	// NOTE: multiplication by Pi is part of single constant together with 1/4 now
	#if UNITY_VERSION>=550//Unity changed the value of PI...:(
		half specularTerm = (V * D) * (UNITY_PI); // Torrance-Sparrow model, Fresnel is applied later (for optimization reasons)
	#else
		half specularTerm = (V * D) * (UNITY_PI/4); // Torrance-Sparrow model, Fresnel is applied later (for optimization reasons)
	#endif
	if (IsGammaSpace())
		specularTerm = sqrt(max(1e-4h, specularTerm));
	specularTerm = max(0, specularTerm * nl);
	
	
	Lighting =	specularTerm;
	#elif SSUNITY_BRDF_PBS==2
	half3 Surface = previousBaseColor*reflectivity;
	gi.indirect.specular *= 1 - perceptualRoughness*(nv*0.2+0.4);
	#if UNITY_BRDF_GGX
	
		// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
		// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
		// https://community.arm.com/events/1155
		half a = realRoughness;
		half a2 = a*a;
	
		half d = nh * nh * (a2 - 1.h) + 1.00001h;
	#ifdef UNITY_COLORSPACE_GAMMA
		// Tighter approximation for Gamma only rendering mode!
		// DVF = sqrt(DVF);
		// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(realRoughness + .5) * d);
		half specularTerm = a / (max(0.32h, lh) * (1.5h + realRoughness) * d);
	#else
		half specularTerm = a2 / (max(0.1h, lh*lh) * (realRoughness + 0.5h) * (d * d) * 4);
	#endif
	
		// on mobiles (where half actually means something) denominator have risk of overflow
		// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
		// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
	#if defined (SHADER_API_MOBILE)
		specularTerm = specularTerm - 1e-4h;
	#endif
	
	#else
	
		// Legacy
		half specularPower = RoughnessToSpecPower(perceptualRoughness);
		// Modified with approximate Visibility function that takes roughness into account
		// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
		// and produced extremely bright specular at grazing angles
	
		half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
		half invF = lh;
	
		half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);
	
	#ifdef UNITY_COLORSPACE_GAMMA
		specularTerm = sqrt(max(1e-4h, specularTerm));
	#endif
	
	#endif
	
	#if defined (SHADER_API_MOBILE)
		specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
	#endif
	#if defined(_SPECULARHIGHLIGHTS_OFF)
		specularTerm = 0.0;
	#endif
	
		// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)
	
		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
		// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
	#ifdef UNITY_COLORSPACE_GAMMA
		half surfaceReduction = 0.28;
	#else
		half surfaceReduction = (0.6-0.08*perceptualRoughness);
	#endif
		surfaceReduction = 1.0 - realRoughness*perceptualRoughness*surfaceReduction;
	
	Lighting =	specularTerm;
	#else
	half3 Surface = previousBaseColor*reflectivity;
	half surfaceReduction = 1;
	half2 rlPow4AndFresnelTerm = Pow4 (half2(dot(vd.worldRefl, gi.light.dir), 1-nv));
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
	half fresnelTerm = rlPow4AndFresnelTerm.y;
	
	
	Lighting =	BRDF3_Direct(0,1,rlPow4,oneMinusRoughness)*nl;
	#endif
	Lighting *= gi.light.color;
	#if SSUNITY_BRDF_PBS==1
	Lighting =	(Lighting + gi.indirect.specular) * lerp(Surface,1,nvPow5);
	#elif SSUNITY_BRDF_PBS==2
	Lighting =	(Lighting * nl + gi.indirect.specular) * lerp(Surface,1,nvPow5);
	#else
	Lighting = (Lighting+gi.indirect.specular) * lerp (Surface.rgb, 1, fresnelTerm);
	#endif
	return half4(Lighting.rgb,lerp(nvPow5,1,reflectivity));
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Scale channel.
			//Generate Layer: SSS Scale
				//Sample parts of the layer:
					half4 SSS_ScaleMask1_Sample1 = _SSS_Scale;
	
	Mask0 = SSS_ScaleMask1_Sample1.r;//2
	
	
			//Generate Layer: SSS Scale2
				//Sample parts of the layer:
					half4 SSS_Scale2Mask1_Sample1 = length(fwidth(vd.worldNormal)) / max(length(fwidth(vd.worldPos) * 1),0.0001);
	
				//Apply Effects:
					SSS_Scale2Mask1_Sample1.rgb = clamp(SSS_Scale2Mask1_Sample1.rgb,_Scale_GLMin,_Scale_GLMax);
	
	Mask0 = (Mask0 * SSS_Scale2Mask1_Sample1.r);//0
	
	
	return Mask0;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.worldTangent = UnityObjectToWorldNormalNew(v.tangent);
	vd.worldBitangent = cross(vd.worldNormal, vd.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
	vd.TtoWSpaceX = float4(vd.worldTangent.x, vd.worldBitangent.x, vd.worldNormal.x, vd.worldPos.x);
	vd.TtoWSpaceY = float4(vd.worldTangent.y, vd.worldBitangent.y, vd.worldNormal.y, vd.worldPos.y);
	vd.TtoWSpaceZ = float4(vd.worldTangent.z, vd.worldBitangent.z, vd.worldNormal.z, vd.worldPos.z);
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	vd.uv_BumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
	#if UNITY_SHOULD_SAMPLE_SH
	vd.sh = 0;
// SH/ambient and vertex lights
#ifdef LIGHTMAP_OFF
	vd.sh = 0;
	// Approximated illumination from non-important point lights
	#ifdef VERTEXLIGHT_ON
		vd.sh += Shade4PointLights (
		unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
		unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
		unity_4LightAtten0, vd.worldPos, vd.worldNormal);
	#endif
	vd.sh = ShadeSHPerVertex (vd.worldNormal, vd.sh);
#endif // LIGHTMAP_OFF
;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
	vd.lmap = 0;
#ifndef DYNAMICLIGHTMAP_OFF
	vd.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
#ifndef LIGHTMAP_OFF
	vd.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
;
	#endif
	
	
vd.Mask0 = Mask_Mask0 ( vd);
	
	
	vtp.position = vd.position;
	vtp.screenPos = vd.screenPos;
	vtp.worldViewDir = vd.worldViewDir;
	vtp.TtoWSpaceX = vd.TtoWSpaceX;
	vtp.TtoWSpaceY = vd.TtoWSpaceY;
	vtp.TtoWSpaceZ = vd.TtoWSpaceZ;
	vtp.uv_MainTex = vd.uv_MainTex;
	vtp.uv_BumpMap = vd.uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
	vtp.sh = vd.sh;
#endif
	#define pos position
	TRANSFER_SHADOW(vtp);
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
	vtp.lmap = vd.lmap;
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
				vd.worldPos = half3(vtp.TtoWSpaceX.w,vtp.TtoWSpaceY.w,vtp.TtoWSpaceZ.w);
				vd.worldNormal = half3(vtp.TtoWSpaceX.z,vtp.TtoWSpaceY.z,vtp.TtoWSpaceZ.z);
				vd.worldTangent = half3(vtp.TtoWSpaceX.x,vtp.TtoWSpaceY.x,vtp.TtoWSpaceZ.x);
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				vd.worldRefl = reflect(-vd.worldViewDir, vd.worldNormal);
				vd.TtoWSpaceX = vtp.TtoWSpaceX;
				vd.TtoWSpaceY = vtp.TtoWSpaceY;
				vd.TtoWSpaceZ = vtp.TtoWSpaceZ;
				vd.uv_MainTex = vtp.uv_MainTex;
				vd.uv_BumpMap = vtp.uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
				vd.sh = vtp.sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
				vd.lmap = vtp.lmap;
	#endif
				half4 previousBaseColor = 0;//Honestly just a quick hack to get Metal specular working XD
				outputNormal = vd.worldNormal;
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI,gi);
// Setup lighting environment
				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(vd.worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				//Uses SHADOW_COORDS
				UNITY_LIGHT_ATTENUATION(atten, vtp, vd.worldPos)
				vd.Atten = atten;
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				#if !defined(LIGHTMAP_ON)
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;
					gi.light.ndotl = LambertTerm (vd.worldNormal, gi.light.dir);
				#endif
				// Call GI (lightmaps/SH/reflections) lighting function
				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = vd.worldPos;
				giInput.worldViewDir = vd.worldViewDir;
				giInput.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = vd.lmap;
				#else
					giInput.lightmapUV = 0.0;
				#endif
				#if UNITY_SHOULD_SAMPLE_SH
					giInput.ambient = vd.sh;
				#else
					giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
				#endif
				#if UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif
vd.Mask0 = Mask_Mask0 ( vd);
				half3 outputTangent_Normals = Tangent_Normals ( vd);
				outputNormal = outputTangent_Normals.rgb;//0
								vd.worldNormal = outputNormal;
				vd.worldRefl = reflect(-vd.worldViewDir, vd.worldNormal);
				half4 outputSub_Surface_Scattering = Sub_Surface_Scattering ( vd, vtp, gi, giInput);
				outputColor = half4(outputSub_Surface_Scattering.rgb,1);//7
								half4 outputSpecular = Specular ( vd, gi, giInput, previousBaseColor);
				outputColor = ((outputColor) * (1 - (outputSpecular.a)) + (half4(outputSpecular.rgb, outputSpecular.a)));//1
								UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				return outputColor;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardAdd" }
	Fog { Color (0,0,0,0) }
	ZTest LEqual
	ZWrite On
	Blend One One
	Cull Back//Culling specifies which sides of the models faces to hide.

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma target 3.0
				#pragma multi_compile_fog
				#pragma multi_compile __ UNITY_COLORSPACE_GAMMA
				#pragma multi_compile_fwdadd_fullshadows
				#include "HLSLSupport.cginc"
				#include "UnityShaderVariables.cginc"
				#define UNITY_PASS_FORWARDADD
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
				float4 _Color;
				sampler2D _BumpMap;
float4 _BumpMap_ST;
float4 _BumpMap_HDR;
				float _Normal_Height;
				float _Shininess;
				float _SSS_Scale;
				float4 _SSS_Color;
				float _SSS_Fringing;
				float _Scale_GLMin;
				float _Scale_GLMax;

#if !defined (SSUNITY_BRDF_PBS) // allow to explicitly override BRDF in custom shader
	// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
	#if SHADER_TARGET < 30
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF3)
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF2)
		#define SSUNITY_BRDF_PBS 2
	#elif defined(UNITY_PBS_USE_BRDF1)
		#define SSUNITY_BRDF_PBS 1
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define SSUNITY_BRDF_PBS 1
	#else
		#error something broke in auto-choosing BRDF (Shader Sandwich)
	#endif
#endif

inline half GGXTermNoFadeout (half NdotH, half realRoughness){
	half a2 = realRoughness * realRoughness;
	half d = (NdotH * a2 - NdotH) * NdotH + 1.0f; // 2 mad
	return a2 / (UNITY_PI * d * d);
}

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
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};
struct VertexToPixel{
	float4 position : POSITION;
	float3 screenPos : TEXCOORD0;
	float3 worldViewDir : TEXCOORD1;
	float4 TtoWSpaceX : TEXCOORD2;
	float4 TtoWSpaceY : TEXCOORD3;
	float4 TtoWSpaceZ : TEXCOORD4;
	float2 uv_MainTex : TEXCOORD5;
	float2 uv_BumpMap : TEXCOORD6;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh : TEXCOORD7;
#endif
	#define pos position
		SHADOW_COORDS(8)
		UNITY_FOG_COORDS(9)
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap : TEXCOORD10;
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldTangent;
	float3 worldBitangent;
	float3 screenPos;
	float3 worldViewDir;
	float3 worldRefl;
	float4 TtoWSpaceX;
	float4 TtoWSpaceY;
	float4 TtoWSpaceZ;
	float2 uv_MainTex;
	float2 uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap;
	#endif
	float Mask0;
	float Atten;
};
half2 SSSBlurRot( half2 d, float r ) {
	half2 sc = half2(sin(r),cos(r));
	return half2( dot( d, half2(sc.y, -sc.x) ), dot( d, sc.xy ) );
}

#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH) || defined (SHADOWS_CUBE)
	float ComputeScatteredShadow_Sub_Surface_Scattering(VertexData vd,VertexToPixel vtp, float3 lightDir, float blerg){
		float colShadow = 0;
		float3 bitangent = cross(vd.worldTangent,vd.worldNormal);
		float weight = 0;
		
		float sampleCount = 5;
		static float2 asd[5] = {
			float2(-0.7957063,0.3076356),
			float2(0.09538598,0.8763882),
			float2(0.229684,-0.6201293),
			float2(-0.7097354,-0.4950111),
			float2(0.3737206,0.1264346),
		};
		static float asdL[5] = {
			1.172189,
			1.134348,
			1.512177,
			1.155656,
			2.534671,
		};
		weight = 0.2;
		half PoissonBlurRandRotationAnimated = 6.28*frac(sin(dot(vd.screenPos.xy, float2(12.9898, 78.233))+_Time.w)* 43758.5453);
		half4 PoissonBlurRotationAnimated = half4( SSSBlurRot(half2(1,0),PoissonBlurRandRotationAnimated), SSSBlurRot(half2(0,1),PoissonBlurRandRotationAnimated));
		#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH)
			float4 shadowCoord = vtp._ShadowCoord;
		#endif
		#if defined (SHADOWS_CUBE)
			float3 shadowCoord = vtp._ShadowCoord;
		#endif
		
		[unroll]
		for(float i = 0; i<sampleCount; i+=1){
			vtp._ShadowCoord = shadowCoord;
			float2 tempblah = (asd[i])*(1.0-(asdL[i]+blerg));
			#if defined (SHADOWS_SCREEN)
				float3 u = normalize(unity_WorldToShadow[0][0].xyz);
				float3 l = normalize(unity_WorldToShadow[0][1].xyz);
				vtp._ShadowCoord = ComputeScreenPos(mul (UNITY_MATRIX_VP,float4(vd.worldPos+(u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg,1)));
			#endif
			#if defined (SHADOWS_DEPTH)
				float3 u = normalize(cross(float3(1,0,0),lightDir));
				float3 l = cross(u,lightDir);
				vtp._ShadowCoord = mul (unity_WorldToShadow[0],float4(vd.worldPos+(u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg,1));
			#endif
			#if defined (SHADOWS_CUBE)
				float3 u = normalize(cross(float3(1,0,0),lightDir));
				float3 l = cross(u,lightDir);
				vtp._ShadowCoord += (u*dot(tempblah,PoissonBlurRotationAnimated.xz)+l*dot(tempblah,PoissonBlurRotationAnimated.yw))*blerg;
			#endif
			
			colShadow += SHADOW_ATTENUATION(vtp);
		}
		colShadow*=weight;
		return colShadow;
	}

#endif
//OutputPremultiplied: True
//UseAlphaGenerate: True
half3 Tangent_Normals ( VertexData vd){
	half3 Surface = half3(0,0,1);
		//Generate layers for the Normals channel.
			//Generate Layer: Normal Map
				//Sample parts of the layer:
					half4 Normal_MapNormals_Sample1 = tex2D(_BumpMap,vd.uv_BumpMap);
	
				//Apply Effects:
					Normal_MapNormals_Sample1 = float4(UnpackNormal(Normal_MapNormals_Sample1),Normal_MapNormals_Sample1.a);
					Normal_MapNormals_Sample1.a = 1;
	
	Surface = lerp(Surface,Normal_MapNormals_Sample1.rgb,Normal_MapNormals_Sample1.a * _Normal_Height);//1
	
	
	return normalize(half3(dot(vd.TtoWSpaceX.xyz, Surface),dot(vd.TtoWSpaceY.xyz, Surface),dot(vd.TtoWSpaceZ.xyz, Surface)));
	
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Sub_Surface_Scattering ( VertexData vd, VertexToPixel vtp, UnityGI gi, UnityGIInput giInput){
	half4 Surface = half4(0.8,0.8,0.8,1);
		//Generate layers for the SSS Color channel.
			//Generate Layer: SSS Color 2
				//Sample parts of the layer:
					half4 SSS_Color_2SSS_Color_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(SSS_Color_2SSS_Color_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: SSS Color
				//Sample parts of the layer:
					half4 SSS_ColorSSS_Color_Sample1 = _Color;
	
	Surface = half4(SSS_ColorSSS_Color_Sample1.rgb,1) ;//0
	
	
	float3 fLT = 0;
	
	
	float3 MaxScale = _SSS_Color * vd.Mask0;
	
	float Quality = 5;
	float weight = 1.0/(Quality+1);
	float iters = 1.0/Quality;
	
	#ifndef USING_DIRECTIONAL_LIGHT
		float dist = max(1,length(UnityWorldSpaceLightDir(vd.worldPos)));
		float3 BackOffset = vd.worldNormal*dot(MaxScale,float3(0.33333,0.33333,0.33333))*dist;	//Red
		float3 Offset = vd.worldNormal*MaxScale.r*dist;
		float3 ldinnerR = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterR = UnityWorldSpaceLightDir(vd.worldPos-Offset);
		//Green
		Offset = vd.worldNormal*MaxScale.g*dist;
		float3 ldinnerG = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterG = UnityWorldSpaceLightDir(vd.worldPos-Offset);
		//Blue
		Offset = vd.worldNormal*MaxScale.b*dist;
		float3 ldinnerB = UnityWorldSpaceLightDir(vd.worldPos+lerp(BackOffset,Offset,_SSS_Fringing));
		float3 ldouterB = UnityWorldSpaceLightDir(vd.worldPos-Offset);
	#else
		float3 BackOffset = vd.worldNormal*dot(MaxScale,float3(0.33333,0.33333,0.33333));	//Red
		float3 Offset = vd.worldNormal*MaxScale.r;
		float3 ldinnerR = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterR = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
		//Green
		Offset = vd.worldNormal*MaxScale.g;
		float3 ldinnerG = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterG = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
		//Blue
		Offset = vd.worldNormal*MaxScale.b;
		float3 ldinnerB = UnityWorldSpaceLightDir(vd.worldPos)-lerp(BackOffset,Offset,_SSS_Fringing);
		float3 ldouterB = UnityWorldSpaceLightDir(vd.worldPos)+Offset;
	#endif
	
	weight = 0;
	[unroll]
	for(float i = 0;i<=1;i+=iters){
		float w=1-abs(i*2-1);
		float3 a = 0;
		float3 lightDir = normalize(lerp(ldinnerR,ldouterR,i));
		a.r = (dot(vd.worldNormal,lightDir))*w;
		lightDir = normalize(lerp(ldinnerG,ldouterG,i));
		a.g = (dot(vd.worldNormal,lightDir))*w;
		lightDir = normalize(lerp(ldinnerB,ldouterB,i));
		a.b = (dot(vd.worldNormal,lightDir))*w;
		a = saturate(a);
		fLT.rgb += a;
		weight+=w;
	}
	fLT*=1.0/weight;
	float3 scatteredShadow = giInput.atten;
	#ifndef SHADOWS_SCREEN
		float4 backup = _LightShadowData;//This is fun XD
		_LightShadowData = 1;
		UNITY_LIGHT_ATTENUATION(atten, vtp, vd.worldPos)
		_LightShadowData = backup;
		scatteredShadow = atten;
	#else
		scatteredShadow = 1;
	#endif
	#if defined (SHADOWS_SCREEN) || defined (SHADOWS_DEPTH) || defined (SHADOWS_CUBE)
		MaxScale = _SSS_Color * _SSS_Scale;
		
		scatteredShadow.r *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.r);
		scatteredShadow.g *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.g);
		scatteredShadow.b *= ComputeScatteredShadow_Sub_Surface_Scattering(vd, vtp, gi.light.dir, MaxScale.b);
	#endif
	
	fLT.rgb *= gi.light.color * scatteredShadow;
	fLT.rgb *= Surface.rgb;
	return float4(fLT,Surface.a);
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Specular ( VertexData vd, UnityGI gi, UnityGIInput giInput, inout half4 previousBaseColor){
	half Metalness = 0;//Metallic Mode
	half oneMinusRoughness = _Shininess;
	half perceptualRoughness = 1-oneMinusRoughness;
	half realRoughness = perceptualRoughness*perceptualRoughness;		// need to square perceptual roughness
	#if SSUNITY_BRDF_PBS==1||SSUNITY_BRDF_PBS==2
	half reflectivity = lerp (0.034-perceptualRoughness*0.01836, 1, Metalness);
	#else
	half reflectivity = lerp (0.02482, 1, Metalness);
	#endif
	half oneMinusReflectivity = 1-reflectivity;
	UnityGI o_gi;
	ResetUnityGI(o_gi);
	o_gi.light = giInput.light;
	o_gi.light.color *= giInput.atten;
	gi = o_gi;
	half3 halfDir = normalize (gi.light.dir + vd.worldViewDir);
	//#if UNITY_BRDF_GGX 
	//	half shiftAmount = dot(vd.worldNormal, vd.worldViewDir);
	//	vd.worldNormal = shiftAmount < 0.0f ? vd.worldNormal + vd.worldViewDir * (-shiftAmount + 1e-5f) : vd.worldNormal;
	//#endif
	half nh = saturate(dot(vd.worldNormal, halfDir));
	half nl = saturate(dot(vd.worldNormal, gi.light.dir));
	half nv = abs(dot(vd.worldNormal, vd.worldViewDir));
	half lh = saturate(dot(gi.light.dir, halfDir));
	
	#if SSUNITY_BRDF_PBS==1
	half nvPow5 = Pow5 (1-nv);
	#elif SSUNITY_BRDF_PBS==2||SSUNITY_BRDF_PBS==3
	half nvPow5 = Pow4 (1-nv);
	#endif
	
	half3 Lighting;
	#if SSUNITY_BRDF_PBS==1
	half3 Surface = previousBaseColor*reflectivity;
	gi.indirect.specular *= 1 - perceptualRoughness*(nv*0.2+0.4);
	// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)
	half surfaceReduction;
	if (IsGammaSpace()) surfaceReduction = 1.0 - 0.28*realRoughness*perceptualRoughness;		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
	else surfaceReduction = 1.0 / (realRoughness*realRoughness + 1.0);			// fade in [0.5;1]
	half whyDoIBotherWithStandardSupport = realRoughness;
	#if UNITY_VERSION<550
		whyDoIBotherWithStandardSupport = perceptualRoughness;
	#endif
	#if UNITY_BRDF_GGX
		half V = SmithJointGGXVisibilityTerm (nl, nv, whyDoIBotherWithStandardSupport);
		half D = GGXTermNoFadeout (nh, realRoughness);
	#else
		half V = SmithBeckmannVisibilityTerm (nl, nv, whyDoIBotherWithStandardSupport);
		half D = NDFBlinnPhongNormalizedTerm (nh, RoughnessToSpecPower (perceptualRoughness));
	#endif
	
	// HACK: theoretically we should divide by Pi diffuseTerm and not multiply specularTerm!
	// BUT 1) that will make shader look significantly darker than Legacy ones
	// and 2) on engine side Non-important lights have to be divided by Pi to in cases when they are injected into ambient SH
	// NOTE: multiplication by Pi is part of single constant together with 1/4 now
	#if UNITY_VERSION>=550//Unity changed the value of PI...:(
		half specularTerm = (V * D) * (UNITY_PI); // Torrance-Sparrow model, Fresnel is applied later (for optimization reasons)
	#else
		half specularTerm = (V * D) * (UNITY_PI/4); // Torrance-Sparrow model, Fresnel is applied later (for optimization reasons)
	#endif
	if (IsGammaSpace())
		specularTerm = sqrt(max(1e-4h, specularTerm));
	specularTerm = max(0, specularTerm * nl);
	
	
	Lighting =	specularTerm;
	#elif SSUNITY_BRDF_PBS==2
	half3 Surface = previousBaseColor*reflectivity;
	gi.indirect.specular *= 1 - perceptualRoughness*(nv*0.2+0.4);
	#if UNITY_BRDF_GGX
	
		// GGX Distribution multiplied by combined approximation of Visibility and Fresnel
		// See "Optimizing PBR for Mobile" from Siggraph 2015 moving mobile graphics course
		// https://community.arm.com/events/1155
		half a = realRoughness;
		half a2 = a*a;
	
		half d = nh * nh * (a2 - 1.h) + 1.00001h;
	#ifdef UNITY_COLORSPACE_GAMMA
		// Tighter approximation for Gamma only rendering mode!
		// DVF = sqrt(DVF);
		// DVF = (a * sqrt(.25)) / (max(sqrt(0.1), lh)*sqrt(realRoughness + .5) * d);
		half specularTerm = a / (max(0.32h, lh) * (1.5h + realRoughness) * d);
	#else
		half specularTerm = a2 / (max(0.1h, lh*lh) * (realRoughness + 0.5h) * (d * d) * 4);
	#endif
	
		// on mobiles (where half actually means something) denominator have risk of overflow
		// clamp below was added specifically to "fix" that, but dx compiler (we convert bytecode to metal/gles)
		// sees that specularTerm have only non-negative terms, so it skips max(0,..) in clamp (leaving only min(100,...))
	#if defined (SHADER_API_MOBILE)
		specularTerm = specularTerm - 1e-4h;
	#endif
	
	#else
	
		// Legacy
		half specularPower = RoughnessToSpecPower(perceptualRoughness);
		// Modified with approximate Visibility function that takes roughness into account
		// Original ((n+1)*N.H^n) / (8*Pi * L.H^3) didn't take into account roughness
		// and produced extremely bright specular at grazing angles
	
		half invV = lh * lh * smoothness + perceptualRoughness * perceptualRoughness; // approx ModifiedKelemenVisibilityTerm(lh, perceptualRoughness);
		half invF = lh;
	
		half specularTerm = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);
	
	#ifdef UNITY_COLORSPACE_GAMMA
		specularTerm = sqrt(max(1e-4h, specularTerm));
	#endif
	
	#endif
	
	#if defined (SHADER_API_MOBILE)
		specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
	#endif
	#if defined(_SPECULARHIGHLIGHTS_OFF)
		specularTerm = 0.0;
	#endif
	
		// surfaceReduction = Int D(NdotH) * NdotH * Id(NdotL>0) dH = 1/(realRoughness^2+1)
	
		// 1-0.28*x^3 as approximation for (1/(x^4+1))^(1/2.2) on the domain [0;1]
		// 1-x^3*(0.6-0.08*x)   approximation for 1/(x^4+1)
	#ifdef UNITY_COLORSPACE_GAMMA
		half surfaceReduction = 0.28;
	#else
		half surfaceReduction = (0.6-0.08*perceptualRoughness);
	#endif
		surfaceReduction = 1.0 - realRoughness*perceptualRoughness*surfaceReduction;
	
	Lighting =	specularTerm;
	#else
	half3 Surface = previousBaseColor*reflectivity;
	half surfaceReduction = 1;
	half2 rlPow4AndFresnelTerm = Pow4 (half2(dot(vd.worldRefl, gi.light.dir), 1-nv));
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
	half fresnelTerm = rlPow4AndFresnelTerm.y;
	
	
	Lighting =	BRDF3_Direct(0,1,rlPow4,oneMinusRoughness)*nl;
	#endif
	Lighting *= gi.light.color;
	#if SSUNITY_BRDF_PBS==1
	Lighting =	(Lighting) * lerp(1,Surface,(1-nvPow5));
	#elif SSUNITY_BRDF_PBS==2
	Lighting =	(Lighting * nl) * lerp(1,Surface,(1-nvPow5));
	#elif SSUNITY_BRDF_PBS==3
	Lighting =	Lighting * Surface;
	#endif
	return half4(Lighting.rgb,lerp(nvPow5,1,reflectivity));
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Scale channel.
			//Generate Layer: SSS Scale
				//Sample parts of the layer:
					half4 SSS_ScaleMask1_Sample1 = _SSS_Scale;
	
	Mask0 = SSS_ScaleMask1_Sample1.r;//2
	
	
			//Generate Layer: SSS Scale2
				//Sample parts of the layer:
					half4 SSS_Scale2Mask1_Sample1 = length(fwidth(vd.worldNormal)) / max(length(fwidth(vd.worldPos) * 1),0.0001);
	
				//Apply Effects:
					SSS_Scale2Mask1_Sample1.rgb = clamp(SSS_Scale2Mask1_Sample1.rgb,_Scale_GLMin,_Scale_GLMax);
	
	Mask0 = (Mask0 * SSS_Scale2Mask1_Sample1.r);//0
	
	
	return Mask0;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.worldTangent = UnityObjectToWorldNormalNew(v.tangent);
	vd.worldBitangent = cross(vd.worldNormal, vd.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
	vd.TtoWSpaceX = float4(vd.worldTangent.x, vd.worldBitangent.x, vd.worldNormal.x, vd.worldPos.x);
	vd.TtoWSpaceY = float4(vd.worldTangent.y, vd.worldBitangent.y, vd.worldNormal.y, vd.worldPos.y);
	vd.TtoWSpaceZ = float4(vd.worldTangent.z, vd.worldBitangent.z, vd.worldNormal.z, vd.worldPos.z);
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	vd.uv_BumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
	#if UNITY_SHOULD_SAMPLE_SH
	vd.sh = 0;
// SH/ambient and vertex lights
#ifdef LIGHTMAP_OFF
	vd.sh = 0;
	// Approximated illumination from non-important point lights
	#ifdef VERTEXLIGHT_ON
		vd.sh += Shade4PointLights (
		unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
		unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
		unity_4LightAtten0, vd.worldPos, vd.worldNormal);
	#endif
	vd.sh = ShadeSHPerVertex (vd.worldNormal, vd.sh);
#endif // LIGHTMAP_OFF
;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
	vd.lmap = 0;
#ifndef DYNAMICLIGHTMAP_OFF
	vd.lmap.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
#endif
#ifndef LIGHTMAP_OFF
	vd.lmap.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif
;
	#endif
	
	
vd.Mask0 = Mask_Mask0 ( vd);
	
	
	vtp.position = vd.position;
	vtp.screenPos = vd.screenPos;
	vtp.worldViewDir = vd.worldViewDir;
	vtp.TtoWSpaceX = vd.TtoWSpaceX;
	vtp.TtoWSpaceY = vd.TtoWSpaceY;
	vtp.TtoWSpaceZ = vd.TtoWSpaceZ;
	vtp.uv_MainTex = vd.uv_MainTex;
	vtp.uv_BumpMap = vd.uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
	vtp.sh = vd.sh;
#endif
	#define pos position
	TRANSFER_SHADOW(vtp);
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
	vtp.lmap = vd.lmap;
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
				vd.worldPos = half3(vtp.TtoWSpaceX.w,vtp.TtoWSpaceY.w,vtp.TtoWSpaceZ.w);
				vd.worldNormal = half3(vtp.TtoWSpaceX.z,vtp.TtoWSpaceY.z,vtp.TtoWSpaceZ.z);
				vd.worldTangent = half3(vtp.TtoWSpaceX.x,vtp.TtoWSpaceY.x,vtp.TtoWSpaceZ.x);
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				vd.worldRefl = reflect(-vd.worldViewDir, vd.worldNormal);
				vd.TtoWSpaceX = vtp.TtoWSpaceX;
				vd.TtoWSpaceY = vtp.TtoWSpaceY;
				vd.TtoWSpaceZ = vtp.TtoWSpaceZ;
				vd.uv_MainTex = vtp.uv_MainTex;
				vd.uv_BumpMap = vtp.uv_BumpMap;
	#if UNITY_SHOULD_SAMPLE_SH
				vd.sh = vtp.sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
				vd.lmap = vtp.lmap;
	#endif
				half4 previousBaseColor = 0;//Honestly just a quick hack to get Metal specular working XD
				outputNormal = vd.worldNormal;
				UnityGI gi;
				UNITY_INITIALIZE_OUTPUT(UnityGI,gi);
// Setup lighting environment
				#ifndef USING_DIRECTIONAL_LIGHT
					fixed3 lightDir = normalize(UnityWorldSpaceLightDir(vd.worldPos));
				#else
					fixed3 lightDir = _WorldSpaceLightPos0.xyz;
				#endif
				//Uses SHADOW_COORDS
				UNITY_LIGHT_ATTENUATION(atten, vtp, vd.worldPos)
				vd.Atten = atten;
				gi.indirect.diffuse = 0;
				gi.indirect.specular = 0;
				#if !defined(LIGHTMAP_ON)
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;
					gi.light.ndotl = LambertTerm (vd.worldNormal, gi.light.dir);
				#endif
				// Call GI (lightmaps/SH/reflections) lighting function
				UnityGIInput giInput;
				UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
				giInput.light = gi.light;
				giInput.worldPos = vd.worldPos;
				giInput.worldViewDir = vd.worldViewDir;
				giInput.atten = atten;
				#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
					giInput.lightmapUV = vd.lmap;
				#else
					giInput.lightmapUV = 0.0;
				#endif
				#if UNITY_SHOULD_SAMPLE_SH
					giInput.ambient = vd.sh;
				#else
					giInput.ambient.rgb = 0.0;
				#endif
				giInput.probeHDR[0] = unity_SpecCube0_HDR;
				giInput.probeHDR[1] = unity_SpecCube1_HDR;
				#if UNITY_SPECCUBE_BLENDING || UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMin[0] = unity_SpecCube0_BoxMin; // .w holds lerp value for blending
				#endif
				#if UNITY_SPECCUBE_BOX_PROJECTION
					giInput.boxMax[0] = unity_SpecCube0_BoxMax;
					giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
					giInput.boxMax[1] = unity_SpecCube1_BoxMax;
					giInput.boxMin[1] = unity_SpecCube1_BoxMin;
					giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
				#endif
vd.Mask0 = Mask_Mask0 ( vd);
				half3 outputTangent_Normals = Tangent_Normals ( vd);
				outputNormal = outputTangent_Normals.rgb;//0
								vd.worldNormal = outputNormal;
				vd.worldRefl = reflect(-vd.worldViewDir, vd.worldNormal);
				half4 outputSub_Surface_Scattering = Sub_Surface_Scattering ( vd, vtp, gi, giInput);
				outputColor = half4(outputSub_Surface_Scattering.rgb,1);//7
								half4 outputSpecular = Specular ( vd, gi, giInput, previousBaseColor);
				outputColor = ((outputColor) * (1 - (outputSpecular.a)) + (half4(outputSpecular.rgb, outputSpecular.a)));//1
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
				float4 _Color;
				sampler2D _BumpMap;
float4 _BumpMap_ST;
float4 _BumpMap_HDR;
				float _Normal_Height;
				float _Shininess;
				float _SSS_Scale;
				float4 _SSS_Color;
				float _SSS_Fringing;
				float _Scale_GLMin;
				float _Scale_GLMax;

#if !defined (SSUNITY_BRDF_PBS) // allow to explicitly override BRDF in custom shader
	// still add safe net for low shader models, otherwise we might end up with shaders failing to compile
	#if SHADER_TARGET < 30
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF3)
		#define SSUNITY_BRDF_PBS 3
	#elif defined(UNITY_PBS_USE_BRDF2)
		#define SSUNITY_BRDF_PBS 2
	#elif defined(UNITY_PBS_USE_BRDF1)
		#define SSUNITY_BRDF_PBS 1
	#elif defined(SHADER_TARGET_SURFACE_ANALYSIS)
		// we do preprocess pass during shader analysis and we dont actually care about brdf as we need only inputs/outputs
		#define SSUNITY_BRDF_PBS 1
	#else
		#error something broke in auto-choosing BRDF (Shader Sandwich)
	#endif
#endif

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
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
};
struct VertexToPixel{
	float4 position : POSITION;
	float4 TtoWSpaceX : TEXCOORD0;
	float4 TtoWSpaceY : TEXCOORD1;
	float4 TtoWSpaceZ : TEXCOORD2;
	float2 uv_MainTex : TEXCOORD3;
	float2 uv_BumpMap : TEXCOORD4;
	#define pos position
		UNITY_FOG_COORDS(5)
#undef pos
	#ifdef SHADOWS_CUBE
		float3 vec : TEXCOORD6;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos : TEXCOORD7;
		#endif
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldTangent;
	float3 worldBitangent;
	float3 worldViewDir;
	float4 TtoWSpaceX;
	float4 TtoWSpaceY;
	float4 TtoWSpaceZ;
	float2 uv_MainTex;
	float2 uv_BumpMap;
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
//OutputPremultiplied: True
//UseAlphaGenerate: True
half3 Tangent_Normals ( VertexData vd){
	half3 Surface = half3(0,0,1);
		//Generate layers for the Normals channel.
			//Generate Layer: Normal Map
				//Sample parts of the layer:
					half4 Normal_MapNormals_Sample1 = tex2D(_BumpMap,vd.uv_BumpMap);
	
				//Apply Effects:
					Normal_MapNormals_Sample1 = float4(UnpackNormal(Normal_MapNormals_Sample1),Normal_MapNormals_Sample1.a);
					Normal_MapNormals_Sample1.a = 1;
	
	Surface = lerp(Surface,Normal_MapNormals_Sample1.rgb,Normal_MapNormals_Sample1.a * _Normal_Height);//1
	
	
	return normalize(half3(dot(vd.TtoWSpaceX.xyz, Surface),dot(vd.TtoWSpaceY.xyz, Surface),dot(vd.TtoWSpaceZ.xyz, Surface)));
	
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Sub_Surface_Scattering ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1);
		//Generate layers for the SSS Color channel.
			//Generate Layer: SSS Color 2
				//Sample parts of the layer:
					half4 SSS_Color_2SSS_Color_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(SSS_Color_2SSS_Color_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: SSS Color
				//Sample parts of the layer:
					half4 SSS_ColorSSS_Color_Sample1 = _Color;
	
	Surface = half4(SSS_ColorSSS_Color_Sample1.rgb,1) ;//0
	
	
	return Surface;
	
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Specular ( VertexData vd, inout half4 previousBaseColor){
	half Metalness = 0;//Metallic Mode
	half3 Surface = lerp (0.034-(1-_Shininess)*0.01836, previousBaseColor, Metalness);
	half oneMinusReflectivity = OneMinusReflectivityFromMetallic(Metalness);
	half reflectivity = 1-oneMinusReflectivity;
	half nv = saturate(dot(vd.worldNormal, vd.worldViewDir));
	half nvPow5 = Pow5 (1-nv);
	return float4(Surface,lerp(1,nvPow5,oneMinusReflectivity));
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Scale channel.
			//Generate Layer: SSS Scale
				//Sample parts of the layer:
					half4 SSS_ScaleMask1_Sample1 = _SSS_Scale;
	
	Mask0 = SSS_ScaleMask1_Sample1.r;//2
	
	
			//Generate Layer: SSS Scale2
				//Sample parts of the layer:
					half4 SSS_Scale2Mask1_Sample1 = length(fwidth(vd.worldNormal)) / max(length(fwidth(vd.worldPos) * 1),0.0001);
	
				//Apply Effects:
					SSS_Scale2Mask1_Sample1.rgb = clamp(SSS_Scale2Mask1_Sample1.rgb,_Scale_GLMin,_Scale_GLMax);
	
	Mask0 = (Mask0 * SSS_Scale2Mask1_Sample1.r);//0
	
	
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
	vd.worldTangent = UnityObjectToWorldNormalNew(v.tangent);
	vd.worldBitangent = cross(vd.worldNormal, vd.worldTangent) * v.tangent.w * unity_WorldTransformParams.w;
	vd.TtoWSpaceX = float4(vd.worldTangent.x, vd.worldBitangent.x, vd.worldNormal.x, vd.worldPos.x);
	vd.TtoWSpaceY = float4(vd.worldTangent.y, vd.worldBitangent.y, vd.worldNormal.y, vd.worldPos.y);
	vd.TtoWSpaceZ = float4(vd.worldTangent.z, vd.worldBitangent.z, vd.worldNormal.z, vd.worldPos.z);
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	vd.uv_BumpMap = TRANSFORM_TEX(v.texcoord, _BumpMap);
	
	
vd.Mask0 = Mask_Mask0 ( vd);
	
	
	vtp.position = vd.position;
	vtp.TtoWSpaceX = vd.TtoWSpaceX;
	vtp.TtoWSpaceY = vd.TtoWSpaceY;
	vtp.TtoWSpaceZ = vd.TtoWSpaceZ;
	vtp.uv_MainTex = vd.uv_MainTex;
	vtp.uv_BumpMap = vd.uv_BumpMap;
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
				vd.worldPos = half3(vtp.TtoWSpaceX.w,vtp.TtoWSpaceY.w,vtp.TtoWSpaceZ.w);
				vd.worldNormal = half3(vtp.TtoWSpaceX.z,vtp.TtoWSpaceY.z,vtp.TtoWSpaceZ.z);
				vd.worldViewDir = 0;
				#ifdef SHADOWS_DEPTH
					//Sorry, no support for directional lights unless Screen Space Shadows are turned off...too much of a pain :/
					vd.worldViewDir = normalize(UnityWorldSpaceLightDir(vd.worldPos));
					if (dot(vd.worldViewDir,vd.worldNormal)<0)
						vd.worldViewDir *= -1;
				#else
					vd.worldViewDir = normalize(UnityWorldSpaceLightDir(vd.worldPos));
				#endif
;
				vd.TtoWSpaceX = vtp.TtoWSpaceX;
				vd.TtoWSpaceY = vtp.TtoWSpaceY;
				vd.TtoWSpaceZ = vtp.TtoWSpaceZ;
				vd.uv_MainTex = vtp.uv_MainTex;
				vd.uv_BumpMap = vtp.uv_BumpMap;
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
				half4 previousBaseColor = 0;//Honestly just a quick hack to get Metal specular working XD
				outputNormal = vd.worldNormal;
vd.Mask0 = Mask_Mask0 ( vd);
				half3 outputTangent_Normals = Tangent_Normals ( vd);
				outputNormal = outputTangent_Normals.rgb;//0
								vd.worldNormal = outputNormal;
				half4 outputSub_Surface_Scattering = Sub_Surface_Scattering ( vd);
				outputColor = half4(outputSub_Surface_Scattering.rgb,1);//7
								half4 outputSpecular = Specular ( vd, previousBaseColor);
				outputColor = ((outputColor) * (1 - (outputSpecular.a)) + (half4(outputSpecular.rgb, outputSpecular.a)));//1
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
			VisName(Text): "Base (RGB)"
			ImageDefault(Float): 0
			Image(Text): ""
			NormalMap(Float): 0
			DefaultTexture(Text): "White"
			SeeTilingOffset(Toggle): True
			TilingOffset(Vec): 1,1,0,0
			MainType(Text): "MainTexture"
			CustomFallback(Text): "_MainTex"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "Color"
			Color(Vec): 1,1,1,1
			MainType(Text): "MainColor"
			CustomFallback(Text): "_Color"
		End Shader Input


		Begin Shader Input
			Type(Text): "Image"
			VisName(Text): "Normal"
			ImageDefault(Float): 0
			Image(Text): "f89b49f3dcf5130458e26b47a4991c4e"
			NormalMap(Float): 0
			DefaultTexture(Text): "Bump"
			SeeTilingOffset(Toggle): True
			TilingOffset(Vec): 1,1,0,0
			MainType(Text): "BumpMap"
			CustomFallback(Text): "_BumpMap"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Normal Height"
			Number(Float): 0
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Normal_Height"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Roughness"
			Number(Float): 0.5618154
			Range0(Float): 0.002
			Range1(Float): 1
			MainType(Text): "Shininess"
			CustomFallback(Text): "_Shininess"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "SSS Scale"
			Number(Float): 0.0643739
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_SSS_Scale"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "SSS Color"
			Color(Vec): 1,0.3,0.3,1
			CustomFallback(Text): "_SSS_Color"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "SSS Fringing"
			Number(Float): 0.1428572
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_SSS_Fringing"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Scale - Min"
			Number(Float): 15
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Scale_GLMin"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Scale - Max"
			Number(Float): 20
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Scale_GLMax"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "SSS Scale 2"
			Number(Float): 0.637931
			Range0(Float): 0
			Range1(Float): 1
			SpecialType(Text): "Mask"
			InEditor(Float): 0
			CustomFallback(Text): "vd.Mask0"
			Mask(ObjectArray): Scale - {ObjectID = 0}
		End Shader Input

		ShaderName(Text): "Shader Sandwich/Enhanced Graphics/Sub Surface Scattering"
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

				LayerListUniqueName(Text): "Mask1"
				LayerListName(Text): "Scale"
				Is Mask(Toggle): True
				EndTag(Text): "r"

				Begin Shader Layer
					Layer Name(Text): "SSS Scale"
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
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Number(Float): 0.0643739 - {Input = 5}
					Color(Vec): 0.627451,0.8,0.8823529,1
					Scale(Float): 15
				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "SSS Scale2"
					Layer Type(ObjectArray): SLTCurvature - {ObjectID = 23}
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
					Mix Type(Type): Multiply - {TypeID = 3}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Scale(Float): 1
					Color(Vec): 0.627451,0.8,0.8823529,1
					Number(Float): 0.5
					Begin Shader Effect
						TypeS(Text): "SSEMathClamp"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						Min(Float): 15 - {Input = 8}
						Max(Float): 20 - {Input = 9}
					End Shader Effect

				End Shader Layer

			End Shader Layer List

		End Masks

		Begin Shader Pass
			Name(Text): "Skin"
			Visible(Toggle): True

			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceTangentNormals"
				User Name(Text): "Tangent Normals"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Blend - {TypeID = 0}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): False
				Normalize(Toggle): True

				Begin Shader Layer List

					LayerListUniqueName(Text): "Normals"
					LayerListName(Text): "Normals"
					Is Mask(Toggle): False
					EndTag(Text): "rgb"

					Begin Shader Layer
						Layer Name(Text): "Normal Map"
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
						Mix Amount(Float): 0 - {Input = 3}
						Mix Type(Type): Mix - {TypeID = 0}
						Stencil(ObjectArray): SSNone - {ObjectID = -1}
						Texture(Texture): f89b49f3dcf5130458e26b47a4991c4e - {Input = 2}
						Color(Vec): 0.627451,0.8,0.8823529,1
						Begin Shader Effect
							TypeS(Text): "SSEUnpackNormal"
							IsVisible(Toggle): True
							UseAlpha(Float): 1
						End Shader Effect

					End Shader Layer

				End Shader Layer List

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceSubSurfaceScattering"
				User Name(Text): "Sub Surface Scattering"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Blend - {TypeID = 0}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): True
				SSS Type(Type): The Scattering Sandwich :D - {TypeID = 0}
				SSS Use Thickness(Toggle): True
				SSS Constant Scatter(Float): 1
				SSS Density(Float): 10
				SSS Fresnel Distortion(Float): 0.05
				SSS Fresnel Thinness(Float): 10
				SSS Iterations(Float): 5
				SSS Quality(Type): High - {TypeID = 0}
				SSS RGB Seperate(Toggle): True
				SSS Scale(Float): 0.637931 - {Input = 10}
				RGB Scale(Vec): 1,0.3,0.3,1 - {Input = 6}
				Light Size(Float): 0
				SSS Fringing(Float): 0.1428572 - {Input = 7}
				Scatter Shadows(Toggle): True
				Scatter Shadows Samples(Float): 5
				Scatter Shadows Relative Size(Float): 0.0643739 - {Input = 5}
				Scatter Shadows Size Type(Type): World Size - {TypeID = 1}
				Use Ambient(Toggle): True

				Begin Shader Layer List

					LayerListUniqueName(Text): "SSS Color"
					LayerListName(Text): "SSS Color"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "SSS Color 2"
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
						Texture(Texture):  - {Input = 0}
						Color(Vec): 1,0.3,0.3,1 - {Input = 6}
						ColorOrFloat(Type): SSN/A - {TypeID = 0}
						FillerInput1(Toggle): False
						FillerInput2(Toggle): False
						FillerInput3(Toggle): False
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "SSS Color"
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
						Mix Amount(Float): 1
						Mix Type(Type): Mix - {TypeID = 0}
						Stencil(ObjectArray): SSNone - {ObjectID = -2}
						Color(Vec): 1,1,1,1 - {Input = 1}
					End Shader Layer

				End Shader Layer List

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceSpecular"
				User Name(Text): "Specular"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Blend - {TypeID = 0}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): True
				Specular Type(Type): The Greatest Sandwich\n...shader model - {TypeID = 0}
				Roughness Or Smoothness(Type): Smoothness - {TypeID = 0}
				Smoothness(Float): 0.5618154 - {Input = 4}
				Roughness(Float): 0.5618154 - {Input = 4}
				Light Size(Float): 0
				Spec Energy Conserve(Toggle): True
				Spec Offset(Float): 0
				PBR Quality(Type): Auto - {TypeID = 0}
				PBR Model(Type): Metal - {TypeID = 1}
				Use Tangents(Toggle): False
				Use Ambient(Toggle): True
				Use Roughness Darkening(Toggle): True
				Use Fresnel(Toggle): True

				Begin Shader Layer List

					LayerListUniqueName(Text): "Specular"
					LayerListName(Text): "Metalness"
					Is Mask(Toggle): False
					EndTag(Text): "a"

				End Shader Layer List

			End Shader Ingredient

			Geometry Ingredients

			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierMisc"
				User Name(Text): "Misc Settings"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				ZWriteMode(Type): Yes - {TypeID = 1}
				ZTestMode(Type): Auto - {TypeID = 0}
				CullMode(Type): Back Faces - {TypeID = 0}
				ShaderModel(Type): Shader Model 3.0 - {TypeID = 3}
				Use Fog(Toggle): True
				Use Lightmaps(Toggle): True
				Use Forward Full Shadows(Toggle): True
				Use Forward Vertex Lights(Toggle): True
				Use Shadows(Toggle): True
				Generate Forward Base Pass(Toggle): True
				Generate Forward Add Pass(Toggle): True
				Generate Deferred Pass(Toggle): True
				Generate Shadow Caster Pass(Toggle): True

			End Shader Ingredient

		End Shader Pass

	End Shader Base
End Shader Sandwich Shader
*/
