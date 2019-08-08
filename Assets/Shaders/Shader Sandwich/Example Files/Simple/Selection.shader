// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Object Shaders/Selection Shader" {//The Shaders Name
//The inputs shown in the material panel
Properties {
	_Color ("Color", Color) = (0.4779412,0.4779412,0.4779412,1)
	_MainTex ("Texture", 2D) = "white" {}
	_Outline_Color ("Outline Color", Color) = (1,0.6685237,0,1)
	_ShellDistance ("Outline Distance", Range(0.000000000,1.000000000)) = 0.038697320
	_Rim_Thinness ("Rim Thinness", Float) = 2.680000000
	_Wave_Strength ("Wave Strength", Range(0.000000000,1.000000000)) = 0.020661160
	_Wave_Scale ("Wave Scale", Float) = 5.920000000
}

SubShader {
	Tags { "RenderType"="Opaque" "Queue"="Transparent" }//A bunch of settings telling Unity a bit about the shader.
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
				#pragma target 2.0
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
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
	float2 uv_MainTex : TEXCOORD2;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh : TEXCOORD3;
#endif
	#define pos position
		SHADOW_COORDS(4)
		UNITY_FOG_COORDS(5)
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap : TEXCOORD6;
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float2 genericTexcoord;
	float2 uv_MainTex;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap;
	#endif
	float Mask0;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Diffuse ( VertexData vd, UnityGI gi, UnityGIInput giInput){
	half4 Surface = half4(0,0,0,0);
		//Generate layers for the Albedo channel.
			//Generate Layer: Texture 2
				//Sample parts of the layer:
					half4 Texture_2Albedo_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(Texture_2Albedo_Sample1.rgb,1);//7
	
	
			//Generate Layer: Color
				//Sample parts of the layer:
					half4 ColorAlbedo_Sample1 = _Color;
	
				//Apply Effects:
					ColorAlbedo_Sample1.rgb = lerp(float3(0.5,0.5,0.5),ColorAlbedo_Sample1.rgb,1.857143);
	
	Surface = half4((Surface.rgb * ColorAlbedo_Sample1.rgb),1) ;//0
	
	
	float3 Lighting;
	half nll = saturate(dot(vd.worldNormal, gi.light.dir)); //Calculate the dot product of the faces normal and the lights direction. This means a lower number the further the angle of the face is from the light source.
	Unity_GlossyEnvironmentData g;
	g.roughness = 0;
	g.reflUVW = vd.worldViewDir;
	gi = UnityGlobalIllumination(giInput, 1, vd.worldNormal,g);
	Lighting = nll; //Output the final RGB color by multiplying the surfaces color with the light color, then by the distance from the light (or some function of it), and finally by the Dot of the normal and the light direction.
	Lighting *= gi.light.color;
	return half4(gi.indirect.diffuse + Lighting,1)*Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Base
				//Sample parts of the layer:
					half4 BaseSurface_Sample1 = 0;
	
	Surface = BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(NoiseCloud2D(((vd.genericTexcoord+float2(_Time.y * 0.5,0))*float2(_Wave_Scale,_Wave_Scale))*3));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Wave_Strength * vd.Mask0);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * 1);
	
}
float Mask_Mask0 (){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0
				//Sample parts of the layer:
					half4 Mask0Mask0_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Mask0 = Mask0Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask02
				//Sample parts of the layer:
					half4 Mask02Mask0_Sample1 = GammaToLinear(float4(1, 1, 1, 1));
	
	Mask0 = Mask02Mask0_Sample1.r;//0
	
	
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
	vd.genericTexcoord = v.texcoord;
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
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
	
	
vd.Mask0 = Mask_Mask0 ();
	Displace ( vd, v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
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
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
	vtp.uv_MainTex = vd.uv_MainTex;
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
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				vd.uv_MainTex = vtp.uv_MainTex;
	#if UNITY_SHOULD_SAMPLE_SH
				vd.sh = vtp.sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
				vd.lmap = vtp.lmap;
	#endif
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
				half4 outputDiffuse = Diffuse ( vd, gi, giInput);
				outputColor = half4(outputDiffuse.rgb,1);//7
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
				#pragma target 2.0
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
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
	float2 uv_MainTex : TEXCOORD2;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh : TEXCOORD3;
#endif
	#define pos position
		SHADOW_COORDS(4)
		UNITY_FOG_COORDS(5)
#undef pos
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap : TEXCOORD6;
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float2 genericTexcoord;
	float2 uv_MainTex;
	#if UNITY_SHOULD_SAMPLE_SH
		float3 sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
		float4 lmap;
	#endif
	float Mask0;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Diffuse ( VertexData vd, UnityGI gi, UnityGIInput giInput){
	half4 Surface = half4(0,0,0,0);
		//Generate layers for the Albedo channel.
			//Generate Layer: Texture 2
				//Sample parts of the layer:
					half4 Texture_2Albedo_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(Texture_2Albedo_Sample1.rgb,1);//7
	
	
			//Generate Layer: Color
				//Sample parts of the layer:
					half4 ColorAlbedo_Sample1 = _Color;
	
				//Apply Effects:
					ColorAlbedo_Sample1.rgb = lerp(float3(0.5,0.5,0.5),ColorAlbedo_Sample1.rgb,1.857143);
	
	Surface = half4((Surface.rgb * ColorAlbedo_Sample1.rgb),1) ;//0
	
	
	float3 Lighting;
	half nll = saturate(dot(vd.worldNormal, gi.light.dir)); //Calculate the dot product of the faces normal and the lights direction. This means a lower number the further the angle of the face is from the light source.
	UnityGI o_gi;
	ResetUnityGI(o_gi);
	o_gi.light = giInput.light;
	o_gi.light.color *= giInput.atten;
	gi = o_gi;
	Lighting = nll; //Output the final RGB color by multiplying the surfaces color with the light color, then by the distance from the light (or some function of it), and finally by the Dot of the normal and the light direction.
	Lighting *= gi.light.color;
	return half4(Lighting,1)*Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Base
				//Sample parts of the layer:
					half4 BaseSurface_Sample1 = 0;
	
	Surface = BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(NoiseCloud2D(((vd.genericTexcoord+float2(_Time.y * 0.5,0))*float2(_Wave_Scale,_Wave_Scale))*3));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Wave_Strength * vd.Mask0);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * 1);
	
}
float Mask_Mask0 (){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0
				//Sample parts of the layer:
					half4 Mask0Mask0_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Mask0 = Mask0Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask02
				//Sample parts of the layer:
					half4 Mask02Mask0_Sample1 = GammaToLinear(float4(1, 1, 1, 1));
	
	Mask0 = Mask02Mask0_Sample1.r;//0
	
	
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
	vd.genericTexcoord = v.texcoord;
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
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
	
	
vd.Mask0 = Mask_Mask0 ();
	Displace ( vd, v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
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
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
	vtp.uv_MainTex = vd.uv_MainTex;
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
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				vd.uv_MainTex = vtp.uv_MainTex;
	#if UNITY_SHOULD_SAMPLE_SH
				vd.sh = vtp.sh;
#endif
	#if (!defined(LIGHTMAP_OFF))||(SHADER_TARGET >= 30)
				vd.lmap = vtp.lmap;
	#endif
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
				half4 outputDiffuse = Diffuse ( vd, gi, giInput);
				outputColor = half4(outputDiffuse.rgb,1);//7
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
				#pragma target 2.0
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
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
	float2 genericTexcoord;
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
//UseAlphaGenerate: False
half4 Diffuse ( VertexData vd){
	half4 Surface = half4(0,0,0,0);
		//Generate layers for the Albedo channel.
			//Generate Layer: Texture 2
				//Sample parts of the layer:
					half4 Texture_2Albedo_Sample1 = tex2D(_MainTex,vd.uv_MainTex);
	
	Surface = half4(Texture_2Albedo_Sample1.rgb,1);//7
	
	
			//Generate Layer: Color
				//Sample parts of the layer:
					half4 ColorAlbedo_Sample1 = _Color;
	
				//Apply Effects:
					ColorAlbedo_Sample1.rgb = lerp(float3(0.5,0.5,0.5),ColorAlbedo_Sample1.rgb,1.857143);
	
	Surface = half4((Surface.rgb * ColorAlbedo_Sample1.rgb),1) ;//0
	
	
	return Surface;
	
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Base
				//Sample parts of the layer:
					half4 BaseSurface_Sample1 = 0;
	
	Surface = BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(NoiseCloud2D(((vd.genericTexcoord+float2(_Time.y * 0.5,0))*float2(_Wave_Scale,_Wave_Scale))*3));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Wave_Strength * vd.Mask0);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * Surface * 1);
	
}
float Mask_Mask0 (){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0
				//Sample parts of the layer:
					half4 Mask0Mask0_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Mask0 = Mask0Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask02
				//Sample parts of the layer:
					half4 Mask02Mask0_Sample1 = GammaToLinear(float4(1, 1, 1, 1));
	
	Mask0 = Mask02Mask0_Sample1.r;//0
	
	
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
	vd.genericTexcoord = v.texcoord;
	vd.uv_MainTex = TRANSFORM_TEX(v.texcoord, _MainTex);
	
	
vd.Mask0 = Mask_Mask0 ();
	Displace ( vd, v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
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
				half4 outputDiffuse = Diffuse ( vd);
				outputColor = half4(outputDiffuse.rgb,1);//7
								UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				SHADOW_CASTER_FRAGMENT(vd)
				return outputColor;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "ZWritePrePass"
		Tags { }
	ZTest LEqual
	ZWrite On
	Blend One One
	Cull Back//Culling specifies which sides of the models faces to hide.
	ColorMask 0

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma target 3.0
				#pragma multi_compile_fog
				#pragma multi_compile __ UNITY_COLORSPACE_GAMMA
				#include "HLSLSupport.cginc"
				#include "UnityShaderVariables.cginc"
				#define SHADERSANDWICH_ZWRITEPREPASS
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal
			//Make our inputs accessible by declaring them here.
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 0 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
				UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				return 0;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
	ZTest LEqual
	ZWrite Off
	Blend One One
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 0 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 0 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
				UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				return outputColor;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "ZWritePrePass"
		Tags { }
	ZTest LEqual
	ZWrite On
	Blend One One
	Cull Back//Culling specifies which sides of the models faces to hide.
	ColorMask 0

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma target 3.0
				#pragma multi_compile_fog
				#pragma multi_compile __ UNITY_COLORSPACE_GAMMA
				#include "HLSLSupport.cginc"
				#include "UnityShaderVariables.cginc"
				#define SHADERSANDWICH_ZWRITEPREPASS
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define INTERNAL_DATA
				#define WorldReflectionVector(data,normal) data.worldRefl
				#define WorldNormalVector(data,normal) normal
			//Make our inputs accessible by declaring them here.
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 1 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
				UNITY_APPLY_FOG(vtp.fogCoord, outputColor); // apply fog (UNITY_FOG_COORDS));
				return 0;

			}
		ENDCG
	}
