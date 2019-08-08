/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Color Mixer Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/ColorMixer.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Color Mixer")]
	public class ColorMixer : PhotoelectricBase 
	{
		#region members


		public float Blend = 0.5f;

		#endregion


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Blend|System.Single|0.0|1.0|1|How much mix to add";
			RetVal.Add(Item1);



			//return the list to Zone
			return RetVal;
		}

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/ColorMixer";
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

				//RenderTexture RTT = RenderTexture.GetTemporary(source.width/4,source.height/4,source.depth,source.format);
				SourceMaterial.SetFloat("_Blend",Blend);
				Graphics.Blit(source, destination, SourceMaterial);
				//Graphics.Blit(RTT,destination);
				//RenderTexture.ReleaseTemporary(RTT);

			}

		}

	}
}