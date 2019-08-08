/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Gaussian Blur Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Gaussian.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Gaussian Blur")]
	public class GaussianBlur : PhotoelectricBase 
	{



		public int Passes = 4;
		public float Blend = 0.85f;

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/GaussianBlur";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Passes|System.Int32|0|100|1|how many passes";
			RetVal.Add(Item1);

			string Item2 = "Blend|System.Single|0.0|1.0|1|how tp blend";
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

			if(SourceMaterial == null)
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				RenderTexture RTBU = RenderTexture.GetTemporary(source.width,source.height,source.depth,source.format);
				Graphics.Blit(source,RTBU);

				RenderTexture RTT = RenderTexture.GetTemporary(source.width,source.height,source.depth,source.format);
				RenderTexture RTT2 = RenderTexture.GetTemporary(source.width,source.height,source.depth,source.format);
				for(int i = 0; i < Passes; i++)
				{
					Graphics.Blit(source, RTT, SourceMaterial,0);
					Graphics.Blit(RTT,RTT2,SourceMaterial,1);
					Graphics.Blit(RTT2,source);
				}
				RenderTexture.ReleaseTemporary(RTT);
				RenderTexture.ReleaseTemporary(RTT2);
				SourceMaterial.SetTexture("_Base_Image", RTBU);
				SourceMaterial.SetFloat("_Blend",Blend);
				Graphics.Blit(source,destination,SourceMaterial,2);
				RenderTexture.ReleaseTemporary(RTBU);

			}

		}
	}

}