AlphaToMask Off
	Pass {
		Name "FORWARD"
		Tags { "LightMode" = "ForwardBase" }
	ZTest LEqual
	ZWrite Off
	Blend One One
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 1 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
				outputColor = outputSet_Alpha_Channel;//10
								outputColor = Transparency ( outputColor);
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
	#undef pos
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
}
void Shells ( inout VertexShaderInput v){
	
	v.vertex.xyz = float3(v.vertex.xyz + v.normal * 1 * _ShellDistance);
	
}
VertexToPixel Vertex (VertexShaderInput v){
	VertexToPixel vtp;
	UNITY_INITIALIZE_OUTPUT(VertexToPixel,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	Shells ( v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldPos = vtp.worldPos;
				vd.worldNormal = normalize(vtp.worldNormal);
				vd.worldViewDir = normalize(UnityWorldSpaceViewDir(vd.worldPos));
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
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
				float4 _Color;
				sampler2D _MainTex;
float4 _MainTex_ST;
float4 _MainTex_HDR;
				float4 _Outline_Color;
				float _ShellDistance;
				float _Rim_Thinness;
				float _Wave_Strength;
				float _Wave_Scale;

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















float Unique1D(float t){
	return frac(sin(dot(t ,12.9898)) * 43758.5453);
}
void Unique1DFastHashRewrite(float2 Pos,out float4 hash_0){
	float2 Offset = float2(26,161);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/71))*71;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/951.135664));
}
float Unique2D(float2 t){
	float x = frac(sin(dot(floor(t) ,float2(12.9898,78.233))) * 43758.5453);
	return x;
}
float Lerp2D(float2 P, float Col1,float Col2,float Col3,float Col4){
	float2 ft = P * 3.1415927;
	float2 f = (1 - cos(ft)) * 0.5;
	P = f;
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2D(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2D(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}
float Lerp2DNoCos(float2 P, float Col1,float Col2,float Col3,float Col4){
	float S1 = lerp(Col1,Col2,P.x);
	float S2 = lerp(Col3,Col4,P.x);
	float L = lerp(S1,S2,P.y);
	return L;
}
float NoiseCloud2DNoCos(float2 P){
	float4 HashX;
	Unique1DFastHashRewrite(floor(P),HashX);
	float xx = Lerp2DNoCos(frac(P),HashX.x,HashX.y,HashX.z,HashX.w);
	return xx;
}

float NoiseCloud1D(float P){
	float ft = frac(P) * 3.1415927;
	float f = (1 - cos(ft)) * 0.5;
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);
}
float NoiseCloud1DNoCos(float P){
	float f = frac(P);
	P = floor(P);
	float SS = Unique1D(P);
	float SE = Unique1D(P+1);
	return lerp(SS,SE,f);//SS+((SE-SS)*f);
}
float Unique3D(float3 t){
	float x = frac(tan(dot(tan(floor(t)),float3(12.9898,78.233,35.344))) * 9.5453);
	return x;
}

float Lerp3D(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 ft = P * 3.1415927;
	float3 f = (1 - cos(ft)) * 0.5;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float Lerp3DNoCos(float3 P, float SSS,float SES,float ESS,float EES, float SSE,float SEE,float ESE,float EEE){
	float3 f = P;
	float S1 = lerp(SSS,SES,f.x);
	float S2 = lerp(ESS,EES,f.x);
	float F1 = lerp(S1,S2,f.y);
	float S3 = lerp(SSE,SEE,f.x);
	float S4 = lerp(ESE,EEE,f.x);
	float F2 = lerp(S3,S4,f.y);
	float L = lerp(F1,F2,f.z);//F1;
	return L;
}
float NoiseCloud3D(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3D(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}
float NoiseCloud3DNoCos(float3 P){
	float SSS = Unique3D(P+float3(0,0,0));
	float SES = Unique3D(P+float3(1,0,0));
	float ESS = Unique3D(P+float3(0,1,0));
	float EES = Unique3D(P+float3(1,1,0));
	float SSE = Unique3D(P+float3(0,0,1));
	float SEE = Unique3D(P+float3(1,0,1));
	float ESE = Unique3D(P+float3(0,1,1));
	float EEE = Unique3D(P+float3(1,1,1));
	float xx = Lerp3DNoCos(frac(P),SSS,SES,ESS,EES,SSE,SEE,ESE,EEE);
	return xx;
}











struct VertexShaderInput{
	float4 vertex : POSITION;
	float3 normal : NORMAL;
};
struct VertexToPixel{
	float3 worldPos : TEXCOORD0;
	float4 position : POSITION;
	float3 worldNormal : TEXCOORD1;
	#define pos position
		UNITY_FOG_COORDS(2)
#undef pos
	#ifdef SHADOWS_CUBE
		float3 vec : TEXCOORD3;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos : TEXCOORD4;
		#endif
	#endif
};

struct VertexData{
	float3 worldPos;
	float4 position;
	float3 worldNormal;
	float3 worldViewDir;
	#ifdef SHADOWS_CUBE
		float3 vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos;
		#endif
	#endif
	float Atten;
};
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Texture 2 2
				//Sample parts of the layer:
					half4 Texture_2_2Surface_Sample1 = lerp(GammaToLinear(float4(0, 0, 0, 1)), _Outline_Color, 1-dot(vd.worldNormal, vd.worldViewDir));
	
				//Apply Effects:
					Texture_2_2Surface_Sample1.rgb = pow(Texture_2_2Surface_Sample1.rgb,_Rim_Thinness);
	
	Surface = half4(Texture_2_2Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
//OutputPremultiplied: False
//UseAlphaGenerate: True
half4 Set_Alpha_Channel ( half4 outputColor){
	float Surface = 0;
		//Generate layers for the Transparency channel.
			//Generate Layer: Legacy Transparency Base
				//Sample parts of the layer:
					half4 Legacy_Transparency_BaseTransparency_Sample1 = 1;
	
	Surface = Legacy_Transparency_BaseTransparency_Sample1.a;//2
	
	
	
	return float4(outputColor.rgb,Surface);
	
}
float4 Transparency ( float4 outputColor){
	clip (outputColor.a - 0);
	outputColor *= 1;
	outputColor.rgb *= outputColor.a;
	return outputColor;
	
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
	
	
	
	
	vtp.worldPos = vd.worldPos;
	vtp.position = vd.position;
	vtp.worldNormal = vd.worldNormal;
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
				vd.worldNormal = normalize(vtp.worldNormal);
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
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
				outputNormal = vd.worldNormal;
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
								half4 outputSet_Alpha_Channel = Set_Alpha_Channel ( outputColor);
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
			Type(Text): "Color"
			VisName(Text): "Color"
			Color(Vec): 0.4779412,0.4779412,0.4779412,1
			MainType(Text): "MainColor"
			CustomFallback(Text): "_Color"
		End Shader Input


		Begin Shader Input
			Type(Text): "Image"
			VisName(Text): "Texture"
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
			VisName(Text): "Outline Color"
			Color(Vec): 1,0.6685237,0,1
			CustomFallback(Text): "_Outline_Color"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Outline Distance"
			Number(Float): 0.03869732
			Range0(Float): 0
			Range1(Float): 1
			MainType(Text): "ShellDistance"
			CustomFallback(Text): "_ShellDistance"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Rim Thinness"
			Number(Float): 2.68
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Rim_Thinness"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Wave Strength"
			Number(Float): 0.02066116
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Wave_Strength"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Wave Scale"
			Number(Float): 5.92
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Wave_Scale"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Mask02 - Mix Amount"
			Number(Float): 1
			Range0(Float): 0
			Range1(Float): 1
			SpecialType(Text): "ShellDepthInvertedNormalized"
			InEditor(Float): 0
			CustomFallback(Text): "1"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Vertex - X Offset"
			Number(Float): 467.9824
			Range0(Float): 0
			Range1(Float): 1
			SpecialType(Text): "Time"
			InputScale(Float): 0.5
			InEditor(Float): 0
			CustomFallback(Text): "_Time.y * 0.5"
		End Shader Input

		ShaderName(Text): "Shader Sandwich/Simple/Selection"
		Tech Lod(Float): 200
		Fallback(Type): Diffuse - {TypeID = 0}
		CustomFallback(Text): "Legacy Shaders/VertexLit"
		Queue(Type): Auto - {TypeID = 0}
		Custom Queue(Float): 2000
		QueueAuto(Toggle): True
		Replacement(Type): Auto - {TypeID = 0}
		ReplacementAuto(Toggle): True
		Tech Shader Target(Float): 2
		Exclude DX9(Toggle): False

		Begin Masks

			Begin Shader Layer List

				LayerListUniqueName(Text): "Mask0"
				LayerListName(Text): "Mask0"
				Is Mask(Toggle): True
				EndTag(Text): "r"

				Begin Shader Layer
					Layer Name(Text): "Mask0"
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
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Cubemap(Cubemap): 
					Noise Dimensions(Type): SSN/A - {TypeID = 0}
					Color(Vec): 0,0,0,1
					Color 2(Vec): 0,0,0,1
					Texture(Texture): 
					Jitter(Float): 0
					Fill(Float): 0
					MinSize(Float): 0
					Edge(Float): 1
					MaxSize(Float): 1
					Square(Toggle): False
				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "Mask02"
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
					Mix Amount(Float): 1 - {Input = 7}
					Mix Type(Type): Mix - {TypeID = 0}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Cubemap(Cubemap): 
					Noise Dimensions(Type): SSN/A - {TypeID = 0}
					Color(Vec): 1,1,1,1
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

		End Masks

		Begin Shader Pass
			Name(Text): "Base"
			Visible(Toggle): True

			Begin Shader Ingredient

				Type(Text): "ShaderSurfaceDiffuse"
				User Name(Text): "Diffuse"
				Use Custom Lighting(Toggle): False
				Use Custom Ambient(Toggle): False
				Alpha Blend Mode(Type): Blend - {TypeID = 0}
				Mix Amount(Float): 1
				Mix Type(Type): Mix - {TypeID = 0}
				Use Alpha(Toggle): True
				ShouldLink(Toggle): True
				Lighting Type(Type): Standard - {TypeID = 2}
				Roughness Or Smoothness(Type): Smoothness - {TypeID = 0}
				Smoothness(Float): 0.3
				Roughness(Float): 0
				Light Size(Float): 0
				Wrap Amount(Float): 0
				Wrap Color(Vec): 0.4,0.2,0.2,1
				PBR Quality(Type): Auto - {TypeID = 0}
				Disable Normals(Float): 0
				Use Ambient(Toggle): True
				Use Tangents(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Albedo"
					LayerListName(Text): "Albedo"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "Texture 2"
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
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 0.627451,0.8,0.8823529,1
						Texture(Texture):  - {Input = 1}
						Color 2(Vec): 0,0,0,1
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Color"
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
						Mix Type(Type): Multiply - {TypeID = 3}
						Stencil(ObjectArray): SSNone - {ObjectID = -1}
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 0.4779412,0.4779412,0.4779412,1 - {Input = 0}
						Color 2(Vec): 0,0,0,1
						Texture(Texture): 
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
						Begin Shader Effect
							TypeS(Text): "SSEContrast"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Contrast(Float): 1.857143
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
				ShaderModel(Type): Shader Model 2.0 - {TypeID = 1}
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
				Strength(Float): 1
				MidLevel(Float): 0
				Independent XYZ(Toggle): True

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Displacement"
					Is Mask(Toggle): False
					EndTag(Text): "rgb"

					Begin Shader Layer
						Layer Name(Text): "Base"
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
						Color(Vec): 0.5,0.8823529,1,1
						Number(Float): 0
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex"
						Layer Type(ObjectArray): SLTCloudNoise - {ObjectID = 12}
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
						Mix Amount(Float): 0.02066116 - {Input = 5}
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask0 - {ObjectID = 0}
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 1,1,1,1
						Color 2(Vec): 0,0,0,1
						Texture(Texture): 
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
						Weird Noise Dimensions(Type): 2D - {TypeID = 1}
						Smoother(Toggle): True
						Gamma Correct(Toggle): True
						Begin Shader Effect
							TypeS(Text): "SSEUVScale"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Seperate(Toggle): False
							X Scale(Float): 5.92 - {Input = 6}
							Y Scale(Float): 5.92 - {Input = 6}
							Z Scale(Float): 5.92 - {Input = 6}
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEUVOffset"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							X Offset(Float): 238.4613 - {Input = 8}
							Y Offset(Float): 0
							Z Offset(Float): 0
						End Shader Effect

					End Shader Layer

				End Shader Layer List

			End Shader Ingredient

		End Shader Pass

		Begin Shader Pass
			Name(Text): "Shells"
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
						Layer Name(Text): "Texture 2 2"
						Layer Type(ObjectArray): SLTGradient - {ObjectID = 9}
						UV Map(Type): Generate - {TypeID = 1}
						Map Local(Toggle): False
						Map Space(Type): World - {TypeID = 0}
						Map Generate Space(Type): Rim - {TypeID = 2}
						Map Inverted(Toggle): False
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
						Cubemap(Cubemap): 
						Noise Dimensions(Type): SSN/A - {TypeID = 0}
						Color(Vec): 1,0.6685237,0,1 - {Input = 2}
						Color 2(Vec): 0,0,0,1
						Texture(Texture): 
						Jitter(Float): 0
						Fill(Float): 0
						MinSize(Float): 0
						Edge(Float): 1
						MaxSize(Float): 1
						Square(Toggle): False
						Gamma Correct(Toggle): True
						Cheap Gamma Correct(Toggle): False
						Begin Shader Effect
							TypeS(Text): "SSEUVFlip"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							X Flip(Toggle): True
							Y Flip(Toggle): False
							Z Flip(Toggle): False
						End Shader Effect

						Begin Shader Effect
							TypeS(Text): "SSEMathPow"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Power(Float): 2.68 - {Input = 4}
						End Shader Effect

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
					EndTag(Text): "a"

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
						Color(Vec): 0.5,0.8823529,1,1
						Number(Float): 1
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
				Generate Forward Add Pass(Toggle): True
				Generate Deferred Pass(Toggle): True
				Generate Shadow Caster Pass(Toggle): True

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierTransparency"
				User Name(Text): "Transparency"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				Transparency Type(Type): Fade - {TypeID = 1}
				Transparency ZWrite(Type): Full - {TypeID = 2}
				Shadow Type Fade(Type): Cutout - {TypeID = 1}
				Cutout Amount(Float): 0
				Transparency(Float): 1
				Blend Mode(Type): Add - {TypeID = 1}

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierShells"
				User Name(Text): "Shells"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				ShellCount(Float): 1
				ShellDistance(Float): 0.03869732 - {Input = 3}
				ShellDistanceType(Type): Local - {TypeID = 0}
				ShellSide(Type): Front - {TypeID = 0}
				ShellEase(Float): 1.022989
				ShellEaseInv(Toggle): True
				ShellSkipFirst(Toggle): False

			End Shader Ingredient

		End Shader Pass

	End Shader Base
End Shader Sandwich Shader
*/
