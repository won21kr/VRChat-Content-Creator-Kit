// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Misc/Point Particles" {//The Shaders Name
//The inputs shown in the material panel
Properties {
	_Displacement ("Displacement", Range(0.000000000,1.000000000)) = 0.312500000
	_Small_Displacement_Scale ("Small Displacement Scale", Float) = 5.900000000
	_Brightness ("Brightness", Float) = 1.000000000
	_Inverse_Quality ("Inverse Quality", Range(1.000000000,50.000000000)) = 2.000000000
	_Color_1 ("Color 1", Color) = (0.1176471,0,1,1)
	_Color_2 ("Color 2", Color) = (0,1,0,1)
	_Color_3 ("Color 3", Color) = (0.8627452,0,1,1)
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
				#pragma hull Hull
				#pragma domain Domain
				#pragma target 5.0
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
				#include "Tessellation.cginc" //Include some Unity code for tessellation.
			//Make our inputs accessible by declaring them here.
				float _Displacement;
				float _Small_Displacement_Scale;
				float _Brightness;
				float _Inverse_Quality;
				float4 _Color_1;
				float4 _Color_2;
				float4 _Color_3;

//Some noise code based on the fantastic library by Brian Sharpe, he deserves a ton of credit :)
//brisharpe CIRCLE_A yahoo DOT com
//http://briansharpe.wordpress.com
//https://github.com/BrianSharpe

float2 PerlinInterpolation_C2( float2 x ) { return x * x * x * (x * (x * 6.0 - 15.0) + 10.0); }

void PerlinFastHash2D(float2 Pos,out float4 hash_0, out float4 hash_1){
	float2 Offset = float2(26,161);
	float Domain = 71;
	float2 SomeLargeFloats = float2(951.135664,642.9478304);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/Domain))*Domain;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/SomeLargeFloats.x));
	hash_1 = frac(P*(1/SomeLargeFloats.y));
}

float PerlinNoise2D(float2 P){
	float2 Pi = floor(P);
	float4 Pf_Pfmin1 = P.xyxy-float4(Pi,Pi+1);
	float4 HashX, HashY;
	PerlinFastHash2D(Pi,HashX,HashY);
	float4 GradX = HashX-0.499999;
	float4 GradY = HashY-0.499999;
	float4 GradRes = rsqrt(GradX*GradX+GradY*GradY+0.00001)*(GradX*Pf_Pfmin1.xzxz+GradY*Pf_Pfmin1.yyww);
	
	GradRes *= 1.4142135623730950488016887242097;
	float2 blend = PerlinInterpolation_C2(Pf_Pfmin1.xy);
	float4 blend2 = float4(blend,float2(1.0-blend));
	return (dot(GradRes,blend2.zxzx*blend2.wwyy));
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
	float4 texcoord : TEXCOORD0;
};
struct TessellationShaderInput{
	float4 vertex : INTERNALTESSPOS;
	float4 texcoord : TEXCOORD0;
};
struct TessellationFactors {
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};
struct VertexToPixel{
	float4 position : POSITION;
	float2 genericTexcoord : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
	#undef pos
};

