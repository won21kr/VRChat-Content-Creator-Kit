// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/Object Shaders/Fire Shader"
{
	Properties
	{
		_FresnelPower("Fresnel Power", Range( 0 , 5)) = 2
		[HideInInspector]_FresnelScale("Fresnel Scale", Range( 0 , 0.3)) = 1.5
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 13.5
		_FresnelBias("Fresnel Bias", Range( 0 , 0.2)) = 0.2364706
		[HDR]_Flamecolor2("Flame color 2", Color) = (1,0,0,0)
		[HDR]_FlameColor("Flame Color", Color) = (1,0.8068966,0,0)
		_Y_Mask("Y_Mask", Range( 0 , 5)) = 0
		_FlameHeight("Flame Height", Range( 0 , 1)) = 0
		_Flamenoise("Flame noise", 2D) = "white" {}
		_FlameWave("Flame Wave", 2D) = "white" {}
		_v("v", Range( -1 , 1)) = 0
		_u("u", Range( -1 , 1)) = 0
		_Alpha("Alpha", Range( 0 , 1)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+100" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Front
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf Standard alpha:fade keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap vertex:vertexDataFunc tessellate:tessFunction 
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
		};

		uniform sampler2D _FlameWave;
		uniform float _u;
		uniform float _v;
		uniform sampler2D _Flamenoise;
		uniform float4 _Flamenoise_ST;
		uniform float _Y_Mask;
		uniform float _FlameHeight;
		uniform float4 _Flamecolor2;
		uniform float4 _FlameColor;
		uniform float _FresnelBias;
		uniform float _FresnelScale;
		uniform float _FresnelPower;
		uniform float _Alpha;
		uniform float _EdgeLength;

		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float4 transform17 = mul(unity_WorldToObject,float4( float3(0,1,0) , 0.0 ));
			float4 appendResult29 = (float4(_u , _v , 0.0 , 0.0));
			float2 uv_Flamenoise = v.texcoord.xy * _Flamenoise_ST.xy + _Flamenoise_ST.zw;
			float2 panner24 = ( 1.0 * _Time.y * appendResult29.xy + uv_Flamenoise);
			float4 lerpResult23 = lerp( float4( 0,0,0,0 ) , transform17 , ( tex2Dlod( _FlameWave, float4( panner24, 0, 0.0) ) * tex2Dlod( _Flamenoise, float4( panner24, 0, 0.0) ) ).r);
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float clampResult12 = clamp( ( distance( ase_worldNormal.y , _Y_Mask ) - _Y_Mask ) , 0.0 , 1.0 );
			float temp_output_14_0 = ( 1.0 - clampResult12 );
			float4 lerpResult18 = lerp( float4( 0,0,0,0 ) , lerpResult23 , temp_output_14_0);
			v.vertex.xyz += ( lerpResult18 * _FlameHeight ).xyz;
			float3 ase_vertexNormal = v.normal.xyz;
			v.normal = ase_vertexNormal;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = i.worldNormal;
			float fresnelNDotV1 = dot( normalize( ase_worldNormal ), ase_worldViewDir );
			float fresnelNode1 = ( _FresnelBias + _FresnelScale * pow( 1.0 - fresnelNDotV1, _FresnelPower ) );
			float4 lerpResult7 = lerp( _Flamecolor2 , _FlameColor , fresnelNode1);
			float4 temp_cast_0 = (0.0).xxxx;
			float4 temp_cast_1 = (5.0).xxxx;
			float4 clampResult31 = clamp( lerpResult7 , temp_cast_0 , temp_cast_1 );
			o.Emission = clampResult31.rgb;
			float clampResult12 = clamp( ( distance( ase_worldNormal.y , _Y_Mask ) - _Y_Mask ) , 0.0 , 1.0 );
			float temp_output_14_0 = ( 1.0 - clampResult12 );
			float lerpResult35 = lerp( 0.0 , ( fresnelNode1 * temp_output_14_0 ) , _Alpha);
			o.Alpha = lerpResult35;
		}

		ENDCG
	}
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15301
381;92;1235;655;-166.599;1254.738;1.261458;True;True
Node;AmplifyShaderEditor.RangedFloatNode;27;1600.378,-43.48143;Float;False;Property;_v;v;15;0;Create;True;0;0;False;0;0;0.2;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;1596.496,-121.6257;Float;False;Property;_u;u;16;0;Create;True;0;0;False;0;0;-0.23;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;8;153.4688,-60.86494;Float;True;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;29;1852.359,53.15722;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;9;162.6843,293.8361;Float;False;Property;_Y_Mask;Y_Mask;10;0;Create;True;0;0;False;0;0;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;25;1415.807,29.60971;Float;False;0;22;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;24;1513.309,159.1272;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;10;454.9435,98.99673;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;22;1903.177,405.5273;Float;True;Property;_Flamenoise;Flame noise;12;0;Create;True;0;0;False;0;None;16c4c1f35e2771646943e26f7c5479e4;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;1535.301,420.0704;Float;True;Property;_FlameWave;Flame Wave;14;0;Create;True;0;0;False;0;None;e0fd6a4930877cf46b85cf41927c84db;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector3Node;16;667.9654,1011.149;Float;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;527.6835,301.6296;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;17;903.8168,1040.52;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;30;2036.29,700.0778;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;12;494.2401,528.3492;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-564.5,-118.5;Float;False;Property;_FresnelScale;Fresnel Scale;1;1;[HideInInspector];Create;True;0;0;False;0;1.5;0.068;0;0.3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-599.5,-22.5;Float;False;Property;_FresnelPower;Fresnel Power;0;0;Create;True;0;0;False;0;2;5;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;2;-602.5,50.5;Float;False;Property;_FresnelBias;Fresnel Bias;7;0;Create;True;0;0;False;0;0.2364706;0;0;0.2;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;14;718.8393,708.61;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;23;1702.964,1089.14;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;6;-400.5,388.5;Float;False;Property;_Flamecolor2;Flame color 2;8;1;[HDR];Create;True;0;0;False;0;1,0,0,0;4.376952,0,0,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-368.5,217.5;Float;False;Property;_FlameColor;Flame Color;9;1;[HDR];Create;True;0;0;False;0;1,0.8068966,0,0;4.243004,0.7900756,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FresnelNode;1;-220.4357,33.09632;Float;True;Tangent;4;0;FLOAT3;0,0,1;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;837.6491,440.4743;Float;False;Property;_Alpha;Alpha;17;0;Create;True;0;0;False;0;0;0.39;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;957.2208,-229.0979;Float;False;Constant;_Float1;Float 1;11;1;[HideInInspector];Create;True;0;0;False;0;0;0;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;719.3638,500.8314;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;1035.361,-100.584;Float;False;Constant;_Float0;Float 0;11;1;[HideInInspector];Create;True;0;0;False;0;5;0;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;7;-0.3349533,505.3345;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;18;1205.065,800.4697;Float;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;19;1310.959,969.3138;Float;False;Property;_FlameHeight;Flame Height;11;0;Create;True;0;0;False;0;0;0.13;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;31;973.6744,-712.118;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0.9926471,0.9926471,0.9926471,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;20;1382.959,695.3138;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.NormalVertexDataNode;15;993.6229,725.9518;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;38;1319.534,-336.865;Float;False;Property;_Tesselation;Tesselation;13;0;Create;True;0;0;False;0;0;200;10;200;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;35;843.6491,296.4743;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.EdgeLengthTessNode;37;1341.534,-482.865;Float;False;1;0;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1184.371,-942.3387;Float;False;True;6;Float;ASEMaterialInspector;0;0;Standard;Rollthered/Fire;False;False;False;False;True;True;True;True;True;False;False;False;False;False;True;False;False;False;False;False;Front;0;False;-1;0;False;-1;False;0;0;False;0;Transparent;0.5;True;False;100;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;13.5;10;25;False;0.51;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;-1;False;-1;-1;False;-1;1;False;1;0,0,0,0;VertexScale;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;2;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;26;0
WireConnection;29;1;27;0
WireConnection;24;0;25;0
WireConnection;24;2;29;0
WireConnection;10;0;8;2
WireConnection;10;1;9;0
WireConnection;22;1;24;0
WireConnection;21;1;24;0
WireConnection;11;0;10;0
WireConnection;11;1;9;0
WireConnection;17;0;16;0
WireConnection;30;0;21;0
WireConnection;30;1;22;0
WireConnection;12;0;11;0
WireConnection;14;0;12;0
WireConnection;23;1;17;0
WireConnection;23;2;30;0
WireConnection;1;1;2;0
WireConnection;1;2;3;0
WireConnection;1;3;4;0
WireConnection;13;0;1;0
WireConnection;13;1;14;0
WireConnection;7;0;6;0
WireConnection;7;1;5;0
WireConnection;7;2;1;0
WireConnection;18;1;23;0
WireConnection;18;2;14;0
WireConnection;31;0;7;0
WireConnection;31;1;34;0
WireConnection;31;2;33;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;35;1;13;0
WireConnection;35;2;36;0
WireConnection;37;0;38;0
WireConnection;0;2;31;0
WireConnection;0;9;35;0
WireConnection;0;11;20;0
WireConnection;0;12;15;0
ASEEND*/
//CHKSM=158A77AAC581DA9C857F035B1B057B50988F1A80