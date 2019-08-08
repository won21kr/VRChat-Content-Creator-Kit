// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Vignette"
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
