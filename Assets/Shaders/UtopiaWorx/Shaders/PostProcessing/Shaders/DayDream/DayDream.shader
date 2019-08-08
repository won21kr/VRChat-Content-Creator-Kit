// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Dream"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_AlphaBlend ("Alpha Map",2D) = "white"{}
		_Strength ("Strength", Range(0,1)) = 0
		_Scale ("Scale",Float) = 0
		_Offset ("Offset",Float) = 0
		_Noise ("Noise",Float) = 0
		_Seed ("Seed",Float) = 0
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
			uniform sampler2D _AlphaBlend;
			uniform sampler3D _ClutTex;
			uniform fixed _Scale;
			uniform fixed _Offset;
			uniform fixed _Noise;
			uniform fixed _Seed;

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
			float4 frag(v2f i) : SV_Target 
			{
				//get the color from the input texture at the UV position
				fixed4 c = tex2D(_MainTex, i.uv);



				//get the alpha map value from the input at the UV posiion
				fixed4 alp = tex2D(_AlphaBlend,i.uv);

				c = clamp(c,0.000001,1.0);

				//set the main color to it's square root
				c.rgba = sqrt(c.rgba);

				float AlphaStrength = (clamp(alp.a /_Strength,0.0,1.0));

				//lookup the corrected color from the LUT
				fixed4 correctedColor = tex3D(_ClutTex, c.rgba * _Scale + _Offset);

				   
				correctedColor = simpleGrain(correctedColor,i.uv,_Noise + _Seed,_Seed);

				//lerp between the input color and the LUT color where the Lerp value is the Alpha blend

				c.rgba = lerp(c,correctedColor, AlphaStrength );


				 
				//return the color back to its full value
				c.rgba *= c.rgba;


   				return FixAlpha(clamp(c,0.0,1.0));

			}
			ENDCG
		}
	}
	Fallback Off	
}