// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Ghost"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Blend ("Blend",Float) = 0
		_Ghost1 ("Ghost1",2D) = "white" {}
		_FrameID("FrameID", float) =0
		_BlendMode ("BlendMode", int) =0

	}
	SubShader
	{
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
			uniform sampler2D _Ghost1;
			uniform fixed _FrameID;
			uniform fixed _Blend;
			uniform int _BlendMode;

				
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
				//get the main color
				fixed4 col = tex2D(_MainTex, i.uv);

				//get the ghost color
				fixed4 gh1 = tex2D(_Ghost1,i.uv );

				gh1 = lerp(gh1,QuickBlur(half2 (0.5,0.05), i, _Ghost1),0.25);

				//pick the blending mode and mix the ghost colors accordingly

				//no effect
				if(_BlendMode == 0)
				{
					gh1 = fixed4(col.r,col.g,col.b,1.0); 
				}

				//red pixel only
				if(_BlendMode == 1)
				{
					gh1 = fixed4(gh1.r,col.g,col.b,1.0); 
				}

				//green pixel only
				if(_BlendMode == 2)
				{
					gh1 = fixed4(col.r,gh1.g,col.b,1.0); 
				}

				//blue pixel only
				if(_BlendMode == 3)
				{
					gh1 = fixed4(col.r,col.g,gh1.b,1.0); 
				}

				//all pixels
				if(_BlendMode == 4)
				{
					gh1 = fixed4(gh1.r,gh1.g,gh1.b,1.0); 
				}

				//Gree and blue
				if(_BlendMode == 5)
				{
					gh1 = fixed4(col.r,gh1.g,gh1.b,1.0); 
				}

				//red and blue
				if(_BlendMode == 6)
				{
					gh1 = fixed4(gh1.r,col.g,gh1.b,1.0); 
				}
				//red and green
				if(_BlendMode == 7)
				{
					gh1 = fixed4(gh1.r,gh1.g,col.b,1.0); 
				}



				//return the lerp blend based on the client lerp factor
				return FixAlpha(lerp(col,gh1,clamp((_Blend),0.0,0.999)));



			}
			ENDCG
		}
	}
}
