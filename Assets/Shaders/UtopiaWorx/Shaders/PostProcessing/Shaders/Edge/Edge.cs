/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Edge Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Edge.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Edge Shadows")]
	public class Edge : PhotoelectricBase 
	{
		#region members


		public float Weight = 0.5f;
		public float Width = 0.003f;




		#endregion
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Edge";
		}

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Weight|System.Single|0.001|0.009|1|Weight of the effect";
			RetVal.Add(Item1);

			string Item2 = "Width|System.Single|0.1|10.0|1|Width of the effect";
			RetVal.Add(Item2);

			//return the list to Zone
			return RetVal;
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
			if(SourceMaterial == null)
			{
				
				//just return an empty blit
				Graphics.Blit(source, destination);
			}
			else
			{
				SourceMaterial.SetFloat("_Weight",Weight);
				SourceMaterial.SetFloat("_Width",Width);
				Graphics.Blit(source, destination, SourceMaterial);
			}

		}

	}

}