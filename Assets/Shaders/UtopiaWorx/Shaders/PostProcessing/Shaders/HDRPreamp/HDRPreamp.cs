/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
HDR Pramp Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/HDRPreamp.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/HDR Preamp")]
	public class HDRPreamp : PhotoelectricBase 
	{
		#region members


		public float Blend = 1.0f;
		public float Intensity = 1.2f;


		#endregion
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/HDRPreamp";
		}



		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Blend|System.Single|0.5|2.0|1|Blend Strength";
			RetVal.Add(Item1);

			string Item2 = "Intensity|System.Single|0.0|2.0|1|Intensity of the effect";
			RetVal.Add(Item2);



			//return the list to Zone
			return RetVal;
		}

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
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetFloat("_Intensity",Intensity);



				Graphics.Blit(source, destination, SourceMaterial,0);





			}

		}

	}
}