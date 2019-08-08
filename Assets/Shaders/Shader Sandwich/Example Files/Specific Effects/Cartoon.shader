// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Object Shaders/Cartoon Shader" {//The Shaders Name
//The inputs shown in the material panel
Properties {
	_Color_A ("Color A", Color) = (0,0.08088242,0.2132353,1)
	_Color_B ("Color B", Color) = (1,0.3147634,0.09558821,1)
	_Outline_Thickness ("Outline Thickness", Range(0.000000000,0.100000000)) = 0.012307690
}

SubShader {
	Tags { "RenderType"="Opaque" "Queue"="AlphaTest" }//A bunch of settings telling Unity a bit about the shader.
	LOD 200
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
	ZTest LEqual
	ZWrite Off
	Blend Off//No transparency
	Cull Front//Culling specifies which sides of the models faces to hide.

		
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
				float4 _Color_A;
				float4 _Color_B;
				float _Outline_Thickness;

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
};
struct VertexToPixel{
	float4 position : POSITION;
	float3 screenPos : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
	#undef pos
};

struct VertexData{
	float4 position;
	float3 screenPos;
	float Mask1;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit (){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo
				//Sample parts of the layer:
					half4 AlbedoSurface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(AlbedoSurface_Sample1.rgb,1) ;//0
	
	
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half Surface = 1;
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * vd.Mask1);
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Strength channel.
			//Generate Layer: Strength 2
				//Sample parts of the layer:
					half4 Strength_2Mask1_Sample1 = _Outline_Thickness;
	
	Mask1 = Strength_2Mask1_Sample1.b;//2
	
	
			//Generate Layer: Distance
				//Sample parts of the layer:
					half4 DistanceMask1_Sample1 = vd.screenPos.z;
	
	Mask1 = (Mask1 * DistanceMask1_Sample1.b);//0
	
	
	return Mask1;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
vd.Mask1 = Mask_Mask1 ( vd);
	Displace ( vd, v);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
	vtp.position = vd.position;
	vtp.screenPos = vd.screenPos;
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
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
vd.Mask1 = Mask_Mask1 ( vd);
				half4 outputUnlit = Unlit ();
				outputColor = half4(outputUnlit.rgb,1);//7
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
	ZWrite Off
	Blend One One
	Cull Front//Culling specifies which sides of the models faces to hide.

		
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
				float4 _Color_A;
				float4 _Color_B;
				float _Outline_Thickness;

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
};
struct VertexToPixel{
	float4 position : POSITION;
	float3 screenPos : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
	#undef pos
};

struct VertexData{
	float4 position;
	float3 screenPos;
	float Mask1;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit (){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo
				//Sample parts of the layer:
					half4 AlbedoSurface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(AlbedoSurface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half Surface = 1;
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * vd.Mask1);
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Strength channel.
			//Generate Layer: Strength 2
				//Sample parts of the layer:
					half4 Strength_2Mask1_Sample1 = _Outline_Thickness;
	
	Mask1 = Strength_2Mask1_Sample1.b;//2
	
	
			//Generate Layer: Distance
				//Sample parts of the layer:
					half4 DistanceMask1_Sample1 = vd.screenPos.z;
	
	Mask1 = (Mask1 * DistanceMask1_Sample1.b);//0
	
	
	return Mask1;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
vd.Mask1 = Mask_Mask1 ( vd);
	Displace ( vd, v);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
	vtp.position = vd.position;
	vtp.screenPos = vd.screenPos;
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
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
vd.Mask1 = Mask_Mask1 ( vd);
				half4 outputUnlit = Unlit ();
				outputColor = half4(outputUnlit.rgb,1);//7
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
	ZWrite Off
	Blend Off//No transparency
	Cull Front//Culling specifies which sides of the models faces to hide.

		
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
				float4 _Color_A;
				float4 _Color_B;
				float _Outline_Thickness;

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
};
struct VertexToPixel{
	float4 position : POSITION;
	float3 screenPos : TEXCOORD0;
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
	float3 screenPos;
	#ifdef SHADOWS_CUBE
		float3 vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos;
		#endif
	#endif
	float Mask1;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit (){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo
				//Sample parts of the layer:
					half4 AlbedoSurface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(AlbedoSurface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half Surface = 1;
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * vd.Mask1);
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Strength channel.
			//Generate Layer: Strength 2
				//Sample parts of the layer:
					half4 Strength_2Mask1_Sample1 = _Outline_Thickness;
	
	Mask1 = Strength_2Mask1_Sample1.b;//2
	
	
			//Generate Layer: Distance
				//Sample parts of the layer:
					half4 DistanceMask1_Sample1 = vd.screenPos.z;
	
	Mask1 = (Mask1 * DistanceMask1_Sample1.b);//0
	
	
	return Mask1;
	
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
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
vd.Mask1 = Mask_Mask1 ( vd);
	Displace ( vd, v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
	vtp.position = vd.position;
	vtp.screenPos = vd.screenPos;
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
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
vd.Mask1 = Mask_Mask1 ( vd);
				half4 outputUnlit = Unlit ();
				outputColor = half4(outputUnlit.rgb,1);//7
								UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				SHADOW_CASTER_FRAGMENT(vd)
				return outputColor;

			}
		ENDCG
	}
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
				float4 _Color_A;
				float4 _Color_B;
				float _Outline_Thickness;

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

