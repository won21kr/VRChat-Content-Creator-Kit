// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/ChromaticBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_blurMax("blurMax", float) = 0.2
		_aberrationMax("aberrationMax",float) = 1.2
		_numIters("numIters", int) =51
	}
	SubShader
	{
		  ZTest Always Cull Off ZWrite Off
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
		uniform fixed _blurMax;
		uniform fixed _aberrationMax;
		uniform int _numIters;


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

			float weightedColour(float colour, float os, float mid) 
			{
			    //return 0.2;
			    return colour * 1.0 * (mid - abs(mid-float(os)))/mid;
			}
//************************************
//
//Fragment Function
//
//************************************
			fixed4 frag (v2f i) : SV_Target
			{
 

    float blur = -_blurMax * 0.5;
	float aberration = 1.0 + (_aberrationMax * 0.5);

	int channelspread = int(float(_numIters) / aberration);
	float mid = float(channelspread+1)/2.0;

    float3 lobound = float3(_numIters-channelspread,(_numIters-channelspread)/2,0.0);
    float3 hibound = float3(_numIters,(_numIters+channelspread)/2,channelspread);

	float2 uv = i.uv;

    
	float2 centre = float2(0.5,0.5);
    uv -= centre; 

    float4 colour = float4(0.0,0.0,0.0,1.0);

	float blurPerIter = blur / float(_numIters-1); 
    for(int i = 0; i < _numIters; i++) {
        float scale = 1.0 + (blurPerIter * float(i));
        float4 txColour = tex2D(_MainTex, centre + (uv * scale));
       
        float3 kk = float3(i+1,i+1,i+1) - lobound;
      
        if (i>=lobound.x && i<hibound.x) 
        {
            colour.r += weightedColour(txColour.r,kk.r,mid);
        } 
        if (i>=lobound.y && i<hibound.y) {
            colour.g += weightedColour(txColour.g,kk.g,mid);
        }
        if (i>=lobound.z && i<hibound.z) {
            colour.b += weightedColour(txColour.b,kk.b,mid);
        }
    }
    
    
		return FixAlpha(colour / (0.5*float(channelspread+1)));
			}
//************************************
//
//Other Functions
//
//************************************


			ENDCG
		}
	}
}







    



