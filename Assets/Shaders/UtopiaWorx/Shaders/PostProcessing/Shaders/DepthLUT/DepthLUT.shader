// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/DepthLUT"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Scale ("Scale",Float) = 0
		_Offset ("Offset",Float) = 0
		_Noise ("Noise",Float) = 0
		_Seed ("Seed",Float) = 0
		_Iterations("Iterations",int) = 0
		_Near("Near",int) =0
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
			uniform fixed _Strength;
			uniform sampler3D _ClutTex;
			uniform fixed _Scale;
			uniform fixed _Offset;
			uniform fixed _Noise;
			uniform fixed _Seed;
			uniform sampler2D _CameraDepthTexture;
			uniform int _Iterations;
			uniform int _Near;

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
				//get the color from the input texture at the UV position
				fixed4 c = tex2D(_MainTex, i.uv);

				//float4 depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
				float4 depthValue = Linear01Depth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
				for(int j =0; j< _Iterations;j++)
				{
					depthValue = clamp((sqrt(depthValue)/0.95),0.0,1.0);

				}


				c = clamp(c,0.000001,1.0);

				//set the main color to it's square root
				c.rgba = sqrt(c.rgba);

				//lookup the corrected color from the LUT
				fixed4 correctedColor = tex3D(_ClutTex, c.rgba * _Scale + _Offset);
				correctedColor = simpleGrain(correctedColor,i.uv,_Noise + _Seed,_Seed);

				if(_Near == 0)
				{
					c.rgba = lerp(c,correctedColor, depthValue );
				}
				else
				{
					c.rgba = lerp(correctedColor,c, depthValue );
				}

				 
				//return the color back to its full value
				c.rgba *= c.rgba;


   				return FixAlpha(clamp(c,0.0,1.0));

			}
			ENDCG
		}
	}
	Fallback Off	
}