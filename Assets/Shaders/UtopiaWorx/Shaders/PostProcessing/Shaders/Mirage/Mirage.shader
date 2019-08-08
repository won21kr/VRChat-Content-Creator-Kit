// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//This shader will approximate the effect of Mirage on a worldspace plane
//It works by considering the depth of the pixel being processed and if it is within the defined range of depth
//and it's worldspace normal direction is at an acceptable angle and below a world space Y vertex apply a UV transformation
//which will give the illusion of heat haze. 
//Finally thre is a color comparison which will look at the sampled pixel of the source UV and the sampled pixel of the UV offset
//to determine if they are within a range of acceptable color range to each other.

Shader "Custom/PostProcessing/Utopiaworx/Mirage"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Iterations("Iterations",float) = 0
		_EffectWidth("EffectWidth",float) = 0
		_NormalRange("_NormalRange",float) = 0
		_DisplaceTex("Displacement Texture", 2D) = "white" {}
		_Magnitude("Magnitude", Range(0,0.1)) = 1
		_Speed("Speed", float) = 1.0
		_MaxWorldHeight("MaxWorldHeight", float) = 1.0
		_ShowDebug("ShowDebug", int) = 0 
		_MatchWeight("MatchWeight",float) =0
	}

	SubShader 
	{
		ZTest Off
	    Cull Off
	    ZWrite Off
	    Blend Off
	    Lighting Off
	    Fog { Mode off }
		Pass {
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
			uniform sampler2D _CameraDepthNormalsTexture;
			uniform sampler2D _CameraDepthTexture;
			uniform float _Iterations;
			uniform float _EffectWidth;
			uniform float _NormalRange;
			uniform sampler2D _DisplaceTex;
			uniform float _Magnitude;
			uniform float _Speed;
			uniform float _MaxWorldHeight;
			uniform int _ShowDebug;
			uniform float _MatchWeight;

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


//************************************
//
//Fragment Function
//
//************************************
			float4 frag(v2f i) : SV_Target 
			{
				//get the main input color
				fixed4 c = tex2D(_MainTex, i.uv);

				//get the depth value from the depth buffer
				float depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);

				//create a normal color
			    float3 normalValues;

			    //create the normal depth
				float depthValueN;

				//get the normal 
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.scrPos.xy), depthValueN, normalValues);

				//creat the normal color
				fixed4 normalColor = fixed4(normalValues, 1.0);

				//set the depth value based on the Iterations value power
				depthValue = depthValue / (pow(10.0	,_Iterations));

				//if the pixel is within the viewspace UV.Y range & the normal Up direction is greater than the normal angle specified
				if(i.uv.y > (0.5 - _EffectWidth) && i.uv.y < (0.5 + _EffectWidth) && normalColor.g > _NormalRange)
				{
					//if the pixel is within the the depth range specified
					if(depthValue.r > (0.5 - _EffectWidth) && depthValue.r < (0.5 + _EffectWidth))
					{
						//if the pixel is lower than the world height
						if(i.uv.y < _MaxWorldHeight)
						{
							//if debug mode is off
							if(_ShowDebug == 0)
							{
								//get the distortion based UV
								fixed2 distuv = float2(i.uv.x + _Time.x * _Speed, (i.uv.y) + _Time.x * _Speed);

								//get the distortion pixel UV
								fixed2 disp = tex2D(_DisplaceTex, distuv).xy;

								//set the magnitude of the UV
								disp = ((disp * 2.0) - 1.0) * _Magnitude;

								//sample the color of the offset UV
								fixed4 c2 = tex2D (_MainTex, i.uv + disp);

								//get the difference between the 2 colors
								fixed3 delta = c.rgb-c2.rgb;

								//if the difference is less than the spedified tollerance
								if(dot(delta,delta) < _MatchWeight)
								{
									//return a mix of the source pixel and the augmented UV based pixel by half
									 return FixAlpha(lerp(c2, c,0.5));
								}
								else
								{
									return FixAlpha(c); 
								}
							}
							else
							{
								//show debug pixel
								return FixAlpha(fixed4(1,0,0,1));
							}
						}
						else
						{
							// retutn the main pixel color
							return FixAlpha(c); 
						}
					}
					else
					{
						// retutn the main pixel color
						return FixAlpha(c); 
					}
				}
				else
				{
					// retutn the main pixel color
					return FixAlpha(c); 
				}
			}
			ENDCG
		}
	}
	Fallback Off	
}