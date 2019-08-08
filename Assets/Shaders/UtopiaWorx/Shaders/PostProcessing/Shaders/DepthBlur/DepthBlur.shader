// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Simple Depth Blur Shader Program
Shader "Custom/PostProcessing/Utopiaworx/SimpleDepthBlur"
{
	Properties
	{
	_MainTex ("Texture", 2D) = "white" {}
        radius ("radius", Range(0,30)) =0
        resolution ("resolution", float) = 800 
        _Iterations ("Iterations", float) = 0 
        _Seed("Seed",float) = 0
        _Blend("Blend",float) =0
        _Desaturate("Desaturate",float) =0
	}
	SubShader
	{
		ZTest Off
	    Cull Off
	    ZWrite Off
	    Blend SrcAlpha OneMinusSrcAlpha 
	    Lighting Off
	    Fog { Mode off }

		Pass
		{
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
			uniform float radius;
			uniform float resolution;
			uniform float _Iterations;
			uniform float4 _MainTex_TexelSize;
			uniform fixed _Seed;
			uniform fixed _Blend;
			uniform fixed _Desaturate;

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
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				const fixed2 texel = _MainTex_TexelSize.xy;

				//get the depth value from the depth buffer
				fixed depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);

				//set the depth value based on the Iterations value power
				depthValue = depthValue / (pow(5.0,_Iterations));

				if(depthValue > 0.0 && depthValue < 0.5 )
				{
					return col;
				}
				else
				{


               fixed4 sum = fixed4(0.0, 0.0, 0.0, 1.0);
                fixed2 tc = i.uv;

                //blur radius in pixels
                fixed blur = radius/resolution/4; 


                fixed hstep = 0.5;
                fixed vstep = 0.5;

                sum += tex2D(_MainTex, fixed2(tc.x - 4.0*blur*hstep, tc.y - 4.0*blur*vstep)) * 0.0162162162;
                sum += tex2D(_MainTex, fixed2(tc.x - 3.0*blur*hstep, tc.y - 3.0*blur*vstep)) * 0.0540540541;
                sum += tex2D(_MainTex, fixed2(tc.x - 2.0*blur*hstep, tc.y - 2.0*blur*vstep)) * 0.1216216216;
                sum += tex2D(_MainTex, fixed2(tc.x - 1.0*blur*hstep, tc.y - 1.0*blur*vstep)) * 0.1945945946;

                sum += tex2D(_MainTex, fixed2(tc.x, tc.y)) * 0.2270270270;

                sum += tex2D(_MainTex, fixed2(tc.x + 1.0*blur*hstep, tc.y + 1.0*blur*vstep)) * 0.1945945946;
                sum += tex2D(_MainTex, fixed2(tc.x + 2.0*blur*hstep, tc.y + 2.0*blur*vstep)) * 0.1216216216;
                sum += tex2D(_MainTex, fixed2(tc.x + 3.0*blur*hstep, tc.y + 3.0*blur*vstep)) * 0.0540540541;
                sum += tex2D(_MainTex, fixed2(tc.x + 4.0*blur*hstep, tc.y + 4.0*blur*vstep)) * 0.0162162162;

                sum = clamp(sum,0.0,1.0);

                if(_Desaturate > 0.0)
                {
                	fixed gs = GreyMix(sum);
                	sum = lerp(sum,fixed4(gs,gs,gs,1.0),_Desaturate);
                }

                  

				//get the difference between the 2 colors
				fixed3 delta = col.rgb-sum.rgb;

				//if the difference is less than the spedified tollerance
				if(dot(delta,delta) < 0.25)
				{
					col = simpleGrain(col,i.uv,0.2 + _Seed,_Seed);
					fixed4 bl = clamp(lerp(col,fixed4(sum.rgb, 1),_Blend),0.0,1.0);
					//bl = clamp(bl,(bl * fixed4(0.3, 0.3,0.3,1.0)),0.5);
					return FixAlpha(bl); 
				}
				else
				{
					return FixAlpha(col); 
				}


				}
			}
			ENDCG
		}
	}
}
