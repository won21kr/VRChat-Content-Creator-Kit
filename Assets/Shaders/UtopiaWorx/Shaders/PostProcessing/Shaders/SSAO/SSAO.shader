// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/SSAO"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	CGINCLUDE
	//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 

//
//Variables
//
//************************************
			uniform sampler2D _MainTex;
			uniform float _MainTex_TexelSize;
			uniform sampler2D _CameraDepthNormalsTexture;
			uniform sampler2D _CameraDepthTexture;


			half4x4 _Projection;
			half4x4 _Cam;
			uniform float _Amount ;
			uniform float _Distance;
			uniform float _Tolerance;
			uniform sampler2D _Backup;


			uniform float _Blend;
			uniform float _Radius;

			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;
//************************************
//
//Vertex Function
//
//************************************
            v2f vert(appdata_img v)
			{

				//declare a return value
				v2f o;

 				//set the Vertex position
				o.vertex = UnityObjectToClipPos(v.vertex);

				//set the UV coordinate
				o.uv = v.texcoord.xy;

				//return the object
				return o;
			} 
			

//************************************
//
//Fragment Function
//
//************************************
	inline half invlerp(half from, half to, half value)
	{
		return (value - from) / (to - from);
	}

	inline half3 resolvePos(half4 mulVal)
	{
		return mulVal.xyz / mulVal.w;
	}
	inline half3 findWorldspacePosition(half2 uv, float depthValue)
	{
		//get the position vector
		half4 position = half4(uv.xy * 2.0 - 1.0, depthValue, 1.0);
		//multiply the position by the camera projection
		half4 mulVal = mul(_Projection, position);
		//resolve the position
		return resolvePos(mulVal);
	}



	inline half3 resolveWorldSpaceNormal(half2 uv)
	{
		//get the world space normal pixel from the buffer
		half4 normalVal = tex2D(_CameraDepthNormalsTexture, uv);
		//decode the normal
		half3 vsnormal = DecodeViewNormalStereo(normalVal);
		//multiply the camera position by the the decoded normal
		half3 theNormal = mul((half3x3)_Cam, vsnormal);
		//return the value of the normal from the prespective of the camera
		return theNormal;
	}


	inline half addAO(half2 tcoord, half2 uvIn, half3 p, half3 cnorm)
	{
		//get the UV offset
		half2 uvPos = tcoord + uvIn;
		//get the depth of the offset
		half offsetDepth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uvPos);
		//get the world space position of our offset
		half3 diff = findWorldspacePosition(uvPos, offsetDepth) - p;
		//normalize the offset
		half3 v = normalize(diff);
		//get the length of diff by Distance
		half d = length(diff) * _Distance;
		//The Magic happens here
		return max(0.0, dot(cnorm, v) - _Tolerance) * (1.0 / (1.0 + d)) * _Amount;
	}

		//return a solid white color
		float4 fragWhite(v2f i) : SV_Target
		{
			return float4(1.0,1.0,1.0,1.0);
		}


		float4 fragAO (v2f i) : SV_Target
		{

			//get the depth value
			float depthValue = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);

			//resolve the eye depth
			float eyeDepth = LinearEyeDepth(depthValue);

			//get our current WSP
			half3 position = findWorldspacePosition(i.uv, depthValue);

			//resolve the world space normal
			half3 normal = resolveWorldSpaceNormal(i.uv);

			//pick the higher between the  radius and 0.005
			half radius = max(_Radius / eyeDepth, 0.005);

			//dont render anything past what we can see
			clip(4000.0 - eyeDepth);

			half2 UVSamples[4] = 
			{  
			half2(-1.0, 1.0),
			half2(1.0, 1.0),
			half2(-1.0, -1.0),   
			half2(1.0, -1.0)
			};


			half Darken = 0.0;
			//loop over the UV samples
			for (int j = 0; j < 4; j++)
			{
				half2 UVPos;
				UVPos = UVSamples[j] * radius;

				half2 UVPos2 = UVPos * 0.2;
				UVPos2 = half2(UVPos2.x - UVPos2.y, UVPos2.x + UVPos2.y);


				Darken += addAO(i.uv, UVPos * 0.30, position, normal);
				Darken += addAO(i.uv, UVPos2 * 0.80, position, normal);

			}
				Darken /= 2.0;
				Darken = 1.0 - Darken;
				return float4(Darken,Darken,Darken,1.0);


		}

		float4 fragBlurH(v2f i) : SV_Target
		{
 			offset[0] = 0.0;
 			offset[1] = 1.3846153846;
 			offset[2] = 3.2307692308;

 			weight[0] = 0.2270270270;
 			weight[1] = 0.3162162162;
 			weight[2] = 0.0702702703;


 			_vx_offset = 1.1;
   			float4 tc = float4(0.0, 0.0, 0.0,0.0);
			  if (i.uv.x<(_vx_offset-0.01))
			  {
			    tc = tex2D(_MainTex, i.uv) * weight[0];

			    for (int ii=1; ii<3; ii++) 
			    {
			      tc += tex2D(_MainTex,i.uv + float2(0.0, offset[ii])/_ScreenParams.y)  * weight[ii];
			      tc += tex2D(_MainTex, i.uv - float2(0.0, offset[ii])/_ScreenParams.y) * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv);
			  }
			  return  tc;
		}
		float4 fragBlurV(v2f i) : SV_Target
		{
 			offset[0] = 0.0;
 			offset[1] = 1.3846153846;
 			offset[2] = 3.2307692308;

 			weight[0] = 0.2270270270;
 			weight[1] = 0.3162162162;
 			weight[2] = 0.0702702703;


 			_vx_offset = 1.1;
   			float4 tc = float4(0.0, 0.0, 0.0, 0.0);
			  if (i.uv.x<(_vx_offset-0.01))
			  {
			    tc = tex2D(_MainTex, i.uv) * weight[0];

			    for (int ii=1; ii<3; ii++) 
			    {
      				tc += tex2D(_MainTex, i.uv + float2(offset[ii],0.0)/_ScreenParams.x) * weight[ii];
      				tc += tex2D(_MainTex, i.uv - float2(offset[ii],0.0)/_ScreenParams.x) * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv);
			  }
			  return  tc;
		}
		float4 fragBlend(v2f i) : SV_Target
		{
			float4 c = tex2D(_MainTex, i.uv);
			float4 cBk = tex2D(_Backup, i.uv);
			if(c.r < 1.0)
			{
			   cBk =cBk * c;

			}

			return lerp(c,cBk,_Blend);
		}

	ENDCG
	SubShader
	{
		// No culling or depth
		ZTest Off
	    Cull Off
	    ZWrite Off
	    Blend Off
	    Lighting Off
	    Fog { Mode off }




	    Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 0 White Pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragWhite
			#pragma target 3.0

			ENDCG
		}
	    Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 1 AO Pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragAO
			#pragma target 3.0

			ENDCG
		}
	    Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 2 Blur Pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragBlurH
			#pragma target 3.0

			ENDCG
		}

	    Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 2 Blur Pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragBlurV
			#pragma target 3.0

			ENDCG
		}
	Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 3 Blend Pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragBlend
			#pragma target 3.0

			ENDCG
		}

	


	}
}
