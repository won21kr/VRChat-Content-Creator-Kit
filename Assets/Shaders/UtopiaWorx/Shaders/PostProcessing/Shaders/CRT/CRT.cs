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
	#if UNITY_EDITOR
	[ExecuteInEditMode]
	#endif
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/CRT.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/CRT")]
	public class CRT : PhotoelectricBase {


		public float Comp_X = 0.338f;
		public float Comp_Y = 0.323f;
		public Vector4 vectors;
		public float Rad = 0.03f;
		public float Zoom = 1.75f;
		public float Amount = 3.3f;




		public int Factor =1;
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/CRT";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Comp_X|System.Single|0.0|1.0|1|how much Moir";
			RetVal.Add(Item1);

			string Item2 = "Comp_Y|System.Single|0.0|1.0|1|how much vertical";
			RetVal.Add(Item2);

			string Item3 = "Rad|System.Single|0.0|1.0|1|how much bend radius";
			RetVal.Add(Item3);

			string Item4 = "Zoom|System.Single|0.0|1.0|1|how much zoom";
			RetVal.Add(Item4);

			string Item5 = "Amount|System.Single|0.0|5.0|1|how much aberration";
			RetVal.Add(Item5);


			string Item6 = "Factor|System.Int32|0|5|1|which scale factor";
			RetVal.Add(Item6);


			//return the list to Zone
			return RetVal;
		}



		void Start () 
		{
			GetComponent<Camera>().depthTextureMode = DepthTextureMode.None;
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



			switch(Factor)
			{
			case 0:
				vectors.x = 128.0f;
				vectors.y = 128.0f;
				vectors.z = 128.0f;
				vectors.w = 128.0f;
				break;

			case 1:
				vectors.x = 256.0f;
				vectors.y = 256.0f;
				vectors.z = 256.0f;
				vectors.w = 256.0f;
				break;

			case 2:
				vectors.x = 512.0f;
				vectors.y = 512.0f;
				vectors.z = 512.0f;
				vectors.w = 512.0f;
				break;

			case 3:
				vectors.x = 1024.0f;
				vectors.y = 1024.0f;
				vectors.z = 1024.0f;
				vectors.w = 1024.0f;
				break;

			case 4:
				vectors.x = 2048.0f;
				vectors.y = 2048.0f;
				vectors.z = 2048.0f;
				vectors.w = 2048.0f;
				break;

			}
			SourceMaterial.SetVector("vectors", vectors);


			SourceMaterial.SetFloat("_Comp_X",Comp_X);
			SourceMaterial.SetFloat("_Comp_Y",Comp_Y);
			SourceMaterial.SetFloat("_Rad",Rad );
			SourceMaterial.SetFloat("_Zoom",Zoom  );
			SourceMaterial.SetFloat("_Amount",Amount);


			RenderTexture RTCRT = RenderTexture.GetTemporary(source.width, source.height,0,source.format);
			RenderTexture RTCA = RenderTexture.GetTemporary(source.width, source.height,0,source.format);
			Graphics.Blit(source, RTCA, SourceMaterial,0);
			Graphics.Blit(RTCA, RTCRT, SourceMaterial,1);
			Graphics.Blit(RTCRT, destination, SourceMaterial,2);

			RenderTexture.ReleaseTemporary(RTCA);
			RenderTexture.ReleaseTemporary(RTCRT);


		}
	}
}
