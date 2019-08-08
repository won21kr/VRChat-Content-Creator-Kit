/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Ghost Frames Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Ghost.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Ghost Frames")]
	public class Ghost : PhotoelectricBase 
	{
		public float Blend = 0.8f;
		public RenderTexture Ghost1;
		public int BlendMode =2;
		public int GhostFrame =0;
		public int GhostRate = 3;

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Ghost";
		}

		void Start()
		{
			GhostFrame =0;
		}

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Blend|System.Single|0.0|1.0|1|Blend Strength";
			RetVal.Add(Item1);

			string Item2 = "GhostRate|System.Int32|1|10|1|Ghost Frame Rate";
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
			GhostFrame++;
			if(SourceMaterial == null)
			{
				Graphics.Blit(source, destination);
			}
			else
			{


				//set the shader properties
				SourceMaterial.SetFloat("_Seed", UnityEngine.Random.Range(0.01f,0.02f));
				SourceMaterial.SetFloat("_FrameID", GhostFrame);
				SourceMaterial.SetTexture("_Ghost1",Ghost1);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetInt("_BlendMode",BlendMode);


				if(GhostFrame == GhostRate)
				{
					


					//blit the source to the Temp render texture
					Graphics.Blit(source, Ghost1, SourceMaterial);
					//do the normal blit
					Graphics.Blit(source, destination, SourceMaterial);
					//reset the Frame Counter
					GhostFrame =0;
				}
				else
				{
					//do normal blit
					Graphics.Blit(source, destination, SourceMaterial);
				}
			}

		}

	}
}