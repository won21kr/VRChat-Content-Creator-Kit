// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Shader that will auto focus to the mearest thing in the field of view
Shader "Custom/PostProcessing/Utopiaworx/ColorMixer"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Blend ("Blend",float) = 0

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
			uniform float4 _MainTex_TexelSize;
			uniform float _Blend;



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

			float Round3(float v)
			{
				if(v == 0.5)
				{
					return v;
				}
				if(v < 0.5)
				{
					if(v < 0.25)
					{
						if(v < 0.125)
						{
							v = 0.0;
							return v;
						}
						else
						{
							v= 0.125;
							return v;
						}
					}
					else
					{
						if(v < 0.375)
						{
							v = 0.25;
							return v;
						}
						else
						{
							v = 0.375;
							return v;
						}
					}
				}
				else
				{
					if(v > 0.75)
					{
						if(v > 0.875)
						{
							v = 1.0;
							return v;
						}
						else
						{
							v = 0.875;
							return v;
						}
					}
					else
					{
						if( v > 0.625)
						{
							v = 0.75;
							return v;
						}
						else
						{
							v= 0.625;
							return v;
						}
					}
				}
			}
//************************************
//
//Fragment Function
//
//************************************
			fixed4 frag (v2f i) : SV_Target
			{
					const fixed2 texel = _MainTex_TexelSize.xy;
			     	fixed4 c = tex2D(_MainTex, i.uv);
			     	fixed4 col = tex2D(_MainTex, i.uv);
			     	float theS = sin((texel.x * (_Time.w)*1000))*0.25;
			     	float theC = cos((texel.x * (_Time.w)*1000))*0.25;

			     	float theSV = sin((texel.y * (_Time.w)*1000))*0.25;
			     	float theCV = cos((texel.y * (_Time.w)*1000))*0.25;


			     	float2 uv1 = i.uv - float2(theS,0);
			     	float2 uv2 = i.uv - float2(theC,0);

			     	if(uv1.x > 1.0)
			     	{
			     		uv1.x =  1.0 - ((uv1.x - 1.0) + (uv1.x - 1.0));
			     	}

			     	if(uv1.x < 0.0)
			     	{
			     		uv1.x = abs(uv1.x);
			     	}

			     	if(uv2.x > 1.0)
			     	{
			     		uv2.x =  1.0 - ((uv2.x - 1.0) + (uv2.x - 1.0));
			     	}

			     	if(uv2.x < 0.0)
			     	{
			     		uv2.x = abs(uv2.x);
			     	}




			     	if(uv1.y > 1.0)
			     	{
			     		uv1.y =  1.0 - ((uv1.y - 1.0) + (uv1.y - 1.0));
			     	}

			     	if(uv1.y < 0.0)
			     	{
			     		uv1.y = abs(uv1.y);
			     	}

			     	if(uv2.y > 1.0)
			     	{
			     		uv2.y =  1.0 - ((uv2.y - 1.0) + (uv2.y - 1.0));
			     	}

			     	if(uv2.y < 0.0)
			     	{
			     		uv2.y = abs(uv2.y);
			     	}




			     	fixed4 colL = tex2D(_MainTex, uv1);
			     	fixed4 colR = tex2D(_MainTex, uv2);



//col.r = Round3(col.r);
col.g = 0.0; //Round3(col.g);
col.b = 0.0; //Round3(col.b);
col.a = 1.0;

colL.r = 0.0; //Round3(colL.g);
//colL.g = Round3(colL.g) * theC;
colL.b = 0.0; //Round3(colL.r);
colL.a = 1.0;

colR.r = 0.0; //Round3(colR.b);
colR.g = 0.0; //Round3(colR.r);
//colR.b = Round3(colR.b) * theS;
colR.a = 1.0;






			     	return FixAlpha(lerp(col,Exclusion(colR,colL),_Blend));

	

			}

			ENDCG
		}
	}
}
