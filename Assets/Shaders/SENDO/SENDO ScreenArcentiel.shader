// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Screen/Cancer Shader"
{
	Properties
	{
		_HUESpeed("HUE Speed", Range( 0 , 50)) = 1
		_HUEScale("HUE Scale", Range( 0 , 0.02)) = 0.0006
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

		uniform sampler2D _GrabTexture;
		uniform float _HUEScale;
		uniform float _HUESpeed;


		float3 HSVToRGB( float3 c )
		{
			float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
			float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
			return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
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
			float4 screenColor52 = tex2D( _GrabTexture, ase_screenPosNorm.xy );
			float mulTime83 = _Time.y * (( ase_screenPosNorm.y + 0.0 )*_HUEScale + _HUESpeed);
			float3 hsvTorgb3_g3 = HSVToRGB( float3(( screenColor52 + sin( mulTime83 ) ).r,1.0,1.0) );
			o.Emission = ( float3( 0,0,0 ) + hsvTorgb3_g3 );
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16301
361;92;1098;650;2443.853;351.3058;1.028507;True;True
Node;AmplifyShaderEditor.ScreenPosInputsNode;78;-2117.046,-197.6575;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;79;-1853.516,-181.8541;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;81;-1998.797,92.86048;Float;False;Property;_HUESpeed;HUE Speed;2;0;Create;True;0;0;False;0;1;1;0;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-2142.746,-10.07295;Float;False;Property;_HUEScale;HUE Scale;4;0;Create;True;0;0;False;0;0.0006;0;0;0.02;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;82;-1736.333,-11.56262;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;83;-1533.405,-63.76982;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;84;-1364.622,-115.5772;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;52;-1878.786,-370.8962;Float;False;Global;_GrabScreen1;Grab Screen 1;3;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;51;-1204.368,-206.3158;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;55;-1026.498,-208.8445;Float;False;Simple HUE;-1;;3;32abb5f0db087604486c2db83a2e817a;0;1;1;COLOR;0,0,0,0;False;4;FLOAT3;6;FLOAT;7;FLOAT;5;FLOAT;8
Node;AmplifyShaderEditor.RangedFloatNode;86;-2221.674,-422.8536;Float;False;Property;_Float0;Float 0;1;0;Create;True;0;0;False;0;15;1;1;50;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;89;-2101.663,-886.6104;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-756.4464,-361.0175;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;87;-2076.392,-697.5682;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-2365.623,-525.7871;Float;False;Property;_Float2;Float 2;3;0;Create;True;0;0;False;0;0.01;0;0;0.02;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;97;-1909.173,-702.1705;Float;False;Constant;_Color0;Color 0;5;0;Create;True;0;0;False;0;0,1,0.08965492,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;93;-1480.719,-716.0805;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;90;-1969.208,-525.2768;Float;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;91;-1775.282,-515.0846;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;85;-2339.923,-713.3717;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-1588.248,-566.1886;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SinOpNode;92;-1432.124,-544.6403;Float;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-554.9919,-415.1799;Float;False;True;2;Float;ASEMaterialInspector;0;0;Unlit;SENDO/Screen/Cancer/CancerColor2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;1;False;-1;7;False;-1;True;5;False;-1;20;False;-1;False;0;Custom;0.5;True;True;0;True;Overlay;;Overlay;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;79;0;78;2
WireConnection;82;0;79;0
WireConnection;82;1;80;0
WireConnection;82;2;81;0
WireConnection;83;0;82;0
WireConnection;84;0;83;0
WireConnection;52;0;78;0
WireConnection;51;0;52;0
WireConnection;51;1;84;0
WireConnection;55;1;51;0
WireConnection;89;0;85;0
WireConnection;46;1;55;6
WireConnection;87;0;85;3
WireConnection;93;0;89;0
WireConnection;90;0;87;0
WireConnection;90;1;88;0
WireConnection;90;2;86;0
WireConnection;91;0;90;0
WireConnection;96;0;97;0
WireConnection;96;1;91;0
WireConnection;92;0;96;0
WireConnection;0;2;46;0
ASEEND*/
//CHKSM=9980D5C4658538F40A79078F997E666AAF704675