/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Vignette Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Vignette.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Vignette")]
	public class Vignette : PhotoelectricBase 
	{


		public float Rad = 0.72f;

		void Start()
		{
			Camera.main.depthTextureMode = DepthTextureMode.None;
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Rad|System.Single|0.0|1.0|1|Radius of Vignette";
			RetVal.Add(Item1);

			//return the list to Zone
			return RetVal;
		}

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Vignette";
		}
		[ImageEffectOpaque]
		protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			UsesHDR = true;
			UsesLinear = true;
			UsesRenderTextures = true;
			UsesDeffered = true;
			UsesSM3 = true;
			UsedDepth = false;

			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				SourceMaterial.SetFloat("_Rad",Rad);
				Graphics.Blit(source, destination, SourceMaterial,0);

			}

		}

	}
}
