/*
struct appdata_full {
	float4 vertex : POSITION;
	float4 tangent : TANGENT;
	float3 normal : NORMAL;
	float4 texcoord : TEXCOORD0;
	float4 texcoord1 : TEXCOORD1;
	fixed4 color : COLOR;
}
*/

Shader "Custom/Object Shaders/ShatterWave Shader" {

    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
        _ClipMainTexture ("Clip Main Texture", Range(-1,1)) = 1
        _Emission ("Emission", Range(0, 10)) = 0
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _EmissionMap ("EmissionMap", 2D) = "black" {}
        _WaveColor ("Wave Color", Color) = (1,1,1,1)
        _WaveEmission ("Wave Emission", Range(0, 10)) = 2
        _WaveTexture ("Wave Texture", 2D) = "white" {}
		_SpeedX ("Speed X", Float) = .5
		_SpeedY ("Speed Y", Float) = .6
		_SpeedZ ("Speed Z", Float) = .7
		_WaveSlopeX ("Wave Slope X", Float) = 2
		_WaveSlopeY ("Wave Slope Y", Float) = 2
		_WaveSlopeZ ("Wave Slope Z", Float) = 2
		_WaveDensityX ("Wave Density X", Float) = 10
		_WaveDensityY ("Wave Density Y", Float) = 8
		_WaveDensityZ ("Wave Density Z", Float) = 9
        _HeightThreshold ("WaveWidth", Range(0, 1)) = .98
        _WaveHeight ("Wave Height", Range(0,50)) = .01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"  }
        Cull off
        Pass
        {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma geometry geom

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            struct myAppData
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD;
                uint vertexId : SV_VertexID;

            };

            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                uint vertexId : TEXCOORD1;
            };
 
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR;
            };
			float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ClipMainTexture;
            sampler2D _WaveTexture;
			float4 _EmissionColor;
            sampler2D _EmissionMap;
            float _Emission;
            float _SpeedX;
            float _SpeedY;
            float _SpeedZ;
            float _WaveSlopeX;
            float _WaveSlopeY;
            float _WaveSlopeZ;
            float _WaveDensityX;
            float _WaveDensityY;
            float _WaveDensityZ;
            float _HeightThreshold;
            float4 _WaveColor;
            float _WaveEmission;
            float _WaveHeight;

            float3 LightingFunction( float3 normal )
            {
                return ShadeSH9(half4(normal, 1.0));
            }

			float random (in float3 st) 
            {
				return frac(cos(dot(st.xyz, float3(12.9898,78.233,123.691)))* 43758.5453123);
			}
           
            v2g vert (myAppData v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = v.normal;
                o.vertexId = v.vertexId;
                return o;
            }
            
            float3 WaveHeight(float3 position)
            {
                return (sin(
                    2* pow(((sin((position.x + _Time.x* _SpeedX) * _WaveDensityX + sin(_Time.y * _SpeedX))+1)/2),_WaveSlopeX) +
                    2* pow(((sin((position.y + _Time.x* _SpeedY) * _WaveDensityY + sin(_Time.y * _SpeedY))+1)/2),_WaveSlopeY) +
                    2* pow(((sin((position.z + _Time.x* _SpeedZ) * _WaveDensityZ + sin(_Time.y * _SpeedZ))+1)/2),_WaveSlopeZ)
                )+1)/2;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> tristream)
            {
				float4 mid = (IN[0].vertex+IN[1].vertex+IN[2].vertex)/3;
                float4 objectPosition = mul(unity_ObjectToWorld, float4(0, 0, 0, 1));
                float4 WavePosition = objectPosition;

				float hash = random(mid);
				//float distanceToWave = -distance(WavePosition.y, mul(unity_ObjectToWorld, mid).y);
                
                
                float distanceToWave = clamp(WaveHeight(mid.xyz), 0, 1);
                if(distanceToWave <= _HeightThreshold)
                {
                    distanceToWave = 0;
                }
                //distanceToWave += .1;
				// 0 = invisible, 1 = visible, can be outside 0-1 range.;

                float range = 1-_HeightThreshold;
				float delta = 1-distanceToWave;
				float percent = delta/range;
				//percent += 0.1 * (1+sin(_Time.y * (1+hash)/2));
				percent = saturate(percent);
				
				if(percent == 0) 
					return;

				g2f o;

				
                float3 edgeA = IN[1].vertex - IN[0].vertex;
                float3 edgeB = IN[2].vertex - IN[0].vertex;
				float3 c = cross(edgeA, edgeB); 
				float3 outDir = normalize(c);
                float3 normalDir = normalize(c);

				// Using o.pos as the delta.
				float3 over = cos(IN[1].vertex * 1234.56);
                for(int i = 0; i < 3; i++)
                {
					// First half is sliding over where it goes
					if(percent < .5) 
					{
						//over -= over.y; // * dot(normalDir, over); // Make it perpendicular to the normal
						over = normalize(over);
						// At percent = 0, position is shifted by 'over'
						// at percent = .5 position is shifted by 0.
						o.pos.xyz = (lerp(over, 0, percent*2) + normalDir) * _WaveHeight;
					} else {
						// Second half is sliding into place
						// percent = .5 should be shifted by normalDir * movement
						// percent = 1 should be shifted by 0
						o.pos.xyz = normalDir * _WaveHeight * (1-percent)*2 ;
					}

                    o.pos = UnityObjectToClipPos(IN[i].vertex+ o.pos);
                    o.uv = IN[i].uv;
                     o.col = fixed4(1,1,1,1);
                    if(distanceToWave > 0)
                    {
                        o.col.r = percent;
                    }
                    
                    tristream.Append(o);
                }
			
                tristream.RestartStrip();
            }
           
            fixed4 frag (g2f i) : SV_Target
            {
                clip(_ClipMainTexture - i.col.r);
                float attenuation = LIGHT_ATTENUATION(i) / SHADOW_ATTENUATION(i);
                float3 FlatLighting = saturate((LightingFunction( float3(0,1,0) )+(_LightColor0.rgb*attenuation)));

                fixed3 col = (tex2D(_EmissionMap, i.uv).xyz * _EmissionColor * _Emission) + (tex2D(_MainTex, i.uv).xyz * _Color.xyz * FlatLighting);
                fixed3 waveCol = tex2D(_WaveTexture, i.uv).xyz * _WaveColor.xyz * _WaveEmission;
                col.rgb = lerp(waveCol , col,  i.col.r);
                return float4(col,1);
            }
            ENDCG
        }
    }
}
