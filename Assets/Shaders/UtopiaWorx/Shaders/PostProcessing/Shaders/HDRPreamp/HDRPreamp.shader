// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will excite the HDR system
Shader "Custom/PostProcessing/Utopiaworx/HDRPreamp"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Blend ("Blend",float) = 0
		_Intensity ("Intensity", float) = 0

	}
	CGINCLUDE
//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 


//************************************
//
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform float _Blend;
			uniform float _Intensity;


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
			float4 fragDarkness (v2f i) : SV_Target
			{

				float4 color = tex2D(_MainTex,i.uv);
				const float blurSize = 1.0/2048.0;
				const float fourx = 4.0 * blurSize;
				const float onex = blurSize;
				const float twox = 2.0 * blurSize;
				float intensity = _Blend;
				const float twentyfive = 0.0025 * _Intensity;
				const float seventyfive = 0.075 * _Intensity;
				const float fourtyfive = 0.045 * _Intensity;
				const float six = 0.06 * _Intensity;

				float4 sum = float4(0,0,0,1.0);

				sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + fourx)) * twentyfive; //0,4
				sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y - fourx)) * twentyfive; //0,-4

				sum += tex2D(_MainTex, float2(i.uv.x + fourx, i.uv.y )) * twentyfive; // 4,0
				sum += tex2D(_MainTex, float2(i.uv.x - fourx, i.uv.y )) * twentyfive; //-4,0


				sum += tex2D(_MainTex, float2(i.uv.x - onex, i.uv.y + onex)) * seventyfive; //-1,1
				sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + onex)) * seventyfive; // 0,1
				sum += tex2D(_MainTex, float2(i.uv.x, i.uv.y + twox)) * fourtyfive; // 0,2
				sum += tex2D(_MainTex, float2(i.uv.x +onex, i.uv.y + onex)) * seventyfive; //1,1


				sum += tex2D(_MainTex, float2(i.uv.x - twox, i.uv.y )) * fourtyfive; // -2,0
				sum += tex2D(_MainTex, float2(i.uv.x - onex, i.uv.y )) * seventyfive; // -1,0
				sum += tex2D(_MainTex, float2(i.uv.x , i.uv.y )) * six; // 0,0
				sum += tex2D(_MainTex, float2(i.uv.x + onex, i.uv.y )) * seventyfive; // 1,0
				sum += tex2D(_MainTex, float2(i.uv.x + twox, i.uv.y )) * fourtyfive; // 2,0


				sum += tex2D(_MainTex, float2(i.uv.x - onex, i.uv.y - onex)) * seventyfive; // -1,-1
				sum += tex2D(_MainTex, float2(i.uv.x , i.uv.y - onex)) * seventyfive; // 0,-1
				sum += tex2D(_MainTex, float2(i.uv.x , i.uv.y - twox)) * fourtyfive; // 0 -2
				sum += tex2D(_MainTex, float2(i.uv.x + onex, i.uv.y - onex)) * seventyfive; // 1,-1

				sum = (sum * intensity) + (tex2D(_MainTex, i.uv) / 2.0); 

				float4 ret =  lerp((sum * sqrt(sum)),color,0.0);
				return FixAlpha(ret);

	
			
			}
	ENDCG
	SubShader
	{
		  ZTest Always Cull Off ZWrite Off
		Pass
		{ 
		name "Darkness"
			CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragDarkness
			#pragma target 3.0

			ENDCG
		}









	}
}
