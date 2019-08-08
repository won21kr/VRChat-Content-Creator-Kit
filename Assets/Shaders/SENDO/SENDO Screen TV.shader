// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Screen/Static Shader (Lines)"
{
	Properties
	{
		_Colorspeed("Color speed", Range( 0 , 1)) = 0.1
		_Float4("Float 4", Range( 1 , 50)) = 10
		_Float3("Float 3", Range( 1 , 50)) = 15
		_Light("Light", Range( -1 , 1)) = 0.2
		_color("color ", Range( -1 , 1)) = 0.3
		_Float2("Float 2", Range( 0 , 0.02)) = 0.01
		_Float5("Float 5", Range( -1 , 20)) = 7.520073
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Overlay"  "Queue" = "Overlay+0" "IsEmissive" = "true"  }
		Cull Off
		ZWrite On
		ZTest Always
		Offset  5 , 20
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float4 screenPos;
		};

		uniform float _Float2;
		uniform float _Float3;
		uniform float _Float5;
		uniform float _Float4;
		uniform sampler2D _GrabTexture;
		uniform float _Colorspeed;
		uniform float _Light;
		uniform float _color;


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
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float mulTime130 = _Time.y * (( ase_screenPosNorm.y + 0.0 )*_Float2 + _Float3);
			float temp_output_131_0 = sin( mulTime130 );
			float temp_output_45_0 = ( temp_output_131_0 + 0.0 );
			float mulTime108 = _Time.y * (ase_screenPosNorm.y*_Float5 + _Float4);
			float3 hsvTorgb37 = HSVToRGB( float3(temp_output_45_0,temp_output_45_0,sin( mulTime108 )) );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 screenColor42 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ase_grabScreenPos ) );
			float4 blendOpSrc44 = float4( hsvTorgb37 , 0.0 );
			float4 blendOpDest44 = ( screenColor42 + float4( 0,0,0,0 ) );
			float mulTime138 = _Time.y * _Colorspeed;
			float3 hsvTorgb139 = HSVToRGB( float3(mulTime138,_Light,_color) );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor140 = tex2D( _GrabTexture, ase_grabScreenPosNorm.xy );
			float4 blendOpSrc141 = float4( hsvTorgb139 , 0.0 );
			float4 blendOpDest141 = screenColor140;
			o.Emission = ( ( saturate( (( blendOpDest44 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest44 - 0.5 ) ) * ( 1.0 - blendOpSrc44 ) ) : ( 2.0 * blendOpDest44 * blendOpSrc44 ) ) )) + ( saturate( (( blendOpDest141 > 0.5 ) ? ( 1.0 - ( 1.0 - 2.0 * ( blendOpDest141 - 0.5 ) ) * ( 1.0 - blendOpSrc141 ) ) : ( 2.0 * blendOpDest141 * blendOpSrc141 ) ) )) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
206;92;1433;650;2750.958;1605.598;1.3;True;True
Node;AmplifyShaderEditor.ScreenPosInputsNode;128;-2446.321,-581.1639;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;132;-2182.79,-565.3604;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;126;-2456.399,-410.7646;Float;False;Property;_Float2;Float 2;6;0;Create;True;0;0;False;0;0.01;0;0;0.02;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;127;-2477.569,-320.7469;Float;False;Property;_Float3;Float 3;3;0;Create;True;0;0;False;0;15;1;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;106;-2062.201,-957.3616;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;103;-2159.751,-683.9446;Float;False;Property;_Float4;Float 4;2;0;Create;True;0;0;False;0;10;1;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2138.581,-773.9623;Float;False;Property;_Float5;Float 5;7;0;Create;True;0;0;False;0;7.520073;0;-1;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;129;-2090.454,-419.2626;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;130;-1853.802,-406.043;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;107;-1842.734,-778.6713;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;108;-1615.554,-769.2407;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;131;-1618.41,-478.0462;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-2129.838,-1261.471;Float;False;Property;_Colorspeed;Color speed;1;0;Create;True;0;0;False;0;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;137;-2086.332,-1421.252;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;138;-1869.534,-1258.623;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;42;-1663.032,-971.4078;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1340.949,-564.4136;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;104;-1403.022,-783.3182;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-2126.077,-1189.129;Float;False;Property;_Light;Light;4;0;Create;True;0;0;False;0;0.2;1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;135;-2129.55,-1117.189;Float;False;Property;_color;color ;5;0;Create;True;0;0;False;0;0.3;-1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode;37;-1137.268,-605.8612;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;133;-1011.742,-752.2012;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.HSVToRGBNode;139;-1866.973,-1194.291;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScreenColorNode;140;-1870.177,-1421.409;Float;False;Global;_GrabScreen1;Grab Screen 1;0;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendOpsNode;141;-1109.359,-926.9297;Float;False;Overlay;True;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;44;-874.6601,-711.9103;Float;False;Overlay;True;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-584.4374,-773.5577;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-370.5377,-665.764;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SENDO/Screen/TV;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;1;False;-1;7;False;-1;True;5;False;-1;20;False;-1;False;0;Custom;0.5;True;True;0;True;Overlay;;Overlay;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;132;0;128;2
WireConnection;129;0;132;0
WireConnection;129;1;126;0
WireConnection;129;2;127;0
WireConnection;130;0;129;0
WireConnection;107;0;106;2
WireConnection;107;1;105;0
WireConnection;107;2;103;0
WireConnection;108;0;107;0
WireConnection;131;0;130;0
WireConnection;138;0;134;0
WireConnection;45;0;131;0
WireConnection;104;0;108;0
WireConnection;37;0;45;0
WireConnection;37;1;45;0
WireConnection;37;2;104;0
WireConnection;133;0;42;0
WireConnection;139;0;138;0
WireConnection;139;1;136;0
WireConnection;139;2;135;0
WireConnection;140;0;137;0
WireConnection;141;0;139;0
WireConnection;141;1;140;0
WireConnection;44;0;37;0
WireConnection;44;1;133;0
WireConnection;46;0;44;0
WireConnection;46;1;141;0
WireConnection;0;2;46;0
ASEEND*/
//CHKSM=E4EB02A7DAE7A97F6726B22FD41FE46EBF87D344