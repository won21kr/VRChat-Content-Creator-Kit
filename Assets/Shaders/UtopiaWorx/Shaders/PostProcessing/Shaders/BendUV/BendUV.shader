// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/BendUV"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BendTex ("BendTex", 2D) = "white" {}
		_Volume("Volume",float) = 1
		_Scale("Scale",float) = 1
		_Speed("Scale",float) = 1
		_Blend ("Blend", float) = 0

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
			uniform sampler2D _BendTex;
			uniform float4 _MainTex_TexelSize;
			uniform fixed _Volume;	
			uniform fixed _Scale;	
			uniform fixed _Speed;	
			uniform fixed _Blend;

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

float2 BendUV(float2 uv, float2 nUV)
{

    
    
    nUV.x += (_Time.y)*_Speed;
    nUV.y += (_Time.x)*_Speed;
    float2 noise = tex2D( _BendTex, nUV*_Scale).xy;
    
    uv += (-1.0+noise*2.0) * _Volume;
    
    return uv;
}

			fixed4 frag (v2f i) : SV_Target
			{
		



		float2 BackupUV = i.uv;
					
    float2 nUV = i.uv;

    
    
	i.uv = BendUV(i.uv, nUV);
    i.uv = BendUV(i.uv, float2(nUV.x+0.10,nUV.y+0.10));
    fixed4 colR = tex2D(_MainTex, i.uv).r;

    i.uv = BendUV(i.uv, float2(nUV.x-0.10,nUV.y-0.10));
    fixed4 colG = tex2D(_MainTex, i.uv).g;

    i.uv = BendUV(i.uv, float2(nUV.x+0.20,nUV.y+0.20));
    fixed4 colB = tex2D(_MainTex, i.uv).b;




    				fixed4 col = tex2D(_MainTex, BackupUV);
    				return lerp(fixed4(colR.r, colG.g,colB.b,1.0),col,_Blend);

			}
			ENDCG
		}
	}
}
