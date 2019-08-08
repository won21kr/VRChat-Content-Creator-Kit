/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Cromatic Aberration Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/BendUV.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Bend UV")]

	public class BendUV : PhotoelectricBase 
	{
		#region members

		private Camera TheCamera;
		public float Volume = 0.004f;
		public float Scale = 0.15f;
		public float Speed = 0.01f;
		public float Blend = 0.0f;
		public Texture2D BendTex ;


		#endregion


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Volume|System.Single|0.01|0.05|1|How much Bending to add";
			RetVal.Add(Item1);

			string Item2 = "Scale|System.Single|0.01|0.05|1|Scale of the effect";
			RetVal.Add(Item2);

			string Item3 = "Speed|System.Single|0.0|1.0|1|How fast";
			RetVal.Add(Item3);

			string Item4 = "Blend|System.Single|0.0|1.0|1|How much effect to mix";
			RetVal.Add(Item4);


			//return the list to Zone
			return RetVal;
		}

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/BendUV";
		}

		void Start () 
		{
			TheCamera = GetComponent<Camera>();
			//set the main camera to send depth normals
			TheCamera.depthTextureMode = DepthTextureMode.Depth;
		}


		//[ImageEffectOpaque]
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
				SourceMaterial.SetTexture("_BendTex",BendTex);
				SourceMaterial.SetFloat("_Volume",Volume);
				SourceMaterial.SetFloat("_Scale",Scale);
				SourceMaterial.SetFloat("_Speed",Speed);
				SourceMaterial.SetFloat("_Blend",Blend);
				Graphics.Blit(source, destination, SourceMaterial);
			}

		}

	}
}
