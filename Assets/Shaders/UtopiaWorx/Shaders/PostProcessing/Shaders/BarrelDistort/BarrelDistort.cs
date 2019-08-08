/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Barrel Distortion Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Barrel.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Barrel Distort")]
	public class BarrelDistort : PhotoelectricBase 
	{

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Rad|System.Single|-0.2|2.0|1|Control the radius";
			RetVal.Add(Item1);

			string Item2 = "Zoom|System.Single|0.5|2|1|How far to Zoom";
			RetVal.Add(Item2);

			//return the list to Zone
			return RetVal;
		}


		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/BarrelDistort";
		}

		public float Rad = 0.19f;
		public float Zoom = 1.2f;

		void Start()
		{
			gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.None;
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

			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				SourceMaterial.SetFloat("_Rad",Rad);
				SourceMaterial.SetFloat("_Zoom",Zoom);

				Graphics.Blit(source, destination, SourceMaterial,0);
			}

		}

	}
}
