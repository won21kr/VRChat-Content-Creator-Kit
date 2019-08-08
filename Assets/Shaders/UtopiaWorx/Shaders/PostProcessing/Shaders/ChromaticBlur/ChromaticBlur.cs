/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
 Cromatic Blur Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/CromaticBlur.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Cromatic Blur")]
	public class ChromaticBlur : PhotoelectricBase 
	{
		#region members


		public float blurMax = 0.33f;
		public float aberrationMax = 1.45f;
		public int numIters = 32;

		#endregion
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/ChromaticBlur";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "blurMax|System.Single|0.0|1.0|1|How much blur to add";
			RetVal.Add(Item1);

			string Item2 = "aberrationMax|System.Single|0.0|2.0|1|How much aberration to add";
			RetVal.Add(Item2);

			string Item3 = "numIters|System.Int32|10|100|1|How many times to blur per frame";
			RetVal.Add(Item3);


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
				SourceMaterial.SetFloat("_blurMax",blurMax);
				SourceMaterial.SetFloat("_aberrationMax",aberrationMax);
				SourceMaterial.SetInt("_numIters",numIters);
				Graphics.Blit(source, destination, SourceMaterial);
			}

		}

	}
}
