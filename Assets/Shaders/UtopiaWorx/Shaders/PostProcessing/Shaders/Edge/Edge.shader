// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/Edge"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Weight("Weight",float) = 1
		_Width("Width",float) = 1
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

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

//************************************
//
//Variables
//
//************************************
			uniform sampler2D _MainTex; 
			uniform float _Weight;
			uniform float _Width;
			uniform float4 _MainTex_TexelSize;

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



			fixed4 frag (v2f i) : SV_Target
			{
				const float2 texel = _MainTex_TexelSize.xy;	
				fixed2 uv =i.uv;
			    fixed2 blurredUV = fixed2(uv.x+_Width,uv.y+_Width);
			    fixed4 baseColor = fixed4(tex2D(_MainTex,uv).rgb,1);
				fixed4 edges = 1.0 - (baseColor / fixed4(tex2D(_MainTex,blurredUV).rgb, 1));
				fixed4 col = tex2D(_MainTex,uv);
			    fixed4 edge = fixed4(length(edges),length(edges),length(edges),1.0);
			    edge = 1.0 - edge;
			    fixed lum = luminance(edge);
			    lum = lum * _Weight;
			    //if(lum < 0.0)
			    //{
			    	col = lerp(lerp(lerp(col, lum,0.015625),col,0.25),col,0.5);
			    	fixed4 LCol = tex2D(_MainTex,i.uv - float2(texel.x * -1.0,0));
			    	fixed4 RCol = tex2D(_MainTex,i.uv + float2(texel.x,0));
			    	col = lerp(lerp(LCol,RCol,0.5),col,0.75);
			    //}

			    return FixAlpha(col);  

			}
			ENDCG
		}
	}
}
