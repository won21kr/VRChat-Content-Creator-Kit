
			VertexOutput vert(VertexInput v) {
				VertexOutput OUT;

				OUT.normal = v.normal;
				OUT.uv0 = v.uv0;
				OUT.uv1 = v.uv1;
				OUT.pos = v.vertex;
				OUT.worldPos = mul(unity_ObjectToWorld, v.vertex);
				OUT.viewDir = normalize(WorldSpaceViewDir(v.vertex));
				OUT.color = v.color;

				return OUT;
			}


float4 frag(g2f i) : COLOR{
				//holds how much to cut out the layer
				float cutout = i.multiOutput.x;

				//holds the brightness of the layer for fur
				float brightness = i.multiOutput.y;

				//holds the red vertexColor channel information for skin
				float vertColor = i.multiOutput.z;
				
				//holds which layer we're on
				float layerType = i.multiOutput.w;

				float3 worldNormal = normalize(mul(unity_ObjectToWorld, float4(i.normal, 0)));
				float3 viewDir = mul(unity_ObjectToWorld, i.viewDir);
				float vdn = dot(viewDir, worldNormal); 

				float4 lengthMask = tex2D(_lengthMask, i.uv0 * _lengthMask_ST.xy + _lengthMask_ST.zw);

				//sample with the halfway point between the 0th and 1st lod of the cutout to smoothen everything out nicely - this ensures that our fur doesn't turn into noise from far away
				//but we still get to keep the details
				float4 cutoutMap = tex2Dlod(_CutoutMap, float4(i.furUV,0,0.5));

				float4 mainTex = tex2D(_MainTex, i.uv0 * _MainTex_ST.xy + _MainTex_ST.zw) * _Color.xyzz * lerp((1-lengthMask.r) + (_Color3.xyzz * lengthMask.r), 0, layerType) ;
				
				float4 FurTexture = tex2D(_furTex, i.uv0 * _furTex_ST.xy + _furTex_ST.zw) * _Color2.xyzz;
				float4 finalTex = lerp(mainTex, FurTexture, layerType); 

				// float vDotN = dot(i.viewDir);
				float3 finalLight = CustomLightingFunction(i, viewDir, worldNormal, _RampFur, _RampSkin, layerType);
				float4 col = float4(lerp(mainTex, finalTex, brightness) * finalLight, 0);	
				float skinAlpha = 1;
				float furAlpha = (((cutoutMap * 4 * lengthMask) - cutout));

				col.a = lerp(skinAlpha, furAlpha, layerType);
				
				return col;
			}