struct VertexData{
	float4 position;
	float2 genericTexcoord;
	float Mask0;
	float Mask1;
	float Mask2;
	float Atten;
};
float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen){
	// distance to edge center
	float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
	// length of the edge
	float len = distance(wpos0, wpos1);
	// edgeLen is approximate desired size in pixels
	float f = len * _ScreenParams.y / (edgeLen * dist);
	return f;
}
float4 EdgeLengthBasedTess (float3 v0, float3 v1, float3 v2, float edgeLength){
	float4 tess;
	tess.x = CalcEdgeTessFactor (v1, v2, edgeLength);
	tess.y = CalcEdgeTessFactor (v2, v0, edgeLength);
	tess.z = CalcEdgeTessFactor (v0, v1, edgeLength);
	tess.xyz = max(1,tess.xyz);
	tess.w = (tess.x + tess.y + tess.z) / 3.0f;
	return tess;
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo2
				//Sample parts of the layer:
					half4 Albedo2Surface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(Albedo2Surface_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: Vertex Copy 2 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2_2Surface_Sample1 = _Color_1;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_2Surface_Sample1.rgb),vd.Mask0);//6
	
	
			//Generate Layer: Vertex Copy 2 Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_2_CopySurface_Sample1 = _Color_2;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_CopySurface_Sample1.rgb),vd.Mask1);//6
	
	
			//Generate Layer: Vertex Copy Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_CopySurface_Sample1 = _Color_3;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_CopySurface_Sample1.rgb),vd.Mask2);//6
	
	
			//Generate Layer: Albedo3
				//Sample parts of the layer:
					half4 Albedo3Surface_Sample1 = Surface;
	
				//Apply Effects:
					Albedo3Surface_Sample1.rgb = (Albedo3Surface_Sample1.rgb*_Brightness);
	
	Surface = half4(Albedo3Surface_Sample1.rgb,1) ;//0
	
	
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Legacy Displacement Base
				//Sample parts of the layer:
					half4 Legacy_Displacement_BaseSurface_Sample1 = 0;
	
	Surface = Legacy_Displacement_BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(float4(1, 0, 0, 1));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Displacement * vd.Mask0);//1
	
	
			//Generate Layer: Vertex Copy 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2Surface_Sample1 = GammaToLinear(float4(0, 1, 0, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_Copy_2Surface_Sample1.rgb),_Displacement * vd.Mask1);//1
	
	
			//Generate Layer: Vertex Copy
				//Sample parts of the layer:
					half4 Vertex_CopySurface_Sample1 = GammaToLinear(float4(0, 0, 1, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_CopySurface_Sample1.rgb),_Displacement * vd.Mask2);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + Surface * 1);
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0 2
				//Sample parts of the layer:
					half4 Mask0_2Mask0_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(0,_Time.y * 0.5))*3)+1)/2;
	
	Mask0 = Mask0_2Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy 2 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2_2Mask0_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(0,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask0 = lerp(Mask0,(Mask0 + Mask0_Copy_2_2Mask0_Sample1.r),0.3127753);//1
	
	
	return Mask0;
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Mask1 channel.
			//Generate Layer: Mask0 Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2Mask1_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.3,_Time.y * 0.5))*3)+1)/2;
	
	Mask1 = Mask0_Copy_2Mask1_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_Copy_2Mask1_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(22.55,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask1 = lerp(Mask1,(Mask1 + Mask0_Copy_Copy_2Mask1_Sample1.r),0.2731278);//1
	
	
	return Mask1;
	
}
float Mask_Mask2 ( VertexData vd){
		//Set default mask color
			float Mask2 = 0;
		//Generate layers for the Mask2 channel.
			//Generate Layer: Mask0 Copy
				//Sample parts of the layer:
					half4 Mask0_CopyMask2_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.55,_Time.y * 0.5))*3)+1)/2;
	
	Mask2 = Mask0_CopyMask2_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy
				//Sample parts of the layer:
					half4 Mask0_Copy_CopyMask2_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(21.54,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask2 = lerp(Mask2,(Mask2 + Mask0_Copy_CopyMask2_Sample1.r),0.3348018);//1
	
	
	return Mask2;
	
}
TessellationShaderInput Vertex (VertexShaderInput v){
	TessellationShaderInput vtp;
	UNITY_INITIALIZE_OUTPUT(TessellationShaderInput,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	
	
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	
	
	vtp.vertex = v.vertex;
	vtp.texcoord = v.texcoord;
	return vtp;
}
TessellationFactors HullTessellationFactors (InputPatch<TessellationShaderInput,3> v) {
	float4 TF = float4(1,1,1,1);
					TF *= EdgeLengthBasedTess(mul(unity_ObjectToWorld,v[0].vertex), mul(unity_ObjectToWorld,v[1].vertex), mul(unity_ObjectToWorld,v[2].vertex), _Inverse_Quality);
	TessellationFactors o;
	o.edge[0] = TF.x;
	o.edge[1] = TF.y;
	o.edge[2] = TF.z;
	o.inside = TF.w;
	return o;
}
[UNITY_domain("tri")]
[UNITY_partitioning("pow2")]
[UNITY_outputtopology("point")]
[UNITY_patchconstantfunc("HullTessellationFactors")]
[UNITY_outputcontrolpoints(3)]
TessellationShaderInput Hull (InputPatch<TessellationShaderInput,3> v, uint id : SV_OutputControlPointID) {
	TessellationShaderInput VT = v[id];
	return VT;
}
[UNITY_domain("tri")]
VertexToPixel Domain (TessellationFactors tessFactors, const OutputPatch<TessellationShaderInput,3> vi, float3 bary : SV_DomainLocation) {
	VertexShaderInput v;
	VertexToPixel vtp;
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
	v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	#define pos position
		UNITY_TRANSFER_FOG(vtp,vtp.pos);
	#undef pos
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	Displace ( vd, v);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	#define pos position
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
	#undef pos
	vtp.position = vd.position;
	vtp.genericTexcoord = vd.genericTexcoord;
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
				vd.genericTexcoord = vtp.genericTexcoord;
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
				half4 outputUnlit = Unlit ( vd);
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
	ZWrite On
	Blend One One
	Cull Back//Culling specifies which sides of the models faces to hide.

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma hull Hull
				#pragma domain Domain
				#pragma target 5.0
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
				#include "Tessellation.cginc" //Include some Unity code for tessellation.
			//Make our inputs accessible by declaring them here.
				float _Displacement;
				float _Small_Displacement_Scale;
				float _Brightness;
				float _Inverse_Quality;
				float4 _Color_1;
				float4 _Color_2;
				float4 _Color_3;

//Some noise code based on the fantastic library by Brian Sharpe, he deserves a ton of credit :)
//brisharpe CIRCLE_A yahoo DOT com
//http://briansharpe.wordpress.com
//https://github.com/BrianSharpe

float2 PerlinInterpolation_C2( float2 x ) { return x * x * x * (x * (x * 6.0 - 15.0) + 10.0); }

void PerlinFastHash2D(float2 Pos,out float4 hash_0, out float4 hash_1){
	float2 Offset = float2(26,161);
	float Domain = 71;
	float2 SomeLargeFloats = float2(951.135664,642.9478304);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/Domain))*Domain;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/SomeLargeFloats.x));
	hash_1 = frac(P*(1/SomeLargeFloats.y));
}

