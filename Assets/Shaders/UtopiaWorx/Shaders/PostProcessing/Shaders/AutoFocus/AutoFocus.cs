/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Auto Focus Shader
contact john@smarterphonelabs.com
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;


namespace Utopiaworx.Shaders.PostProcessing
{
	#if UNITY_EDITOR
	[ExecuteInEditMode]
	#endif
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/AutoFocus.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Auto Focus")]
	public class AutoFocus : PhotoelectricBase 
	{
		#region members
	
		public float Depth;
		public float Blend = 0.5f;
		public float Desaturate;
		public LayerMask MyLM = -1;
		private Camera TheCamera;
		public float DTemp = 0.0f;
		private float NowTemp = 0.0f;
		private float LastDTemp = 0.0f;
		private float Counter = 0.25f;
		public float UpdateTime =0.22f;
		public float FocusSpeed = 33.0f;
		public float Exposure = 3.68f;
		public Transform FallbackLocation;


		#endregion

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Exposure|System.Single|1.0|10.0|1|Control the exposure";
			RetVal.Add(Item1);

			string Item2 = "Blend|System.Single|0.0|1.0|1|How much to blend the color";
			RetVal.Add(Item2);

			string Item3 = "UpdateTime|System.Single|0.0|1.0|1|How often to check for changes";
			RetVal.Add(Item3);

			string Item4 = "FocusSpeed|System.Single|0.0|100.0|1|How much to blend the color";
			RetVal.Add(Item4);

			//return the list to Zone
			return RetVal;
		}

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/AutoFocus";
		}

		void Start () 
		{
			TheCamera = GetComponent<Camera>();
			//set the main camera to send depth normals
			TheCamera.depthTextureMode = DepthTextureMode.Depth;
		}
		void Update()
		{
			Counter -= Time.deltaTime;
			if(Counter <= 0.0f)
			{
				RaycastHit hit;
				if (Physics.Raycast(TheCamera.transform.position, TheCamera.transform.forward, out hit,TheCamera.farClipPlane,MyLM))
				{

					NowTemp =  hit.distance / TheCamera.farClipPlane;
					LastDTemp = NowTemp;
				}
				else
				{
					if(FallbackLocation != null)
					{
						NowTemp = Vector3.Distance(TheCamera.transform.position,FallbackLocation.position) / TheCamera.farClipPlane;
						LastDTemp = NowTemp;
					}
				}
				Counter = UpdateTime;
			}

			if(DTemp < LastDTemp)
			{
				DTemp += ((Time.deltaTime / TheCamera.farClipPlane) * FocusSpeed);
			}
			if(DTemp > LastDTemp)
			{
				DTemp -= ((Time.deltaTime / TheCamera.farClipPlane) * FocusSpeed);				
			}


		}
		[ImageEffectOpaque]

		protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
		{

			UsesHDR = true;
			UsesLinear = true;
			UsesRenderTextures = true;
			UsesDeffered = true;
			UsesSM3 = true;
			UsedDepth = true;


			//if the source material is missing
			if(SourceMaterial == null  )
			{
				//just return an empty blit
				Graphics.Blit(source, destination);
			}
			else
			{
				 

				SourceMaterial.SetFloat("_Depth", DTemp);
				SourceMaterial.SetFloat("_Blend", Blend);
				SourceMaterial.SetFloat("_Exposure",Exposure);
				SourceMaterial.SetFloat("_Seed", UnityEngine.Random.Range(0.01f,0.02f));

				RenderTexture RTT = RenderTexture.GetTemporary(source.width,source.height,source.depth,source.format);

				//do vertical
				Graphics.Blit(source, RTT, SourceMaterial,0);
				//do horizontal
				Graphics.Blit(RTT,destination,SourceMaterial,1);


				RenderTexture.ReleaseTemporary(RTT);

			}


		}
	}
}