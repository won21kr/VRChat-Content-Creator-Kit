// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/EightBit"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Rad("Rad", float) = 0
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


uniform float pixel_width; // 15.0
uniform float pixel_height; // 10.0


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
			fixed4 fragWSN (v2f i) : SV_Target
			{

  float ScrenWidth = _ScreenParams.x *2;
  float ScreenHeight = _ScreenParams.y *2;
  float3 tc = float3(1.0, 0.0, 0.0);

    float dx = pixel_width*(1./ScrenWidth);
    float dy = pixel_height*(1./ScreenHeight);
    float2 coord = float2(dx*floor(i.uv.x/dx), dy*floor(i.uv.y/dy));
    tc = tex2D(_MainTex, coord).rgb;

	return float4(tc, 1.0);

		
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
