// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/LensArtifacts"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_LensTexture ("Base (RGB)", 2D) = "white" {}
		_Volume ("Volume",float) = 0

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
			uniform float _Volume;
			uniform float _Seed;
			uniform sampler2D _LensTexture;
			uniform float4 _MainTex_TexelSize;
			uniform float _Boost;

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
				const fixed2 texel = _MainTex_TexelSize.xy;
				float4 color = tex2D(_MainTex,i.uv);
				float4 dirt = tex2D(_LensTexture,i.uv);
				dirt *= _Boost;
				float3 HSV =  HSVtoRGB(float3(dirt.r,dirt.g,dirt.b));
				fixed colR = tex2D(_LensTexture, i.uv + float2(texel.x * abs(HSV.z * 30) ,0)).r;
				fixed colG = tex2D(_LensTexture, i.uv + float2(texel.x * 1.0,texel.y * (abs(HSV.z* 30) / 10.0 ))).g;
				fixed colB = tex2D(_LensTexture, i.uv + float2(texel.x * (abs(HSV.z* 30) * -1.0) ,0)).b;

				return color + (float4(colR,colG,colB,1.0) * (_Volume * HSV.x)); 
			}
			ENDCG
		}
	}
	Fallback Off	
}