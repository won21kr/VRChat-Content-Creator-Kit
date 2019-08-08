float3 CustomLightingFunction(struct g2f i, float3 viewDir, float3 worldNormal, sampler2D rampSkin, sampler2D rampFur, float layerType)
{
		UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos.xyz);
	//Do direct and indirect lighting
		float light_Env = float(any(_WorldSpaceLightPos0.xyz));
		
		float3 lightDir;
		#if defined(DIRECTIONAL)
			lightDir = normalize(_WorldSpaceLightPos0.xyz);
		#else
			lightDir = normalize(_WorldSpaceLightPos0 - i.worldPos);
		#endif


		if( light_Env != 1)
		{
			//A way to get dominant light direction from Unity's Spherical Harmonics.
			lightDir = normalize(unity_SHAr.xyz + unity_SHAg.xyz + unity_SHAb.xyz);
			
				if(length(unity_SHAr.xyz*unity_SHAr.w + unity_SHAg.xyz*unity_SHAg.w + unity_SHAb.xyz*unity_SHAb.w) == 0)
				{
					lightDir = normalize(float4(1, 1, 1, 0));
				}
		}

		float nDotl = DotClamped(lightDir, worldNormal);												
		float3 lightintensity = ShadeSH9(float4(0,0,0,1));
		float2 rampUV = lerp(	nDotl * 0.5 + 0.5, 
						dot(normalize(_fakeLightDir), worldNormal),
						_fakeLight	);	

	float4 skinRamp = tex2D(_RampSkin, float2(rampUV.x, rampUV.y));
	float4 furRamp = tex2D(_RampFur, float2(rampUV.x, rampUV.y));
	float3 shadowRamp = lerp(skinRamp.xyz, furRamp.xyz, layerType); 

	float3 lightCol;
	float3 lightingRampCol;
	float3 lightingEnvCol;
	float3 lighting;

		lightCol = _LightColor0 * shadowRamp;
		lightingRampCol = lightCol + shadowRamp * lightintensity;
		lightingEnvCol = lightCol + lightintensity;

	#if defined(DIRECTIONAL)
		lighting = lerp(lightingRampCol, lightingEnvCol, _useRampColor);
	#else
		lighting = lerp(lightingRampCol, lightingEnvCol, _useRampColor) * attenuation * shadowRamp;
	#endif
	
	//Do indirect specular
	float roughness = 1-_smoothness;
	float3 reflectedDir = reflect(-viewDir, worldNormal);
	float4 indirectSpecular = (UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectedDir, roughness * UNITY_SPECCUBE_LOD_STEPS));
	float3 specular = DecodeHDR(indirectSpecular, unity_SpecCube0_HDR)* _Reflectance;

	//Emission 
		//skin  
			float3 skinEmiss = lerp(tex2D(_Emission, i.uv0 * _Emission_ST.xy + _Emission_ST.zw) * _EmissionColor, 0, layerType);
		//fur
			float3 furEmiss = lerp(tex2D(_Emission2, i.uv0 * _Emission2_ST.xy + _Emission2_ST.zw) * _EmissionColor2, 0, 1-layerType);
					
		float3 emission = skinEmiss + furEmiss;

		return lighting + lerp(0, specular, layerType) + emission;

}