// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/MotionBlur"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
	}
		CGINCLUDE

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
			uniform float4 _MainTex_TexelSize;
			uniform sampler2D _blur1;
			uniform sampler2D _blur2;
			uniform sampler2D _blur3;
			uniform sampler2D _blur4;
			uniform float _Blend;
			uniform int _Steps;



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
				fixed4 cBU = c;
				if(_Steps ==1)
				{
					fixed4 b1 = tex2D(_blur1, i.uv);
					c = lerp(c,b1,0.5);
				}

				if(_Steps ==2)
				{
					fixed4 b1 = tex2D(_blur1, i.uv);
					fixed4 b2 = tex2D(_blur2, i.uv);

					c = lerp(c,b1,0.5);
					c = lerp(c,b2,0.4);

				}


				if(_Steps ==3)
				{
					fixed4 b1 = tex2D(_blur1, i.uv);
					fixed4 b2 = tex2D(_blur2, i.uv);
					fixed4 b3 = tex2D(_blur3, i.uv);

					c = lerp(c,b1,0.5);
					c = lerp(c,b2,0.4);
					c = lerp(c,b3,0.3);
				}


				if(_Steps ==4)
				{
					fixed4 b1 = tex2D(_blur1, i.uv);
					fixed4 b2 = tex2D(_blur2, i.uv);
					fixed4 b3 = tex2D(_blur3, i.uv);
					fixed4 b4 = tex2D(_blur4, i.uv);


					c = lerp(c,b1,0.5);
					c = lerp(c,b2,0.4);
					c = lerp(c,b3,0.3);
					c = lerp(c,b4,0.2);
				}



				return lerp(cBU,c,_Blend);

			}





		ENDCG


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

			ENDCG
		}


	}
	Fallback Off	
}