// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Tonemapping"
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
//Variables;

//
//************************************
			uniform sampler2D _MainTex;
			uniform float _Gamma;

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
			//asdf;
				const float Gamma = _Gamma;
				float3 c = tex2D(_MainTex, i.uv).rgb;
				float3 mapped = c / (c + float3(1.0,1.0,1.0));
				mapped = pow(mapped, float3((1.0 / Gamma),(1.0 / Gamma),(1.0 / Gamma)) );
				return fixed4(mapped.r,mapped.g,mapped.b,1.0);
				 


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