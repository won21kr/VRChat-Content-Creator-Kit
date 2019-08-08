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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Diagnostic.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Diagnostic Shaders")]
	public class Diagnostic : PhotoelectricBase 
	{


		public int Mode = 0;

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Diagnostic";
		}

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Mode|System.Int32|0|9|1|Which diagnostic mode";
			RetVal.Add(Item1);




			//return the list to Zone
			return RetVal;
		}

		void Start()
		{
			gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
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

			gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
			Matrix4x4 MV = gameObject.GetComponent<Camera>().cameraToWorldMatrix;
			SourceMaterial.SetMatrix("_CameraMV", MV);
			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{

					Graphics.Blit(source, destination, SourceMaterial,Mode);
	
			}

		}

	}
}
