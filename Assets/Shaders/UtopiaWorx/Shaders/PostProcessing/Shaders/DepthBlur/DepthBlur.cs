/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Depth Blur Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/DepthBlur.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Depth Blur")]
	public class DepthBlur : PhotoelectricBase 
	{
		#region members

		public float radius = 0.008f;
		public float resolution = 1.0f;
		public float Iterations = -3.0f;
		public float Blend = 0.77f;
		public float Desaturate = 0.5f;
		#endregion

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/SimpleDepthBlur";
		}

		void Start () 
		{
			//set the main camera to send depth normals
			GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "radius|System.Single|0.003|0.01|1|how big is the blur radius";
			RetVal.Add(Item1);

			string Item2 = "resolution|System.Single|1.0|2.0|1|How much detail";
			RetVal.Add(Item2);

			string Item3 = "Iterations|System.Single|-5.0|20.0|1|How far away";
			RetVal.Add(Item3);

			string Item4 = "Blend|System.Single|0.0|1.0|1|How much color to mix";
			RetVal.Add(Item4);

			string Item5 = "Desaturate|System.Single|0.0|1.0|1|How much color to strip";
			RetVal.Add(Item5);


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




				SourceMaterial.SetFloat("radius", radius);
				SourceMaterial.SetFloat("resolution", resolution);
				SourceMaterial.SetFloat("_Iterations", Iterations);
				SourceMaterial.SetFloat("_Blend", Blend);
				SourceMaterial.SetFloat("_Seed", UnityEngine.Random.Range(0.01f,0.02f));
				SourceMaterial.SetFloat("_Desaturate",Desaturate);
				Graphics.Blit(source, destination, SourceMaterial);



			}

		}

	}
}