float3 getStereoCamPos()
			{
				#if UNITY_SINGLE_PASS_STEREO
					float3 cameraPos = float3((unity_StereoWorldSpaceCameraPos[0]+ unity_StereoWorldSpaceCameraPos[1])*.5); 
				#else
					float3 cameraPos = _WorldSpaceCameraPos;
				#endif

				return cameraPos;
			}