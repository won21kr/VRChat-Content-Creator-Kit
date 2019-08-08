// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/AutoFocus"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Depth ("Depth",float) =0
        _Seed("Seed",float) = 0
        _Blend("Blend",float) =0
        _Exposure("Exposure",float) =0

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
			#pragma glsl

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
			uniform fixed _Depth;
			uniform sampler2D _CameraDepthTexture;
			uniform fixed _Seed;
			uniform fixed _Blend;
			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;
			uniform float _Exposure;

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


				//get the depth value from the depth buffer
				fixed depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);



				if((depthValue - 0.002) > (_Depth + 0.0002) || depthValue < (_Depth - 0.002) )
				{
					

				//fixed4 c = QuickBlur(_RadSamp,i, _MainTex);

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

			  fixed4 c = fixed4(tc.r,tc.g,tc.b,1.0);

                    fixed4 bloom = fixed4(tc.r,tc.g,tc.b,1.0);

                    c.rgb = pow(bloom.rgba, _Exposure);
                    c.rgb *= bloom;
                    c.rgb += bloom;

					col = simpleGrain(col,i.uv,0.2 + _Seed,_Seed);
					fixed4 bl = clamp(lerp(col,c,_Blend),0.0,1.0);


					return FixAlpha(bl); 

				}
				else
				{
					return FixAlpha(col); 
				}
			}

	    	ENDCG

	    }

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
			#pragma glsl

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
			uniform fixed _Depth;
			uniform sampler2D _CameraDepthTexture;
			uniform fixed _Seed;
			uniform fixed _Blend;
			uniform float offset[3];
			uniform float weight[3];
			uniform float _vx_offset;
			uniform float _Exposure;

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


				//get the depth value from the depth buffer
				fixed depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);



				if((depthValue - 0.002) > (_Depth + 0.0002) || depthValue < (_Depth - 0.002) )
				{
					

				//fixed4 c = QuickBlur(_RadSamp,i, _MainTex);

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
			      tc += tex2D(_MainTex,i.uv + float2(offset[ii],0.0)/_ScreenParams.x).rgb  * weight[ii];
			      tc += tex2D(_MainTex, i.uv - float2(offset[ii],0.0)/_ScreenParams.x).rgb * weight[ii];
			    }

			  }
			  else if (i.uv.x>=(_vx_offset+0.01))
			  {
			    tc = tex2D(_MainTex, i.uv).rgb;
			  }

			  fixed4 c = fixed4(tc.r,tc.g,tc.b,1.0);

                    fixed4 bloom = fixed4(tc.r,tc.g,tc.b,1.0);

                    c.rgb = pow(bloom.rgba, _Exposure);
                    c.rgb *= bloom;
                    c.rgb += bloom;


					col = simpleGrain(col,i.uv,0.2 + _Seed,_Seed);
					fixed4 bl = clamp(lerp(col,c,_Blend),0.0,1.0);


					return FixAlpha(bl); 

				}
				else
				{
					return FixAlpha(col); 
				}
			}

	    	ENDCG

	    }
		
	}
}
