/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Depth LUT Shader
contact john@smarterphonelabs.com
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;

namespace Utopiaworx.Shaders.PostProcessing
{

	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/MotionBlur.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/MotionBlur")]
	public class MotionBlur : PhotoelectricBase {



		public RenderTexture blur1;
		public RenderTexture blur2;
		public RenderTexture blur3;
		public RenderTexture blur4;
		public RenderTexture blur5;


		public int Steps = 1;
		public float Blend = 1.0f;

		private int FrameCount =0;

	
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/MotionBlur";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Blend|System.Single|0.0|1.0|1|how much effect";
			RetVal.Add(Item1);

			//return the list to Zone
			return RetVal;
		}



		void Start () 
		{
			GetComponent<Camera>().depthTextureMode = DepthTextureMode.None;
			FrameCount = 0;
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

			switch(Steps)
			{
			case 1:
				SourceMaterial.SetTexture("_blur1",blur1);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetInt("_Steps",Steps);



				Graphics.Blit(source, destination, SourceMaterial,0);
				Graphics.Blit(destination,blur5);


				blur1 = blur5;


				break;

			case 2:
				SourceMaterial.SetTexture("_blur1",blur1);
				SourceMaterial.SetTexture("_blur2",blur2);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetInt("_Steps",Steps);



				Graphics.Blit(source, destination, SourceMaterial,0);
				Graphics.Blit(destination,blur5);


				blur1 = blur2;
				blur2 = blur5;

				break;

			case 3:
				SourceMaterial.SetTexture("_blur1",blur1);
				SourceMaterial.SetTexture("_blur2",blur2);
				SourceMaterial.SetTexture("_blur3",blur3);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetInt("_Steps",Steps);



				Graphics.Blit(source, destination, SourceMaterial,0);
				Graphics.Blit(destination,blur5);


				blur1 = blur2;
				blur2 = blur3;
				blur3 = blur5;
				break;

			case 4:
				SourceMaterial.SetTexture("_blur1",blur1);
				SourceMaterial.SetTexture("_blur2",blur2);
				SourceMaterial.SetTexture("_blur3",blur3);
				SourceMaterial.SetTexture("_blur4",blur4);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetInt("_Steps",Steps);



				Graphics.Blit(source, destination, SourceMaterial,0);
				Graphics.Blit(destination,blur5);


				blur1 = blur2;
				blur2 = blur3;
				blur3 = blur4;
				blur4 = blur5;
				break;
			}



			FrameCount++;





		}
	}
}
