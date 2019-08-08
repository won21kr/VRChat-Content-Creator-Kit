// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/PostProcessing/Utopiaworx/Diagnostic"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}

	}
	CGINCLUDE
	//************************************
//
//includes
//
//************************************

			#include "UnityCG.cginc" 
			#include "../../cginc/PhotoelectricShaders.cginc" 

//
//Variables
//
//************************************
			uniform sampler2D _MainTex;
			uniform sampler2D _CameraDepthNormalsTexture;
			uniform float4 _HighlightDirection;
			uniform float4x4 _CameraMV;
			uniform sampler2D _CameraGBufferTexture0;
			uniform sampler2D _CameraGBufferTexture1;
			uniform sampler2D _CameraGBufferTexture2;
			uniform sampler2D _CameraGBufferTexture3;
			uniform float _MainTex_TexelSize;
			uniform sampler2D _CameraDepthTexture;

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
			fixed4 fragWSN (v2f i) : SV_Target
			{
				float3 normalValues;
				float depthValue;
				DecodeDepthNormal(tex2D(_CameraDepthNormalsTexture, i.scrPos.xy), depthValue, normalValues);

				fixed4 col = tex2D(_MainTex, i.uv);
				float4 normalColor = float4(normalValues, 1);
				fixed normalR = sqrt(normalColor.r);
				fixed normalG = sqrt(normalColor.g);

				return normalColor;
			}

			fixed4 fragDiffuse (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture0, i.uv);
				return fixed4(col.r, col.g,col.b,1.0);
			}

			fixed4 fragOcclusion (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture0, i.uv);
				return fixed4(col.a, col.a,col.a,1.0);
			}
			fixed4 fragSpecColor (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture1, i.uv);
				return fixed4(col.r, col.g,col.b,1.0);
			}
			fixed4 fragRoughness (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture1, i.uv);
				return fixed4(col.a, col.a,col.a,1.0);
			}
			fixed4 fragEmission (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture2, i.uv);
				return fixed4(col.a, col.a,col.a,1.0);
			}
			fixed4 fragLighting (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture2, i.uv);
				return fixed4(col.r, col.r,col.r,1.0);
			}
			fixed4 fragLightMaps (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture2, i.uv);
				return fixed4(col.g, col.g,col.g,1.0);
			}
			fixed4 fragReflectionProbes (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_CameraGBufferTexture2, i.uv);
				return fixed4(col.b, col.b,col.b,1.0);
			}
			fixed4 fragDepth (v2f i) : SV_Target
			{
				const fixed2 texel = _MainTex_TexelSize;
				//get the depth value from the depth buffer
				fixed depthValue = Linear01Depth (tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.scrPos)).r);

				return fixed4(depthValue,depthValue,depthValue,1.0);
			}
	ENDCG
	SubShader
	{
		// No culling or depth
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
			#pragma fragment fragWSN
			#pragma target 3.0

			ENDCG
		}

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
			#pragma fragment fragDiffuse
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragOcclusion
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragSpecColor
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragRoughness
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragEmission
			#pragma target 3.0

			ENDCG
		}

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
			#pragma fragment fragLighting
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragLightMaps
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragReflectionProbes
			#pragma target 3.0

			ENDCG
		}
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
			#pragma fragment fragDepth
			#pragma target 3.0

			ENDCG
		}


	}
}
