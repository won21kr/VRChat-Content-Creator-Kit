/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Mirage Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Mirage.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Mirage")]
	public class Mirage : PhotoelectricBase 
	{

		#region members

		public float Iterations = -1.0f;
		public float EffectWidth = 0.4f;
		public float NormalRange = 0.7f;
		public Texture2D DisplaceTex;
		public float Magnitude = 0.02f;
		public float Speed = -0.4f;
		public float MaxWorldHeight = 5780.0f;
		public int ShowDebug = 0;
		public bool IsDebug = false;
		public float MatchWeight = 0.2f;
		#endregion


		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Mirage";
		}
		void Start () 
		{
			//set the main camera to send depth normals
			GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Iterations|System.Single|-20.0|20.0|1|Distance from camera";
			RetVal.Add(Item1);

			string Item2 = "EffectWidth|System.Single|-1.0|20.0|1|Volume of the effect";
			RetVal.Add(Item2);

			string Item3 = "NormalRange|System.Single|0.45|1.35|1|Normal view Angle";
			RetVal.Add(Item3);

			string Item4 = "Magnitude|System.Single|0.0|0.09|1|How much motion to add";
			RetVal.Add(Item4);

			string Item5 = "Speed|System.Single|-2.0|2.0|1|How fast the motion should be";
			RetVal.Add(Item5);

			string Item6 = "MaxWorldHeight|System.Single|0.0|10000.0|1|How high can it render";
			RetVal.Add(Item6);

			string Item7 = "MatchWeight|System.Single|0.0|1.0|1|Adjust color tolerance";
			RetVal.Add(Item7);

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
				//set the shader properties

				//todo
				//find a way to set this value based on camera position 
				SourceMaterial.SetFloat("_Iterations", Iterations);

				SourceMaterial.SetFloat("_EffectWidth", EffectWidth);
				SourceMaterial.SetFloat("_NormalRange", NormalRange);
				SourceMaterial.SetTexture("_DisplaceTex", DisplaceTex);
				SourceMaterial.SetFloat("_Magnitude", Magnitude);
				SourceMaterial.SetFloat("_Speed", Speed);
				SourceMaterial.SetFloat("_MaxWorldHeight",MaxWorldHeight);
				SourceMaterial.SetFloat("_MatchWeight",MatchWeight);
				SourceMaterial.SetInt("_ShowDebug",ShowDebug);

				//blit the shader
				Graphics.Blit(source, destination, SourceMaterial);

			}

		}
	}
}
