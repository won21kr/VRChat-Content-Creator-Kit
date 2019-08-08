// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/CRT"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
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
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_TexelSize;
			uniform float _Comp_X;
			uniform float _Comp_Y;
			uniform float _Rad;
			uniform float _Zoom;
			uniform half4 vectors; 
			uniform fixed _Amount;


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
				fixed4 res = tex2D(_MainTex, i.uv);

			   float2 sine_comp = float2(_Comp_X, _Comp_Y);


			   float3 scanline = res * (0.95 + dot(sine_comp * sin(i.uv * 
			   float2(3.1415 * vectors.x * vectors.y / vectors.z, 2.0 * 3.1415 * vectors.w)
			   ), float2(1.0, 1.0)));
			   return float4(scanline.x, scanline.y, scanline.z, 1.0);
			}


			float2 barrelDistortion(float2 uv)
			{   

			    float r = uv.x*uv.x + uv.y*uv.y;
			    uv *= _Zoom + _Rad * r + _Rad * r * r;
			    return uv;
			}

			fixed4 fragCA (v2f i) : SV_Target
			{
				const fixed2 texel = _MainTex_TexelSize.xy;
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed colR = tex2D(_MainTex, i.uv + float2(texel.x * abs(_Amount) ,0)).r;
				fixed colG = tex2D(_MainTex, i.uv + float2(texel.x * 1.0,texel.y * (abs(_Amount) / 10.0 ))).g;
				fixed colB = tex2D(_MainTex, i.uv + float2(texel.x * (abs(_Amount) * -1.0) ,0)).b;


				return FixAlpha(fixed4(colR,colG,colB,1.0));
			}
			fixed4 fragWSN (v2f i) : SV_Target
			{
			    //get the UV
				half2 uv = half2(i.uv.x, i.uv.y);

			    uv = uv * 2.0 - 1.0;
			    uv = barrelDistortion(uv);
			    uv = 0.5 * (uv * 0.5 + 1.0);

				//get the color
				return  tex2D(_MainTex, uv);
			}

		ENDCG


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

			ENDCG
		}

		Pass {
			CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragCA
			#pragma target 3.0

			ENDCG
		}

		Pass {
			CGPROGRAM
//************************************
//
//Pragmas
//
//************************************
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma vertex vert
			#pragma fragment fragWSN
			#pragma target 3.0

			ENDCG
		}
	}
	Fallback Off	
}