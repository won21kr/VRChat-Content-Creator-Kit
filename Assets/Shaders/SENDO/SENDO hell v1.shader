// Upgrade NOTE: upgraded instancing buffer 'SENDOScreenHellv11' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Screen/Hell"
{
	Properties
	{
		_SpeedColor("Speed Color", Range( 0 , 100)) = 3
		_Grille("Grille", Range( 0 , 0)) = 0
		_GrilleSpeed("Grille Speed", Range( 0 , 0)) = 0
		_Shake("Shake", Range( 0 , 100)) = 20
		_Range("Range", Range( 10 , 300)) = 150
		_ScreenBlack("Screen Black", Float) = 0.1
		_Color("Color", Range( -10 , 50)) = 1
		_Flash("Flash", Range( -10 , 50)) = 0.8
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZTest Always
			ZWrite On
		}

		Tags{ "RenderType" = "Overlay"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		ZTest Always
		Offset  5 , 20
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 screenPos;
		};

		uniform float _SpeedColor;
		uniform float _Color;
		uniform float _Flash;
		uniform sampler2D _GrabTexture;
		uniform float _Range;
		uniform float _ScreenBlack;
		uniform float _Grille;
		uniform float _GrilleSpeed;

		UNITY_INSTANCING_BUFFER_START(SENDOScreenHellv11)
			UNITY_DEFINE_INSTANCED_PROP(float, _Shake)
#define _Shake_arr SENDOScreenHellv11
		UNITY_INSTANCING_BUFFER_END(SENDOScreenHellv11)


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
		}


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float mulTime45 = _Time.y * _SpeedColor;
			float3 hsvTorgb48 = HSVToRGB( float3(mulTime45,_Color,_Flash) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 color109 = IsGammaSpace() ? float4(0,0,0,0) : float4(0,0,0,0);
			float _Shake_Instance = UNITY_ACCESS_INSTANCED_PROP(_Shake_arr, _Shake);
			float mulTime4 = _Time.y * ( color109 + _Shake_Instance ).r;
			float4 screenColor9 = tex2D( _GrabTexture, ( ase_grabScreenPosNorm + ( sin( mulTime4 ) / _Range ) ).xy );
			float4 blendOpSrc49 = float4( hsvTorgb48 , 0.0 );
			float4 blendOpDest49 = screenColor9;
			float4 lerpResult89 = lerp( ( saturate( (( blendOpDest49 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest49 - 0.5 ) ) * ( 1.0 - blendOpSrc49 ) ) : ( 2.0 * blendOpDest49 * blendOpSrc49 ) ) )) , float4( 0,0,0,0 ) , _ScreenBlack);
			float mulTime95 = _Time.y * _GrilleSpeed;
			float temp_output_99_0 = ( 0.0 - 0.0 );
			float4 temp_cast_3 = (temp_output_99_0).xxxx;
			float4 clampResult100 = clamp( sin( ( ( _Grille * ( ase_grabScreenPosNorm + float4( 0,0,0,0 ) ) ) + mulTime95 ) ) , temp_cast_3 , float4( 1,0,0,0 ) );
			float4 temp_cast_4 = (temp_output_99_0).xxxx;
			o.Emission = ( lerpResult89 + ( (float4( 0,0,0,0 ) + (clampResult100 - temp_cast_4) * (float4( 1,0,0,0 ) - float4( 0,0,0,0 )) / (float4( 1,0,0,0 ) - temp_cast_4)) + float4( 0,0,0,0 ) ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
206;92;1433;650;2432.403;923.0287;2.145192;True;True
Node;AmplifyShaderEditor.ColorNode;109;-1823.064,-72.52853;Float;False;Constant;_Color0;Color 0;9;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;-1919.952,113.5642;Float;True;InstancedProperty;_Shake;Shake;4;0;Create;True;0;0;False;0;20;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;105;-1406.914,-656.7935;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-1606.064,57.47147;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;106;-1053.048,-541.4455;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;108;-1129.427,-666.1627;Float;False;Property;_Grille;Grille;2;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;4;-1479.952,107.5642;Float;True;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-1195.427,-429.1627;Float;False;Property;_GrilleSpeed;Grille Speed;3;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;95;-881.6572,-451.3154;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1148.455,187.019;Float;True;Property;_Range;Range;5;0;Create;True;0;0;False;0;150;0;10;300;0;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;5;-1311.258,98.09344;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;92;-852.6572,-600.3154;Float;False;2;2;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-641.6572,-544.3154;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1198.936,-311.592;Float;False;Property;_SpeedColor;Speed Color;1;0;Create;True;0;0;False;0;3;0;0;100;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-891.207,90.69205;Float;False;2;0;FLOAT;500;False;1;FLOAT;80;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;1;-1357.299,-98.60051;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SinOpNode;97;-470.6572,-541.3154;Float;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-424.6572,-317.3154;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1005.544,-76.83529;Float;False;Property;_Flash;Flash;8;0;Create;True;0;0;False;0;0.8;-1;-10;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-741.2417,17.07026;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-1010.174,-169.0305;Float;False;Property;_Color;Color;7;0;Create;True;0;0;False;0;1;1;-10;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;-888.6657,-273.6346;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;48;-648.2588,-208.8573;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ClampOpNode;100;-266.3426,-402.6639;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;9;-615.3154,4.14246;Float;False;Global;_GrabScreen0;Grab Screen 0;2;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;88;-366.0374,19.39835;Float;True;Property;_ScreenBlack;Screen Black;6;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;101;-104.9368,-325.7964;Float;False;5;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;1,0,0,0;False;3;FLOAT4;0,0,0,0;False;4;FLOAT4;1,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BlendOpsNode;49;-372.7939,-98.18287;Float;False;Overlay;True;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;89;7.48463,-89.92113;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;91.76943,-344.1287;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;41;484.7837,-142.6167;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;669.8379,-177.9769;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SENDO/Screen/Hell v1.1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;1;False;-1;7;False;-1;True;5;False;-1;20;False;-1;True;7;Custom;0.5;True;True;0;True;Overlay;;Overlay;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;110;0;109;0
WireConnection;110;1;3;0
WireConnection;106;0;105;0
WireConnection;4;0;110;0
WireConnection;95;0;107;0
WireConnection;5;0;4;0
WireConnection;92;0;108;0
WireConnection;92;1;106;0
WireConnection;96;0;92;0
WireConnection;96;1;95;0
WireConnection;6;0;5;0
WireConnection;6;1;40;0
WireConnection;97;0;96;0
WireConnection;7;0;1;0
WireConnection;7;1;6;0
WireConnection;45;0;42;0
WireConnection;48;0;45;0
WireConnection;48;1;43;0
WireConnection;48;2;44;0
WireConnection;100;0;97;0
WireConnection;100;1;99;0
WireConnection;9;0;7;0
WireConnection;101;0;100;0
WireConnection;101;1;99;0
WireConnection;49;0;48;0
WireConnection;49;1;9;0
WireConnection;89;0;49;0
WireConnection;89;2;88;0
WireConnection;103;0;101;0
WireConnection;41;0;89;0
WireConnection;41;1;103;0
WireConnection;0;2;41;0
ASEEND*/
//CHKSM=B5C9697FC5AE0848C92DE166CF26EB48EB5D17FA