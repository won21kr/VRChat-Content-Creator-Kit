// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/BarrelDistort"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rad("Rad", float) = 0
		_Zoom("Zoom", float) = 1.6
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
			uniform float _Zoom;


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
    uv *= _Zoom + _Rad * r + _Rad * r * r;
    return uv;
}
			fixed4 fragWSN (v2f i) : SV_Target
			{
			    //get the UV
				half2 uv = half2(i.uv.x, i.uv.y);

    uv = uv * 2.0 - 1.0;
    uv = barrelDistortion(uv);
    uv = 0.5 * (uv * 0.5 + 1.0);

				//get the color
				return  tex2D(_MainTex, uv);




		
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
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragWSN
			#pragma target 3.0

			ENDCG
		}




	}
}
