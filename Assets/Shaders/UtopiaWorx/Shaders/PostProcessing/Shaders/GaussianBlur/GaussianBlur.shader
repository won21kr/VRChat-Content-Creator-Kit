// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	   _vx_offset("vx_offset", float) = 0

 

	}
SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
		//Name "Vertical Pass"
		CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

//************************************
//
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform float4 _MainTex_TexelSize;
			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;


//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 

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

				//set the screen position for the depth texture
				o.scrPos = ComputeScreenPos(o.vertex);

				//set the UV coordinate
				o.uv = v.texcoord.xy;

				//return the object
				return o;
			} 



			fixed4 frag (v2f i) : SV_Target
			{
 			offset[0] = 0.0;
 			offset[1] = 1.3846153846;
 			offset[2] = 3.2307692308;

 			weight[0] = 0.2270270270;
 			weight[1] = 0.3162162162;
 			weight[2] = 0.0702702703;


 			_vx_offset = 1.1;
   			float3 tc = float3(0.0, 0.0, 0.0);
			  if (i.uv.x<(_vx_offset-0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb * weight[0];

			    for (int ii=1; ii<3; ii++) 
			    {
			      tc += tex2D(_MainTex,i.uv + float2(0.0, offset[ii])/_ScreenParams.y).rgb  * weight[ii];
			      tc += tex2D(_MainTex, i.uv - float2(0.0, offset[ii])/_ScreenParams.y).rgb * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb;
			  }
			  return  fixed4(tc, 1.0);
			}
			ENDCG
		}

Pass
		{
		//Name "Horizontal Pass"
		CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

//************************************
//
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform float4 _MainTex_TexelSize;
			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;


//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 

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

				//set the screen position for the depth texture
				o.scrPos = ComputeScreenPos(o.vertex);

				//set the UV coordinate
				o.uv = v.texcoord.xy;

				//return the object
				return o;
			} 



			fixed4 frag (v2f i) : SV_Target
			{
 			offset[0] = 0.0;
 			offset[1] = 1.3846153846;
 			offset[2] = 3.2307692308;

 			weight[0] = 0.2270270270;
 			weight[1] = 0.3162162162;
 			weight[2] = 0.0702702703;


 			_vx_offset = 1.1;
   			float3 tc = float3(0.0, 0.0, 0.0);
			  if (i.uv.x<(_vx_offset-0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb * weight[0];

			    for (int ii=1; ii<3; ii++) 
			    {
      				tc += tex2D(_MainTex, i.uv + float2(offset[ii],0.0)/_ScreenParams.x).rgb * weight[ii];
      				tc += tex2D(_MainTex, i.uv - float2(offset[ii],0.0)/_ScreenParams.x).rgb * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb;
			  }
			  return  fixed4(tc, 1.0);
			}
			ENDCG
		}

Pass
		{
		//Name "Horizontal Pass"
		CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

//************************************
//
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform sampler2D _Base_Image;
			uniform float _Blend;



//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 

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

				//set the screen position for the depth texture
				o.scrPos = ComputeScreenPos(o.vertex);

				//set the UV coordinate
				o.uv = v.texcoord.xy;

				//return the object
				return o;
			} 



			fixed4 frag (v2f i) : SV_Target
			{
				float4 Base = tex2D(_Base_Image,i.uv);
				float4 Blur = tex2D(_MainTex,i.uv);

			  return lerp(Base,Blur,_Blend);  
			}
			ENDCG
		}
	}
}
