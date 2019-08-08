// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

//Created by John Rossitter of UtopiaWorx 2016
//john@smarterphonelabs.com
//A Bloom shader based on downsamples,and gausian blur
Shader "Custom/PostProcessing/Utopiaworx/Bloom"
{
	Properties
	{
		_BlewmStrength("BlewmStrength", float) =0
		_MainTex ("Texture", 2D) = "white" {}
		_BloomPass1 ("BloomPass1", 2D) = "black" {}
		_BloomPass2 ("BloomPass2", 2D) = "black" {}
		_BloomPass3 ("BloomPass3", 2D) = "black" {}
		_BloomPass4 ("BloomPass4", 2D) = "black" {}
		_BloomPass5 ("BloomPass5", 2D) = "black" {}
		_BloomPass6 ("BloomPass6", 2D) = "black" {}
		_texelStrength ("texelStrength", float) = 1024
		_Noise ("Noise",float) = 0.25
		_Seed ("Seed", float) = 0.25
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
//Variables
//
//************************************
			uniform float _BlewmStrength;
			uniform sampler2D _MainTex; 
			uniform sampler2D _CameraGBufferTexture1;
			uniform float4 _MainTex_TexelSize;
			uniform sampler2D _BloomPass1;
			uniform sampler2D _BloomPass2;
			uniform sampler2D _BloomPass3;
			uniform sampler2D _BloomPass4;
			uniform sampler2D _BloomPass5;
			uniform sampler2D _BloomPass6;
			uniform float _texelStrength;
			uniform float _Noise;
			uniform float _Seed;



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

            v2f_DS vertDS(appdata_img v)
			{

				//declare a return value
				v2f_DS o;

 				//set the Vertex position
				o.pos = UnityObjectToClipPos(v.vertex);

				//set the UV coordinate
				o.uv0 = half4(v.texcoord.xy + _MainTex_TexelSize.xy, 0.0, 0.0);				
				o.uv1 = half4(v.texcoord.xy + _MainTex_TexelSize.xy * half2(-0.5,-0.5), 0.0, 0.0);	
				o.uv2 = half4(v.texcoord.xy + _MainTex_TexelSize.xy * half2(0.5,-0.5), 0.0, 0.0);
				o.uv3 = half4(v.texcoord.xy + _MainTex_TexelSize.xy * half2(-0.5,0.5), 0.0, 0.0);

				//return the object
				return o;
			} 


//************************************
//
//Fragment Function
//
//************************************
			//bloom shader
			float4 fragBloom (v2f i) : SV_Target
			{
				float4 colorMain = tex2D(_MainTex,i.uv);
				float4 c = tex2D(_MainTex,i.uv);
				c += (tex2D(_BloomPass1,i.uv) * 0.5);
				c += (tex2D(_BloomPass2,i.uv) * 0.7);
				c += (tex2D(_BloomPass3,i.uv) * 0.6);
				c += (tex2D(_BloomPass4,i.uv) * 0.45);
				c += (tex2D(_BloomPass5,i.uv) * 0.35);
				c += (tex2D(_BloomPass6,i.uv) * 0.23);
				c /= 1.1;

				return lerp(colorMain,c,_BlewmStrength);
			}
			//vertical blur shader
			float4 fragVert (v2f i) : SV_Target
			{
				const fixed2 texel = fixed2(1.0/_texelStrength, 1.0/_texelStrength);
				float4 color = tex2D(_MainTex,i.uv + float2(texel.x * -3.0,0)) * curve4[0];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -2.0,0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -1.0,0)) * curve4[2];
				color += tex2D(_MainTex,i.uv) * curve4[3];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 1.0,0)) * curve4[2];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 2.0,0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 3.0,0)) * curve4[0];
				return color;
			}
			//horizontal blur
			float4 fragHoriz (v2f i) : SV_Target
			{
				const fixed2 texel = fixed2(1.0/_texelStrength, 1.0/_texelStrength);
				float4 color = tex2D(_MainTex,i.uv + float2(0,texel.y * -3.0)) * curve4[0];
				color += tex2D(_MainTex,i.uv + float2(0,texel.y * -2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(0,texel.y * -1.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv) * curve4[3];
				color += tex2D(_MainTex,i.uv + float2(0,texel.y * 1.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv + float2(0,texel.y * 2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(0,texel.y * 3.0)) * curve4[0];
				return color;   
			}
			//diag 1 blur shader
			float4 fragDiag1 (v2f i) : SV_Target
			{
				const fixed2 texel = fixed2(1.0/_texelStrength, 1.0/_texelStrength);
				float4 color = tex2D(_MainTex,i.uv + float2(texel.x * -1.0,texel.y * -1.0)) * curve4[0];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -2.0,texel.y * -2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -3.0,texel.y * -3.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv) * curve4[3];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 1.0,texel.y * 1.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 2.0,texel.y * 2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 3.0,texel.y * 3.0)) * curve4[0];
				return color;
			}
			//diag 2 blur shader
			float4 fragDiag2 (v2f i) : SV_Target
			{
				const fixed2 texel = fixed2(1.0/_texelStrength, 1.0/_texelStrength);
				float4 color = tex2D(_MainTex,i.uv + float2(texel.x * -1.0,texel.y * 1.0)) * curve4[0];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -2.0,texel.y * 2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * -3.0,texel.y * 3.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv) * curve4[3];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 1.0,texel.y * -1.0)) * curve4[2];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 2.0,texel.y * -2.0)) * curve4[1];
				color += tex2D(_MainTex,i.uv + float2(texel.x * 3.0,texel.y * -3.0)) * curve4[0];
				return color;
			}
			// add some grain to the shader
			float4 fragGrain (v2f i) : SV_Target
			{
				float4 colorOrig = tex2D (_MainTex, i.uv);
				float4 c = tex2D (_MainTex, i.uv);
				c = simpleGrain(c,i.uv,_Noise + _Seed,_Seed);
				return lerp(c,colorOrig,0.75);
			}

			//downsample fragment shader
			float4 fragDS ( v2f_DS i ) : SV_Target
			{				
				float4 c = tex2D (_MainTex, i.uv0);
				c += tex2D (_MainTex, i.uv1);
				c += tex2D (_MainTex, i.uv2);
				c += tex2D (_MainTex, i.uv3);
				return max(c/4, 0);
			}
	ENDCG

	SubShader
	{
		  ZTest Always Cull Off ZWrite Off
		Pass
		{ 
		name "Blewm"
			CGPROGRAM
//************************************
//
//Pragmas the final bloom pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragBloom
			#pragma target 3.0

			ENDCG
		}


		Pass
		{ 
		name "Downsample"
			CGPROGRAM
//************************************
//
//Pragmas the downsample pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vertDS
			#pragma fragment fragDS
			#pragma target 3.0

			ENDCG
		}

		Pass
		{ 
		name "Vert"
			CGPROGRAM
//************************************
//
//Pragmas the vertical pass for the gaussian
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragVert
			#pragma target 3.0

			ENDCG
		}

		Pass
		{ 
		name "Horiz"
			CGPROGRAM
//************************************
//
//Pragmas the horizontal pass for the gaussian blur
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragHoriz
			#pragma target 3.0

			ENDCG
		}

		Pass
		{ 
		name "Diag1"
			CGPROGRAM
//************************************
//
//Pragmas the  1st diagonal pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragDiag1
			#pragma target 3.0

			ENDCG
		}

		Pass
		{ 
		name "Diag2"
			CGPROGRAM
//************************************
//
//Pragmas the 2nd diagonal pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragDiag2
			#pragma target 3.0

			ENDCG
		}
		Pass
		{ 
		name "Grain Pass"
			CGPROGRAM
//************************************
//
//Pragmas the grain pass
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragGrain
			#pragma target 3.0

			ENDCG
		}
	}
}
