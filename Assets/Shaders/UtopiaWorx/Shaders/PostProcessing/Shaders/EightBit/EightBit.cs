/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
8 Bit Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/EightBit.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/8 Bit")]
	public class EightBit : PhotoelectricBase 
	{


		public float pixel_h = 8.0f ; // 10.0

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/EightBit";
		}

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "pixel_h|System.Single|4.0|64.0|1|Pixel thickness";
			RetVal.Add(Item1);



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

			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{

				SourceMaterial.SetFloat("pixel_width",pixel_h * 1.5f);
				SourceMaterial.SetFloat("pixel_height",pixel_h);
				Graphics.Blit(source, destination, SourceMaterial,0);

			}

		}

	}
}
