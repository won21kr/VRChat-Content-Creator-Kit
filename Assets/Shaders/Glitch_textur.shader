Shader "Four_DJ/Glitch textur"
{
	Properties
	{
		[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex ("Texture", 2D) = "white" {}
		_Glitch ("Glitch", Range(0, 1.001)) = 0
		_Transparency("Transparency", float) = 1
	}
	SubShader
	{
		Tags { "Queue" = "Overlay+28767"
			"RenderType"="TransparentCutout+28767"  
			"PreviewType"="Plane+28767"   
			"IgnoreProjector"="True"  
            "DisableBatching"="LODFading"
            "CanUseSpriteAtlas"="True"
			"QUEUE" = "Transparent+10000"  }
		LOD 200
		Cull [_Cull]
        ZTest [_ZTest]
		Blend SrcAlpha OneMinusSrcAlpha
		Pass
		{
		Tags { 
			"LIGHTMODE" = "FORWARDBASE"
			"QUEUE" = "Transparent+10000"
			"RenderType" = "TransparentCutout" 
			"SHADOWSUPPORT" = "true"  
		}
			Cull [_Cull]
            ZTest [_ZTest]
            Lighting Off
			Stencil
            {
                Ref 901 Comp NotEqual Pass keep
            }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
				float4 screenCoord : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Glitch;
			float _Transparency;
			float4 _Color;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				 
				float s = sin(_Time.y * 12.);
				float l = _Glitch;
	
				float r = tex2D(_MainTex, i.uv).x;
				float g = tex2D(_MainTex, i.uv + fixed2(l*s,0.)).y;
				float b = tex2D(_MainTex, i.uv - fixed2(0.,l*s)).z;
				
				fixed4 col = fixed4(r,g,b,1.)*_Color;
				col.a = _Transparency;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
