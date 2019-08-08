// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/ColorCorrection"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Scale ("Scale",Float) = 0
		_Offset ("Offset",Float) = 0
		_Noise ("Noise",Float) = 0
		_Seed ("Seed",Float) = 0
		_HueBlend ("Hue", float) = 0
		_SaturationBlend ("Saturation", float) = 0
		_VibranceBlend ("Vibrance", float) = 0
		_RedBlend ("red Blend", float) = 0
		_GreenBlend ("green Blend", float) = 0
		_BlueBlend ("blue Blend", float) = 0
		_MixMode ("MixMode", int) = 0
		_MasterMix ("MasterMix", float) =0
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
			uniform fixed _Strength;
			uniform sampler3D _ClutTex;
			uniform fixed _Scale;
			uniform fixed _Offset;
			uniform float _RedBlend;
			uniform float _GreenBlend;
			uniform float _BlueBlend;

			uniform float _HueBlend;
			uniform float _SaturationBlend;
			uniform float _VibranceBlend;

			uniform int _MixMode;

			uniform float _MasterMix;


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
				//lookup the corrected color from the LUT
				fixed4 correctedColor = tex3D(_ClutTex, c.rgba * _Scale + _Offset);

				if(_MixMode == 1)
				{
					float3 CC_HSV = RGBtoHSV(correctedColor.rgb);
					float3 C_HSV = RGBtoHSV(c.rgb);

					float HBelnd = 	lerp(C_HSV.x,CC_HSV.x,_HueBlend);
					float SBelnd = 	lerp(C_HSV.y,CC_HSV.y,_SaturationBlend);
					float VBelnd = 	lerp(C_HSV.z,CC_HSV.z,_VibranceBlend);
					float3 newCol = HSVtoRGB(float3(HBelnd, SBelnd,VBelnd));
				 	float4 Master =  FixAlpha(clamp(fixed4(newCol.r,newCol.g,newCol.b,1.0),0.0,1.0));
				 	return lerp(c,Master,_MasterMix);
				}
				else if(_MixMode ==2)
				{
					float RBlend = 	lerp(c.r,correctedColor.r,_RedBlend);
					float GBlend = 	lerp(c.g,correctedColor.g,_GreenBlend);
					float BBlend = 	lerp(c.b,correctedColor.b,_BlueBlend);
	   				float4 Master =  FixAlpha(clamp(fixed4(RBlend,GBlend,BBlend,1.0),0.0,1.0));
	   				return lerp(c,Master,_MasterMix);
				}
				else
				{
					float4 Master = FixAlpha(correctedColor);
					return lerp(c,Master,_MasterMix);
				}




			}
			ENDCG
		}
	}
	Fallback Off	
}