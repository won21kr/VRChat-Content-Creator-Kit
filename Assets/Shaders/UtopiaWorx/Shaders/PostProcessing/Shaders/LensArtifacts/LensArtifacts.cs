/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Diagnostic Shaders
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/LensArtifacts.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Lens Artifacts")]
	public class LensArtifacts : PhotoelectricBase 
	{


		public float Volume = 0.53f;
		public float Seed;
		public Texture2D LensTexture;
		public float Boost = 1.3f;


				
	
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/LensArtifacts";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Volume|System.Single|0.0|1.0|1|Amount of effect";
			RetVal.Add(Item1);





			//return the list to Zone
			return RetVal;
		}


		void Start()
		{
			gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
			//Camera.main.depthTextureMode = DepthTextureMode.DepthNormals;
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

			gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
			SourceMaterial.SetFloat("_Volume",Volume);
			SourceMaterial.SetFloat("_Boost",Boost);
			SourceMaterial.SetTexture("_LensTexture",LensTexture);
			SourceMaterial.SetFloat("_Seed",Random.Range(0.0f,100.0f));

			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{

				Graphics.Blit(source, destination, SourceMaterial);

			}

		}

	}
}