	float4 GenerateTriPlanar(float4 XAxis,float4 YAxis, float4 ZAxis, float3 Map, float idk){
		half3 blend = pow(abs(Map),idk);
		blend /= blend.x+blend.y+blend.z;
		return XAxis*blend.x + YAxis*blend.y + ZAxis*blend.z;
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
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	float4 texcoord2 : TEXCOORD2;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	float3 localNormal : TEXCOORD2;
	float3 screenPos : TEXCOORD3;
	float3 worldViewDir : TEXCOORD4;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh : TEXCOORD5;
#endif
	#define pos position
		SHADOW_COORDS(6)
		UNITY_FOG_COORDS(7)
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap : TEXCOORD8;
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 localNormal;
	float3 screenPos;
	float3 worldViewDir;
	float3 worldRefl;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap;
	#endif
	float Mask1;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo 2
				//Sample parts of the layer:
					half4 Albedo_2Surface_Sample1 = _Color_A;
	
	Surface = half4(Albedo_2Surface_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: Unlit
				//Sample parts of the layer:
					float3 UnlitSurface_Sample1_GeneratePos = mul(unity_WorldToObject, float4(vd.worldPos,1)).xyz;
					half4 UnlitSurface_Sample1 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.z+((-0.35))));
					half4 UnlitSurface_Sample2 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.z+((-0.35))));
					half4 UnlitSurface_Sample3 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.x+((-0.35))));
					UnlitSurface_Sample1 = GenerateTriPlanar(UnlitSurface_Sample1, UnlitSurface_Sample2, UnlitSurface_Sample3,vd.localNormal,5);
	
	Surface.rgb = (Surface.rgb + UnlitSurface_Sample1.rgb);//4
	
	
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Specular ( VertexData vd, UnityGI gi, UnityGIInput giInput, out half OneMinusAlpha){
	half3 Surface = half4(0,0,0,1);//Specular Mode
	half oneMinusRoughness = 0.476;
	half perceptualRoughness = 1-oneMinusRoughness;
	half realRoughness = perceptualRoughness*perceptualRoughness;		// need to square perceptual roughness
	half reflectivity = SpecularStrength(Surface);
	half oneMinusReflectivity = 1-reflectivity;
	Unity_GlossyEnvironmentData g;
	g.roughness = (1-0.476);
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
	
	half3 Lighting;
	#if SSUNITY_BRDF_PBS==1
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
	half surfaceReduction = 1;
	half2 rlPow4AndFresnelTerm = Pow4 (half2(dot(vd.worldRefl, gi.light.dir), 1-nv));
	half rlPow4 = rlPow4AndFresnelTerm.x; // power exponent must match kHorizontalWarpExp in NHxRoughness() function in GeneratedTextures.cpp
	half fresnelTerm = rlPow4AndFresnelTerm.y;
	
	
	Lighting =	BRDF3_Direct(0,1,rlPow4,oneMinusRoughness)*nl;
	#endif
	Lighting *= gi.light.color;
	half grazingTerm = saturate((oneMinusRoughness) + (reflectivity));
	#if SSUNITY_BRDF_PBS==1
	Lighting =	Lighting * FresnelTerm (Surface, lh) + surfaceReduction * gi.indirect.specular * FresnelLerp (Surface.rgb, grazingTerm, nv);
	#elif SSUNITY_BRDF_PBS==2
	Lighting =	(Lighting * nl + surfaceReduction * gi.indirect.specular) * FresnelLerpFast (Surface.rgb, grazingTerm, nv);
	#else
	Lighting = (Lighting+gi.indirect.specular) * lerp (Surface.rgb, grazingTerm, fresnelTerm);
	#endif
	OneMinusAlpha = oneMinusReflectivity;
	return half4(Lighting,reflectivity);
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Strength channel.
			//Generate Layer: Strength 2
				//Sample parts of the layer:
					half4 Strength_2Mask1_Sample1 = _Outline_Thickness;
	
	Mask1 = Strength_2Mask1_Sample1.b;//2
	
	
			//Generate Layer: Distance
				//Sample parts of the layer:
					half4 DistanceMask1_Sample1 = vd.screenPos.z;
	
	Mask1 = (Mask1 * DistanceMask1_Sample1.b);//0
	
	
	return Mask1;
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.localNormal = v.normal.xyz;
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
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
	
	
vd.Mask1 = Mask_Mask1 ( vd);
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
	vtp.localNormal = vd.localNormal;
	vtp.screenPos = vd.screenPos;
	vtp.worldViewDir = vd.worldViewDir;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.localNormal = normalize(vtp.localNormal);
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				vd.worldRefl = reflect(-vd.worldViewDir, vd.worldNormal);
	#if UNITY_SHOULD_SAMPLE_SH
				vd.sh = vtp.sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
				vd.lmap = vtp.lmap;
	#endif
				half OneMinusAlpha = 0; //An optimization to avoid redundant 1-a if already calculated in ingredient function :)
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
vd.Mask1 = Mask_Mask1 ( vd);
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSpecular = Specular ( vd, gi, giInput, OneMinusAlpha);
				outputColor = ((outputColor) * OneMinusAlpha + (half4(outputSpecular.rgb, outputSpecular.a)));//1
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
				float4 _Color_A;
				float4 _Color_B;
				float _Outline_Thickness;

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

	float4 GenerateTriPlanar(float4 XAxis,float4 YAxis, float4 ZAxis, float3 Map, float idk){
		half3 blend = pow(abs(Map),idk);
		blend /= blend.x+blend.y+blend.z;
		return XAxis*blend.x + YAxis*blend.y + ZAxis*blend.z;
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
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 localNormal : TEXCOORD1;
	float3 screenPos : TEXCOORD2;
	#define pos position
		UNITY_FOG_COORDS(3)
#undef pos
	#ifdef SHADOWS_CUBE
		float3 vec : TEXCOORD4;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos : TEXCOORD5;
		#endif
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 localNormal;
	float3 screenPos;
	#ifdef SHADOWS_CUBE
		float3 vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos;
		#endif
	#endif
	float Mask1;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo 2
				//Sample parts of the layer:
					half4 Albedo_2Surface_Sample1 = _Color_A;
	
	Surface = half4(Albedo_2Surface_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: Unlit
				//Sample parts of the layer:
					float3 UnlitSurface_Sample1_GeneratePos = mul(unity_WorldToObject, float4(vd.worldPos,1)).xyz;
					half4 UnlitSurface_Sample1 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.z+((-0.35))));
					half4 UnlitSurface_Sample2 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.z+((-0.35))));
					half4 UnlitSurface_Sample3 = lerp(_Color_B, GammaToLinear(float4(0, 0, 0, 1)), (UnlitSurface_Sample1_GeneratePos.x+((-0.35))));
					UnlitSurface_Sample1 = GenerateTriPlanar(UnlitSurface_Sample1, UnlitSurface_Sample2, UnlitSurface_Sample3,vd.localNormal,5);
	
	Surface.rgb = (Surface.rgb + UnlitSurface_Sample1.rgb);//4
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Specular (){
	half3 Surface = half4(0,0,0,1);//Specular Mode
	half reflectivity = SpecularStrength(Surface);
	half oneMinusReflectivity = 1-reflectivity;
	return half4(Surface,reflectivity);
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Strength channel.
			//Generate Layer: Strength 2
				//Sample parts of the layer:
					half4 Strength_2Mask1_Sample1 = _Outline_Thickness;
	
	Mask1 = Strength_2Mask1_Sample1.b;//2
	
	
			//Generate Layer: Distance
				//Sample parts of the layer:
					half4 DistanceMask1_Sample1 = vd.screenPos.z;
	
	Mask1 = (Mask1 * DistanceMask1_Sample1.b);//0
	
	
	return Mask1;
	
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
	vd.localNormal = v.normal.xyz;
	vd.screenPos = ComputeScreenPos (UnityObjectToClipPos (v.vertex)).xyw;
	
	
vd.Mask1 = Mask_Mask1 ( vd);
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.localNormal = vd.localNormal;
	vtp.screenPos = vd.screenPos;
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
				vd.worldPos = vtp.worldPos;
				vd.localNormal = normalize(vtp.localNormal);
				vd.screenPos = float3(vtp.screenPos.xy/vtp.screenPos.z,vtp.screenPos.z);
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
vd.Mask1 = Mask_Mask1 ( vd);
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSpecular = Specular ();
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
			Type(Text): "Color"
			VisName(Text): "Color A"
			Color(Vec): 0,0.08088242,0.2132353,1
			CustomFallback(Text): "_Color_A"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "Color B"
			Color(Vec): 1,0.3147634,0.09558821,1
			CustomFallback(Text): "_Color_B"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Outline Thickness"
			Number(Float): 0.01230769
			Range0(Float): 0
			Range1(Float): 0.1
			CustomFallback(Text): "_Outline_Thickness"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Strength"
			Number(Float): 0.03375133
			Range0(Float): -2
			Range1(Float): 2
			SpecialType(Text): "Mask"
			InEditor(Float): 0
			CustomFallback(Text): "vd.Mask1"
			Mask(ObjectArray): Strength - {ObjectID = 1}
		End Shader Input

		ShaderName(Text): "Shader Sandwich/Specific/Cartoon 1"
		Tech Lod(Float): 200
		Fallback(Type): Diffuse - {TypeID = 0}
		CustomFallback(Text): "\qLegacy Shaders/Diffuse\q"
		Queue(Type): Alpha Test (2450) - {TypeID = 3}
		Custom Queue(Float): 2450
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

			End Shader Layer List

			Begin Shader Layer List

				LayerListUniqueName(Text): "Mask1"
				LayerListName(Text): "Strength"
				Is Mask(Toggle): True
				EndTag(Text): "b"

				Begin Shader Layer
					Layer Name(Text): "Strength 2"
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
					Number(Float): 0.01230769 - {Input = 2}
					Color(Vec): 0.5,0.8823529,1,1
				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "Distance"
					Layer Type(ObjectArray): SLTCurrentOutputDepth - {ObjectID = 19}
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
					Stencil(ObjectArray): SSNone - {ObjectID = -2}
					Color(Vec): 0.5,0.8823529,1,1
					Number(Float): 0.5
				End Shader Layer

			End Shader Layer List

		End Masks

		Begin Shader Pass
			Name(Text): "Pass 2"
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
				ShouldLink(Toggle): False
				RenderForEachLight(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Unlit"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "Albedo"
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
						Color(Vec): 0,0,0,1
					End Shader Layer

				End Shader Layer List

			End Shader Ingredient

			Geometry Ingredients

			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierMisc"
				User Name(Text): "Misc Settings"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				ZWriteMode(Type): No - {TypeID = 2}
				ZTestMode(Type): Auto - {TypeID = 0}
				CullMode(Type): Front Faces - {TypeID = 1}
				ShaderModel(Type): Auto - {TypeID = 0}
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


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierDisplacement"
				User Name(Text): "Displace"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				Direction(Type): Normal - {TypeID = 0}
				Coordinate Space(Type): Object - {TypeID = 0}
				Strength(Float): 0.03375133 - {Input = 3}
				MidLevel(Float): 0
				Independent XYZ(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Displacement"
					Is Mask(Toggle): False
					EndTag(Text): "r"

				End Shader Layer List

			End Shader Ingredient

		End Shader Pass

		Begin Shader Pass
			Name(Text): "Pass 1"
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
				ShouldLink(Toggle): False
				RenderForEachLight(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Unlit"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "Albedo 2"
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
						Color(Vec): 0,0.08088242,0.2132353,1 - {Input = 0}
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Unlit"
						Layer Type(ObjectArray): SLTGradient - {ObjectID = 9}
						UV Map(Type): Generate - {TypeID = 1}
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
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): SSNone - {ObjectID = -2}
						Color(Vec): 0,0,0,1
						Color 2(Vec): 1,0.3147634,0.09558821,1 - {Input = 1}
						Cheap Gamma Correct(Toggle): False
						Gamma Correct(Toggle): True
						Begin Shader Effect
							TypeS(Text): "SSEUVOffset"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							X Offset(Float): -0.35
							Y Offset(Float): 0
							Z Offset(Float): 0
						End Shader Effect

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
				Specular Type(Type): Unity Standard - {TypeID = 1}
				Roughness Or Smoothness(Type): Smoothness - {TypeID = 0}
				Smoothness(Float): 0.476
				Roughness(Float): 0.7
				Light Size(Float): 0
				Spec Energy Conserve(Toggle): True
				Spec Offset(Float): 0
				PBR Quality(Type): Auto - {TypeID = 0}
				PBR Model(Type): Specular - {TypeID = 0}
				Use Tangents(Toggle): False
				Use Ambient(Toggle): True
				Use Roughness Darkening(Toggle): True
				Use Fresnel(Toggle): True

				Begin Shader Layer List

					LayerListUniqueName(Text): "Specular"
					LayerListName(Text): "Specular Color"
					Is Mask(Toggle): False
					EndTag(Text): "rgb"

				End Shader Layer List

			End Shader Ingredient

			Geometry Ingredients

			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierMisc"
				User Name(Text): "Misc Settings"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				ZWriteMode(Type): Auto - {TypeID = 0}
				ZTestMode(Type): Auto - {TypeID = 0}
				CullMode(Type): Back Faces - {TypeID = 0}
				ShaderModel(Type): Auto - {TypeID = 0}
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

		End Shader Pass

	End Shader Base
End Shader Sandwich Shader
*/
