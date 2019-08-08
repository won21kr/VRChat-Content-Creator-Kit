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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/CromaticAb.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Cromatic Aberration")]

	public class ChromaticAberration : PhotoelectricBase 
	{
		#region members

		private Camera TheCamera;
		public float Amount = 8.1f;
		public float Mix = 0.44f;


		#endregion


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Amount|System.Single|1.0|50.0|1|How much aberration to add";
			RetVal.Add(Item1);

			string Item2 = "Mix|System.Single|0.0|1.0|1|How hard to mix it with base color";
			RetVal.Add(Item2);




			//return the list to Zone
			return RetVal;
		}

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/ChromaticAberration";
		}

		void Start () 
		{
			TheCamera = GetComponent<Camera>();
			//set the main camera to send depth normals
			TheCamera.depthTextureMode = DepthTextureMode.Depth;
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
				SourceMaterial.SetFloat("_Amount",Amount);
				SourceMaterial.SetFloat("_Mix",Mix);
				Graphics.Blit(source, destination, SourceMaterial);
			}

		}

	}
}
