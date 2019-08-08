// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Honeymooners"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Blend ("Blend",Float) = 0
		_LUTBlend ("LutBlend", float) = 0
		_Rad("Rad", float) = 0
		_Rad2("Rad2", float) = 0
		_Ghost1 ("Ghost1",2D) = "white" {}
	    _vx_offset("vx_offset", float) = 0
		_Noise ("Noise",Float) = 0
		_Seed ("Seed",Float) = 0
		_Scale ("Scale",Float) = 0
		_Offset ("Offset",Float) = 0
		_ChromaticOffset ("_ChromaticOffset", float) = 0
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
			uniform float _Rad;
			uniform float _Rad2;
			uniform fixed _Blend;
			uniform sampler2D _Ghost1;

			uniform sampler3D _ClutTex;
			uniform fixed _Scale;
			uniform fixed _Offset;

			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;
			uniform fixed _Noise;
			uniform fixed _Seed;
			uniform float _LUTBlend;
			uniform float _ChromaticOffset;


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

			float2 barrelDistortion(float2 uv)
			{   

			    float r = uv.x*uv.x + uv.y*uv.y;
			    uv *= 1.6 + _Rad2 * r + _Rad2 * r * r;
			    return uv;
			}


			fixed4 fragChromatic (v2f i) : SV_Target
			{

				 fixed2 texel = _MainTex_TexelSize ;
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed colR = tex2D(_MainTex, i.uv + float2((1.0/2048.0) * abs(_ChromaticOffset) ,0)).r;
				fixed colG = tex2D(_MainTex, i.uv).g;
				fixed colB = tex2D(_MainTex, i.uv).b;


				return fixed4(colR,colG,colB,1.0);
			}


			fixed4 fragLUT (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				fixed4 correctedColor = tex3D(_ClutTex, c.rgba * _Scale + _Offset);
				return lerp(c,correctedColor,_LUTBlend);
			}
			fixed4 fragGrain (v2f i) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, i.uv);
				return simpleGrain(color,i.uv,_Noise + _Seed,_Seed);
			}

			fixed4 fragGhost (v2f i) : SV_Target
			{
				half2 uv = half2(i.uv.x, i.uv.y);

			    uv = uv * 2.0 - 1.0;
			    uv = barrelDistortion(uv);
			    uv = 0.5 * (uv * 0.5 + 1.0);

				//get the color


				fixed4 color = tex2D(_MainTex, uv);
				fixed GM = GreyMix(color);
				return fixed4(GM,GM,GM,1.0);
			}

			fixed4 fragColorCorrection (v2f i) : SV_Target
			{
				fixed4 color =  tex2D(_MainTex, i.uv );

				fixed GM = GreyMix(color);
				fixed4 gh1 = tex2D(_Ghost1,i.uv );
				//gh1 = lerp(color,QuickBlur(half2 (0.5,0.05), i, _Ghost1),0.5);	
				gh1 = fixed4(gh1.r,gh1.g,gh1.b,1.0); 
				return lerp(fixed4(GM,GM,GM,1.0), gh1,_Blend);
			}

			fixed4 fragVignette (v2f i) : SV_Target
			{

			    //get the UV
				half2 coords = half2(i.uv.x, i.uv.y);
				//get the color
				float4 col = tex2D(_MainTex, i.uv);
				//uv minus half times 2
				coords = (coords - 0.5) * 2.0;		
				//take the dot of the 2
				half coordDot = dot (coords,coords);
				//clone the color
				half4 color = tex2D (_MainTex, i.uv);	 
				//create the mask
				float mask = 1.0 - coordDot * _Rad; 

				float3 myhsv = RGBtoHSV(color.rgb);
				myhsv.z *= (mask/2);
				float3 myrgb = HSVtoRGB(myhsv);
				fixed4 converted = fixed4(myrgb.r,myrgb.g,myrgb.b,1.0);

				return lerp(color,converted,0.75);
			}



			fixed4 fragBarrel (v2f i) : SV_Target
			{
				half2 uv = half2(i.uv.x, i.uv.y);

			    uv = uv * 2.0 - 1.0;
			    uv = barrelDistortion(uv);
			    uv = 0.5 * (uv * 0.5 + 1.0);

				//get the color
				return  tex2D(_MainTex, uv);
			}

			fixed4 fragBlurH(v2f i) : SV_Target
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

			fixed4 fragBlurV(v2f i) : SV_Target
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
      				tc += tex2D(_MainTex, i.uv + float2(0.0,offset[ii])/_ScreenParams.x).rgb * weight[ii];
      				tc += tex2D(_MainTex, i.uv - float2(0.0,offset[ii])/_ScreenParams.x).rgb * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb;
			  }
			  return  fixed4(tc, 1.0);
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
//Pragmas pass 3
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragGhost
			#pragma target 3.0

			ENDCG
		}


		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 2
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragBarrel
			#pragma target 3.0

			ENDCG
		}


		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 8
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragChromatic
			#pragma target 3.0

			ENDCG
		}


		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 0
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragColorCorrection
			#pragma target 3.0

			ENDCG
		}

		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 6
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragGrain
			#pragma target 3.0

			ENDCG
		}

		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 4
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
//Pragmas pass 5
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
//Pragmas pass 7
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragLUT
			#pragma target 3.0

			ENDCG
		}



		Pass
		{
			CGPROGRAM
//************************************
//
//Pragmas pass 1
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragVignette
			#pragma target 3.0

			ENDCG
		}













	}
}
