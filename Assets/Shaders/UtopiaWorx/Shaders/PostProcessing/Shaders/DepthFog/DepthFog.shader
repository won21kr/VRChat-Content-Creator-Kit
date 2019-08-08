// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/DepthFog"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
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
			uniform sampler2D _CameraDepthTexture;
			uniform float _Volume;
			uniform float _Seed;
			uniform fixed4 _Tint;

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
				fixed depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);
				fixed4 color = tex2D(_MainTex,i.uv);
				fixed4 depth = fixed4(depthValue,depthValue,depthValue,1.0);
				depth = lerp(depth,((simpleGrain(depth, i.uv, 0.5, _Seed)) / 5.0),0.5);
				fixed4 SomeC = _Tint;
				SomeC *= depth;
				return SomeC + color + (depth * _Volume);
				//return color + (depth * _Volume); 
			}
			ENDCG
		}
	}
	Fallback Off	
}