float PerlinNoise2D(float2 P){
	float2 Pi = floor(P);
	float4 Pf_Pfmin1 = P.xyxy-float4(Pi,Pi+1);
	float4 HashX, HashY;
	PerlinFastHash2D(Pi,HashX,HashY);
	float4 GradX = HashX-0.499999;
	float4 GradY = HashY-0.499999;
	float4 GradRes = rsqrt(GradX*GradX+GradY*GradY+0.00001)*(GradX*Pf_Pfmin1.xzxz+GradY*Pf_Pfmin1.yyww);
	
	GradRes *= 1.4142135623730950488016887242097;
	float2 blend = PerlinInterpolation_C2(Pf_Pfmin1.xy);
	float4 blend2 = float4(blend,float2(1.0-blend));
	return (dot(GradRes,blend2.zxzx*blend2.wwyy));
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
	float4 texcoord : TEXCOORD0;
};
struct TessellationShaderInput{
	float4 vertex : INTERNALTESSPOS;
	float4 texcoord : TEXCOORD0;
};
struct TessellationFactors {
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};
struct VertexToPixel{
	float4 position : POSITION;
	float2 genericTexcoord : TEXCOORD0;
	#define pos position
		UNITY_FOG_COORDS(1)
	#undef pos
};

struct VertexData{
	float4 position;
	float2 genericTexcoord;
	float Mask0;
	float Mask1;
	float Mask2;
	float Atten;
};
float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen){
	// distance to edge center
	float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
	// length of the edge
	float len = distance(wpos0, wpos1);
	// edgeLen is approximate desired size in pixels
	float f = len * _ScreenParams.y / (edgeLen * dist);
	return f;
}
float4 EdgeLengthBasedTess (float3 v0, float3 v1, float3 v2, float edgeLength){
	float4 tess;
	tess.x = CalcEdgeTessFactor (v1, v2, edgeLength);
	tess.y = CalcEdgeTessFactor (v2, v0, edgeLength);
	tess.z = CalcEdgeTessFactor (v0, v1, edgeLength);
	tess.xyz = max(1,tess.xyz);
	tess.w = (tess.x + tess.y + tess.z) / 3.0f;
	return tess;
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo2
				//Sample parts of the layer:
					half4 Albedo2Surface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(Albedo2Surface_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: Vertex Copy 2 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2_2Surface_Sample1 = _Color_1;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_2Surface_Sample1.rgb),vd.Mask0);//6
	
	
			//Generate Layer: Vertex Copy 2 Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_2_CopySurface_Sample1 = _Color_2;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_CopySurface_Sample1.rgb),vd.Mask1);//6
	
	
			//Generate Layer: Vertex Copy Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_CopySurface_Sample1 = _Color_3;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_CopySurface_Sample1.rgb),vd.Mask2);//6
	
	
			//Generate Layer: Albedo3
				//Sample parts of the layer:
					half4 Albedo3Surface_Sample1 = Surface;
	
				//Apply Effects:
					Albedo3Surface_Sample1.rgb = (Albedo3Surface_Sample1.rgb*_Brightness);
	
	Surface = half4(Albedo3Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Legacy Displacement Base
				//Sample parts of the layer:
					half4 Legacy_Displacement_BaseSurface_Sample1 = 0;
	
	Surface = Legacy_Displacement_BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(float4(1, 0, 0, 1));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Displacement * vd.Mask0);//1
	
	
			//Generate Layer: Vertex Copy 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2Surface_Sample1 = GammaToLinear(float4(0, 1, 0, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_Copy_2Surface_Sample1.rgb),_Displacement * vd.Mask1);//1
	
	
			//Generate Layer: Vertex Copy
				//Sample parts of the layer:
					half4 Vertex_CopySurface_Sample1 = GammaToLinear(float4(0, 0, 1, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_CopySurface_Sample1.rgb),_Displacement * vd.Mask2);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + Surface * 1);
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0 2
				//Sample parts of the layer:
					half4 Mask0_2Mask0_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(0,_Time.y * 0.5))*3)+1)/2;
	
	Mask0 = Mask0_2Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy 2 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2_2Mask0_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(0,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask0 = lerp(Mask0,(Mask0 + Mask0_Copy_2_2Mask0_Sample1.r),0.3127753);//1
	
	
	return Mask0;
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Mask1 channel.
			//Generate Layer: Mask0 Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2Mask1_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.3,_Time.y * 0.5))*3)+1)/2;
	
	Mask1 = Mask0_Copy_2Mask1_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_Copy_2Mask1_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(22.55,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask1 = lerp(Mask1,(Mask1 + Mask0_Copy_Copy_2Mask1_Sample1.r),0.2731278);//1
	
	
	return Mask1;
	
}
float Mask_Mask2 ( VertexData vd){
		//Set default mask color
			float Mask2 = 0;
		//Generate layers for the Mask2 channel.
			//Generate Layer: Mask0 Copy
				//Sample parts of the layer:
					half4 Mask0_CopyMask2_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.55,_Time.y * 0.5))*3)+1)/2;
	
	Mask2 = Mask0_CopyMask2_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy
				//Sample parts of the layer:
					half4 Mask0_Copy_CopyMask2_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(21.54,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask2 = lerp(Mask2,(Mask2 + Mask0_Copy_CopyMask2_Sample1.r),0.3348018);//1
	
	
	return Mask2;
	
}
TessellationShaderInput Vertex (VertexShaderInput v){
	TessellationShaderInput vtp;
	UNITY_INITIALIZE_OUTPUT(TessellationShaderInput,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	
	
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	
	
	vtp.vertex = v.vertex;
	vtp.texcoord = v.texcoord;
	return vtp;
}
TessellationFactors HullTessellationFactors (InputPatch<TessellationShaderInput,3> v) {
	float4 TF = float4(1,1,1,1);
					TF *= EdgeLengthBasedTess(mul(unity_ObjectToWorld,v[0].vertex), mul(unity_ObjectToWorld,v[1].vertex), mul(unity_ObjectToWorld,v[2].vertex), _Inverse_Quality);
	TessellationFactors o;
	o.edge[0] = TF.x;
	o.edge[1] = TF.y;
	o.edge[2] = TF.z;
	o.inside = TF.w;
	return o;
}
[UNITY_domain("tri")]
[UNITY_partitioning("pow2")]
[UNITY_outputtopology("point")]
[UNITY_patchconstantfunc("HullTessellationFactors")]
[UNITY_outputcontrolpoints(3)]
TessellationShaderInput Hull (InputPatch<TessellationShaderInput,3> v, uint id : SV_OutputControlPointID) {
	TessellationShaderInput VT = v[id];
	return VT;
}
[UNITY_domain("tri")]
VertexToPixel Domain (TessellationFactors tessFactors, const OutputPatch<TessellationShaderInput,3> vi, float3 bary : SV_DomainLocation) {
	VertexShaderInput v;
	VertexToPixel vtp;
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
	v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	#define pos position
		UNITY_TRANSFER_FOG(vtp,vtp.pos);
	#undef pos
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	Displace ( vd, v);
	vd.position = UnityObjectToClipPos(v.vertex);
	vd.genericTexcoord = v.texcoord;
	#define pos position
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
	#undef pos
	vtp.position = vd.position;
	vtp.genericTexcoord = vd.genericTexcoord;
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
				vd.genericTexcoord = vtp.genericTexcoord;
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
				half4 outputUnlit = Unlit ( vd);
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
	ZWrite On
	Blend Off//No transparency
	Cull Back//Culling specifies which sides of the models faces to hide.

		
		CGPROGRAM
			// compile directives
				#pragma vertex Vertex
				#pragma fragment Pixel
				#pragma hull Hull
				#pragma domain Domain
				#pragma target 5.0
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
				#include "Tessellation.cginc" //Include some Unity code for tessellation.
			//Make our inputs accessible by declaring them here.
				float _Displacement;
				float _Small_Displacement_Scale;
				float _Brightness;
				float _Inverse_Quality;
				float4 _Color_1;
				float4 _Color_2;
				float4 _Color_3;

//Some noise code based on the fantastic library by Brian Sharpe, he deserves a ton of credit :)
//brisharpe CIRCLE_A yahoo DOT com
//http://briansharpe.wordpress.com
//https://github.com/BrianSharpe

float2 PerlinInterpolation_C2( float2 x ) { return x * x * x * (x * (x * 6.0 - 15.0) + 10.0); }

void PerlinFastHash2D(float2 Pos,out float4 hash_0, out float4 hash_1){
	float2 Offset = float2(26,161);
	float Domain = 71;
	float2 SomeLargeFloats = float2(951.135664,642.9478304);
	float4 P = float4(Pos.xy,Pos.xy+1);
	P = P-floor(P*(1.0/Domain))*Domain;
	P += Offset.xyxy;
	P *= P;
	P = P.xzxz*P.yyww;
	hash_0 = frac(P*(1/SomeLargeFloats.x));
	hash_1 = frac(P*(1/SomeLargeFloats.y));
}

float PerlinNoise2D(float2 P){
	float2 Pi = floor(P);
	float4 Pf_Pfmin1 = P.xyxy-float4(Pi,Pi+1);
	float4 HashX, HashY;
	PerlinFastHash2D(Pi,HashX,HashY);
	float4 GradX = HashX-0.499999;
	float4 GradY = HashY-0.499999;
	float4 GradRes = rsqrt(GradX*GradX+GradY*GradY+0.00001)*(GradX*Pf_Pfmin1.xzxz+GradY*Pf_Pfmin1.yyww);
	
	GradRes *= 1.4142135623730950488016887242097;
	float2 blend = PerlinInterpolation_C2(Pf_Pfmin1.xy);
	float4 blend2 = float4(blend,float2(1.0-blend));
	return (dot(GradRes,blend2.zxzx*blend2.wwyy));
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
};
struct TessellationShaderInput{
	float4 vertex : INTERNALTESSPOS;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
};
struct TessellationFactors {
	float edge[3] : SV_TessFactor;
	float inside : SV_InsideTessFactor;
};
struct VertexToPixel{
	float4 position : POSITION;
	float2 genericTexcoord : TEXCOORD0;
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
	#ifdef SHADOWS_CUBE
		float3 vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
			float4 hpos;
		#endif
	#endif
	float Mask0;
	float Mask1;
	float Mask2;
	float Atten;
};
float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen){
	// distance to edge center
	float dist = distance (0.5 * (wpos0+wpos1), _WorldSpaceCameraPos);
	// length of the edge
	float len = distance(wpos0, wpos1);
	// edgeLen is approximate desired size in pixels
	float f = len * _ScreenParams.y / (edgeLen * dist);
	return f;
}
float4 EdgeLengthBasedTess (float3 v0, float3 v1, float3 v2, float edgeLength){
	float4 tess;
	tess.x = CalcEdgeTessFactor (v1, v2, edgeLength);
	tess.y = CalcEdgeTessFactor (v2, v0, edgeLength);
	tess.z = CalcEdgeTessFactor (v0, v1, edgeLength);
	tess.xyz = max(1,tess.xyz);
	tess.w = (tess.x + tess.y + tess.z) / 3.0f;
	return tess;
}
//OutputPremultiplied: False
//UseAlphaGenerate: False
half4 Unlit ( VertexData vd){
	half4 Surface = half4(0.8,0.8,0.8,1.0);
		//Generate layers for the Unlit channel.
			//Generate Layer: Albedo2
				//Sample parts of the layer:
					half4 Albedo2Surface_Sample1 = GammaToLinear(float4(0, 0, 0, 1));
	
	Surface = half4(Albedo2Surface_Sample1.rgb,1) ;//0
	
	
			//Generate Layer: Vertex Copy 2 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2_2Surface_Sample1 = _Color_1;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_2Surface_Sample1.rgb),vd.Mask0);//6
	
	
			//Generate Layer: Vertex Copy 2 Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_2_CopySurface_Sample1 = _Color_2;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_2_CopySurface_Sample1.rgb),vd.Mask1);//6
	
	
			//Generate Layer: Vertex Copy Copy
				//Sample parts of the layer:
					half4 Vertex_Copy_CopySurface_Sample1 = _Color_3;
	
	Surface.rgb = lerp(Surface.rgb,(Surface.rgb + Vertex_Copy_CopySurface_Sample1.rgb),vd.Mask2);//6
	
	
			//Generate Layer: Albedo3
				//Sample parts of the layer:
					half4 Albedo3Surface_Sample1 = Surface;
	
				//Apply Effects:
					Albedo3Surface_Sample1.rgb = (Albedo3Surface_Sample1.rgb*_Brightness);
	
	Surface = half4(Albedo3Surface_Sample1.rgb,1) ;//0
	
	
	Surface.rgb = 0;
	return Surface;
}
void Displace ( inout VertexData vd, inout VertexShaderInput v){
	half3 Surface = half3(1,1,1);
		//Generate layers for the Displacement channel.
			//Generate Layer: Legacy Displacement Base
				//Sample parts of the layer:
					half4 Legacy_Displacement_BaseSurface_Sample1 = 0;
	
	Surface = Legacy_Displacement_BaseSurface_Sample1.rgb;//0
	
	
			//Generate Layer: Vertex
				//Sample parts of the layer:
					half4 VertexSurface_Sample1 = GammaToLinear(float4(1, 0, 0, 1));
	
	Surface = lerp(Surface,(Surface + VertexSurface_Sample1.rgb),_Displacement * vd.Mask0);//1
	
	
			//Generate Layer: Vertex Copy 2
				//Sample parts of the layer:
					half4 Vertex_Copy_2Surface_Sample1 = GammaToLinear(float4(0, 1, 0, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_Copy_2Surface_Sample1.rgb),_Displacement * vd.Mask1);//1
	
	
			//Generate Layer: Vertex Copy
				//Sample parts of the layer:
					half4 Vertex_CopySurface_Sample1 = GammaToLinear(float4(0, 0, 1, 1));
	
	Surface = lerp(Surface,(Surface + Vertex_CopySurface_Sample1.rgb),_Displacement * vd.Mask2);//1
	
	
	
	v.vertex.xyz = float3(v.vertex.xyz + Surface * 1);
	
}
float Mask_Mask0 ( VertexData vd){
		//Set default mask color
			float Mask0 = 0;
		//Generate layers for the Mask0 channel.
			//Generate Layer: Mask0 2
				//Sample parts of the layer:
					half4 Mask0_2Mask0_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(0,_Time.y * 0.5))*3)+1)/2;
	
	Mask0 = Mask0_2Mask0_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy 2 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2_2Mask0_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(0,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask0 = lerp(Mask0,(Mask0 + Mask0_Copy_2_2Mask0_Sample1.r),0.3127753);//1
	
	
	return Mask0;
	
}
float Mask_Mask1 ( VertexData vd){
		//Set default mask color
			float Mask1 = 0;
		//Generate layers for the Mask1 channel.
			//Generate Layer: Mask0 Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_2Mask1_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.3,_Time.y * 0.5))*3)+1)/2;
	
	Mask1 = Mask0_Copy_2Mask1_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy 2
				//Sample parts of the layer:
					half4 Mask0_Copy_Copy_2Mask1_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(22.55,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask1 = lerp(Mask1,(Mask1 + Mask0_Copy_Copy_2Mask1_Sample1.r),0.2731278);//1
	
	
	return Mask1;
	
}
float Mask_Mask2 ( VertexData vd){
		//Set default mask color
			float Mask2 = 0;
		//Generate layers for the Mask2 channel.
			//Generate Layer: Mask0 Copy
				//Sample parts of the layer:
					half4 Mask0_CopyMask2_Sample1 = (PerlinNoise2D((vd.genericTexcoord+float2(2.55,_Time.y * 0.5))*3)+1)/2;
	
	Mask2 = Mask0_CopyMask2_Sample1.r;//2
	
	
			//Generate Layer: Mask0 Copy Copy
				//Sample parts of the layer:
					half4 Mask0_Copy_CopyMask2_Sample1 = (PerlinNoise2D(((vd.genericTexcoord+float2(21.54,_Time.y * 0.5))*float2(_Small_Displacement_Scale,_Small_Displacement_Scale))*3)+1)/2;
	
	Mask2 = lerp(Mask2,(Mask2 + Mask0_Copy_CopyMask2_Sample1.r),0.3348018);//1
	
	
	return Mask2;
	
}
TessellationShaderInput Vertex (VertexShaderInput v){
	TessellationShaderInput vtp;
	UNITY_INITIALIZE_OUTPUT(TessellationShaderInput,vtp);
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
	
	
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	
	
	vtp.vertex = v.vertex;
	vtp.normal = v.normal;
	vtp.texcoord = v.texcoord;
	return vtp;
}
TessellationFactors HullTessellationFactors (InputPatch<TessellationShaderInput,3> v) {
	float4 TF = float4(1,1,1,1);
					TF *= EdgeLengthBasedTess(mul(unity_ObjectToWorld,v[0].vertex), mul(unity_ObjectToWorld,v[1].vertex), mul(unity_ObjectToWorld,v[2].vertex), _Inverse_Quality);
	TessellationFactors o;
	o.edge[0] = TF.x;
	o.edge[1] = TF.y;
	o.edge[2] = TF.z;
	o.inside = TF.w;
	return o;
}
[UNITY_domain("tri")]
[UNITY_partitioning("pow2")]
[UNITY_outputtopology("point")]
[UNITY_patchconstantfunc("HullTessellationFactors")]
[UNITY_outputcontrolpoints(3)]
TessellationShaderInput Hull (InputPatch<TessellationShaderInput,3> v, uint id : SV_OutputControlPointID) {
	TessellationShaderInput VT = v[id];
	return VT;
}
[UNITY_domain("tri")]
VertexToPixel Domain (TessellationFactors tessFactors, const OutputPatch<TessellationShaderInput,3> vi, float3 bary : SV_DomainLocation) {
	VertexShaderInput v;
	VertexToPixel vtp;
	VertexData vd;
	UNITY_INITIALIZE_OUTPUT(VertexData,vd);
	v.vertex = vi[0].vertex*bary.x + vi[1].vertex*bary.y + vi[2].vertex*bary.z;
	v.normal = vi[0].normal*bary.x + vi[1].normal*bary.y + vi[2].normal*bary.z;
	v.texcoord = vi[0].texcoord*bary.x + vi[1].texcoord*bary.y + vi[2].texcoord*bary.z;
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
	#define pos position
		UNITY_TRANSFER_FOG(vtp,vtp.pos);
#undef pos
	#ifdef SHADOWS_CUBE
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
		#endif
	#endif
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
	Displace ( vd, v);
	vd.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
	vd.position = 0;
	TRANSFER_SHADOW_CASTER_NOPOS(vd,vd.position);
	vd.worldNormal = UnityObjectToWorldNormalNew(v.normal);
	vd.genericTexcoord = v.texcoord;
	#define pos position
	UNITY_TRANSFER_FOG(vtp,vtp.pos);
#undef pos
	#ifdef SHADOWS_CUBE
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
		#endif
	#endif
	vtp.position = vd.position;
	vtp.genericTexcoord = vd.genericTexcoord;
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
				vd.genericTexcoord = vtp.genericTexcoord;
	#ifdef SHADOWS_CUBE
				vd.vec = vtp.vec;
#endif
	#ifndef SHADOWS_CUBE
		#ifdef UNITY_MIGHT_NOT_HAVE_DEPTH_TEXTURE
				vd.hpos = vtp.hpos;
		#endif
	#endif
vd.Mask0 = Mask_Mask0 ( vd);
vd.Mask1 = Mask_Mask1 ( vd);
vd.Mask2 = Mask_Mask2 ( vd);
				half4 outputUnlit = Unlit ( vd);
				outputColor = half4(outputUnlit.rgb,1);//7
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
			Type(Text): "Range"
			VisName(Text): "Displacement"
			Number(Float): 0.3125
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Displacement"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Small Displacement Scale"
			Number(Float): 5.9
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Small_Displacement_Scale"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Brightness"
			Number(Float): 1
			Range0(Float): 0
			Range1(Float): 1
			CustomFallback(Text): "_Brightness"
		End Shader Input


		Begin Shader Input
			Type(Text): "Range"
			VisName(Text): "Inverse Quality"
			Number(Float): 2
			Range0(Float): 1
			Range1(Float): 50
			CustomFallback(Text): "_Inverse_Quality"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "Color 1"
			Color(Vec): 0.1176471,0,1,1
			CustomFallback(Text): "_Color_1"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "Color 2"
			Color(Vec): 0,1,0,1
			CustomFallback(Text): "_Color_2"
		End Shader Input


		Begin Shader Input
			Type(Text): "Color"
			VisName(Text): "Color 3"
			Color(Vec): 0.8627452,0,1,1
			CustomFallback(Text): "_Color_3"
		End Shader Input


		Begin Shader Input
			Type(Text): "Float"
			VisName(Text): "Offset"
			Number(Float): 194.707
			Range0(Float): 0
			Range1(Float): 1
			SpecialType(Text): "Time"
			InputScale(Float): 0.5
			InEditor(Float): 0
			CustomFallback(Text): "_Time.y * 0.5"
		End Shader Input

		ShaderName(Text): "Shader Sandwich/DX11/Point Particles"
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
					Layer Name(Text): "Mask0 2"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 0
						Y Offset(Float): 180.6926 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy 2 2"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Mix Amount(Float): 0.3127753
					Mix Type(Type): Add - {TypeID = 1}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVScale"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						Seperate(Toggle): False
						X Scale(Float): 5.9 - {Input = 1}
						Y Scale(Float): 5.9 - {Input = 1}
						Z Scale(Float): 5.9 - {Input = 1}
					End Shader Effect

					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 0
						Y Offset(Float): 180.6926 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

			End Shader Layer List

			Begin Shader Layer List

				LayerListUniqueName(Text): "Mask1"
				LayerListName(Text): "Mask1"
				Is Mask(Toggle): True
				EndTag(Text): "r"

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy 2"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 2.3
						Y Offset(Float): 155.2427 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy Copy 2"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Mix Amount(Float): 0.2731278
					Mix Type(Type): Add - {TypeID = 1}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVScale"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						Seperate(Toggle): False
						X Scale(Float): 5.9 - {Input = 1}
						Y Scale(Float): 5.9 - {Input = 1}
						Z Scale(Float): 5.9 - {Input = 1}
					End Shader Effect

					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 22.55
						Y Offset(Float): 155.2427 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

			End Shader Layer List

			Begin Shader Layer List

				LayerListUniqueName(Text): "Mask2"
				LayerListName(Text): "Mask2"
				Is Mask(Toggle): True
				EndTag(Text): "r"

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 2.55
						Y Offset(Float): 155.5847 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

				Begin Shader Layer
					Layer Name(Text): "Mask0 Copy Copy"
					Layer Type(ObjectArray): SLTPerlinNoise - {ObjectID = 10}
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
					Mix Amount(Float): 0.3348018
					Mix Type(Type): Add - {TypeID = 1}
					Stencil(ObjectArray): SSNone - {ObjectID = -1}
					Noise Dimensions(Type): 2D - {TypeID = 0}
					Image Based(Toggle): False
					Gamma Correct(Toggle): False
					Color(Vec): 0.627451,0.8,0.8823529,1
					Begin Shader Effect
						TypeS(Text): "SSEUVScale"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						Seperate(Toggle): False
						X Scale(Float): 5.9 - {Input = 1}
						Y Scale(Float): 5.9 - {Input = 1}
						Z Scale(Float): 5.9 - {Input = 1}
					End Shader Effect

					Begin Shader Effect
						TypeS(Text): "SSEUVOffset"
						IsVisible(Toggle): True
						UseAlpha(Float): 0
						X Offset(Float): 21.54
						Y Offset(Float): 155.5847 - {Input = 7}
						Z Offset(Float): 0
					End Shader Effect

				End Shader Layer

			End Shader Layer List

		End Masks

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
				ShouldLink(Toggle): True
				RenderForEachLight(Toggle): False

				Begin Shader Layer List

					LayerListUniqueName(Text): "Surface"
					LayerListName(Text): "Unlit"
					Is Mask(Toggle): False
					EndTag(Text): "rgba"

					Begin Shader Layer
						Layer Name(Text): "Albedo2"
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
						Color(Vec): 0,0,0,1
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex Copy 2 2"
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
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask0 - {ObjectID = 0}
						Color(Vec): 0.1176471,0,1,1 - {Input = 4}
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex Copy 2 Copy"
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
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask1 - {ObjectID = 1}
						Color(Vec): 0,1,0,1 - {Input = 5}
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex Copy Copy"
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
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask2 - {ObjectID = 2}
						Color(Vec): 0.8627452,0,1,1 - {Input = 6}
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Albedo3"
						Layer Type(ObjectArray): SLTPrevious - {ObjectID = 3}
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
						Color(Vec): 0.627451,0.8,0.8823529,1
						Begin Shader Effect
							TypeS(Text): "SSEMathMul"
							IsVisible(Toggle): True
							UseAlpha(Float): 0
							Multiply(Float): 1 - {Input = 2}
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
				ShaderModel(Type): Shader Model 5.0 - {TypeID = 8}
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

				Type(Text): "ShaderGeometryModifierTessellation"
				User Name(Text): "Subdivide"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				Type(Type): Distance - {TypeID = 2}
				Quality(Float): 2 - {Input = 3}
				ScreenSize(Float): 2 - {Input = 3}
				Falloff(Float): 1
				Snap(Toggle): True

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierToPoints"
				User Name(Text): "Points"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False

			End Shader Ingredient


			Begin Shader Ingredient

				Type(Text): "ShaderGeometryModifierDisplacement"
				User Name(Text): "Displace"
				Mix Amount(Float): 1
				ShouldLink(Toggle): False
				Direction(Type): XYZ - {TypeID = 2}
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
						Layer Name(Text): "Legacy Displacement Base"
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
						Number(Float): 0
						Color(Vec): 0.5,0.8823529,1,1
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex"
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
						Mix Amount(Float): 0.3125 - {Input = 0}
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask0 - {ObjectID = 0}
						Color(Vec): 1,0,0,1
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex Copy 2"
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
						Mix Amount(Float): 0.3125 - {Input = 0}
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask1 - {ObjectID = 1}
						Color(Vec): 0,1,0,1
					End Shader Layer

					Begin Shader Layer
						Layer Name(Text): "Vertex Copy"
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
						Mix Amount(Float): 0.3125 - {Input = 0}
						Mix Type(Type): Add - {TypeID = 1}
						Stencil(ObjectArray): Mask2 - {ObjectID = 2}
						Color(Vec): 0,0,1,1
					End Shader Layer

				End Shader Layer List

			End Shader Ingredient

		End Shader Pass

	End Shader Base
End Shader Sandwich Shader
*/
