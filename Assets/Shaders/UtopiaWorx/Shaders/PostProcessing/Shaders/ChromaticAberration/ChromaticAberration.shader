// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/ChromaticAberration"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Amount("Amount",float) = 1
		_Mix("Mix",float) = 1

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
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform float4 _MainTex_TexelSize;
			uniform fixed _Amount;	
			uniform fixed _Mix;	

//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 
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
				const fixed2 texel = _MainTex_TexelSize.xy;
				fixed4 col = tex2D(_MainTex, i.uv);




				fixed colR = tex2D(_MainTex, i.uv + float2(texel.x * abs(_Amount) ,0)).r;
				fixed colG = tex2D(_MainTex, i.uv + float2(texel.x * 1.0,texel.y * (abs(_Amount) / 10.0 ))).g;
				fixed colB = tex2D(_MainTex, i.uv + float2(texel.x * (abs(_Amount) * -1.0) ,0)).b;


				return FixAlpha(lerp(col,fixed4(colR,colG,colB,1.0),_Mix));
			}
			ENDCG
		}
	}
}
