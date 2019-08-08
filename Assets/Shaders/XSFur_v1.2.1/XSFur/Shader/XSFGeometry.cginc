[maxvertexcount(40)]
void geom(triangle VertexInput IN[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> tristream)
{
	g2f o;
	float3 edgeA = IN[1].vertex - IN[0].vertex;
    float3 edgeB = IN[2].vertex - IN[0].vertex;
    float3 faceNormal = normalize(cross(edgeB, edgeA));
    float3 averagedPos = normalize((IN[0].vertex + IN[1].vertex + IN[2].vertex) / 3);
	float3 vCrossN = cross(averagedPos, faceNormal);

	float3 cameraPos = getStereoCamPos();

    float3 viewDir = (vCrossN - mul(unity_WorldToObject, float4(cameraPos, 1)));

	float3 dist = distance( mul(unity_ObjectToWorld, float4(0,0,0,1)).xyz, 
											cameraPos);
	half falloff = saturate((dist - 5) / (8 - 5)) * _layers;

	float2 averageUV = (IN[0].uv0 + IN[1].uv0 + IN[2].uv0) / 3;
	float4 lengthMask = tex2Dlod(_lengthMask, float4(averageUV, 0, 0));

	//These Values will get scaled with Distance for lodding.
		float layers = clamp((_layers - falloff), 2, _layers);
		//after scaling layers with distance, we also use the length mask to get rid of unneed layers
		layers = clamp(layers*lengthMask.r, 1, _layers);		
	//-------

	float offset = _offset;
	float4 uv = float4(_CutoutMap_ST);
	float2 uvLayerOffset = float2(0,0); 
	float cutout = 0;
	float brightness = 0;
	float vertexColorR = IN[0].color.r;

	float3 gravityDir = mul(unity_WorldToObject,float4(0,-1,0,0)) * _gravity * _offset;

	for (int l = 0; l < layers; l++){
		
		
		offset += _offset;
		float x = saturate(float(l)/ float(_layers * 2));
		cutout += _Cutout * (l/layers) * 4;

		brightness = (l/layers);
		brightness = lerp(1, brightness, _furOcclusionStrength);
		
		uvLayerOffset += float2(_x/10,_y/10);

	//For some reason, an if statement inside of a for loop is more performant. 
	// ?????????????????????????????????????????????????????????????????????
		//Do first Layer - the skin
		if (l == 0){
			for (int i = 0; i < 3; i++)
			{
				o.pos = UnityObjectToClipPos(IN[i].vertex);
				o.worldPos = IN[i].worldPos;
				o.uv0 = IN[i].uv0;
				o.uv1 =  IN[i].uv1;
				o.furUV = IN[i].uv0;
				o.normal = IN[i].normal;
				o.viewDir = viewDir;
				o.multiOutput = float4(0, 1, lengthMask.r, 0);
				tristream.Append(o);	
			}
			tristream.RestartStrip();
		}
		else{
			//Do other layers - fur
			for (int i = 0; i < 3; i++)
			{

				o.pos = UnityObjectToClipPos(IN[i].vertex + normalize(IN[i].normal.xyz) * offset + l * gravityDir);
				o.worldPos = IN[i].worldPos;
				o.uv0 = IN[i].uv0;
				o.uv1 =  IN[i].uv1;
				o.furUV = lerp(IN[i].uv0, IN[i].uv1, _UVSet) * float2(_density.xx) + uvLayerOffset;
				o.normal = IN[i].normal;
				o.viewDir = viewDir;
				o.multiOutput = float4(cutout, brightness, vertexColorR, 1);

				tristream.Append(o);	
			}		
			tristream.RestartStrip();
		}					
	}
}