/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Bloom Shader
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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Bloom.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Bloom")]
	public class Bloom : PhotoelectricBase 
	{
		#region members


		public float BlewmStrength =0.5f;
		public int Blurps = 10;
		public float Noise = 0.55f;

		private float texelStrength;
		#endregion

		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Bloom";
		}

		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "BlewmStrength|System.Single|0.0|1.0|1|Control the blend";
			RetVal.Add(Item1);

			string Item2 = "Blurps|System.Int32|1|60|1|How many samples to take per frame";
			RetVal.Add(Item2);

			string Item3 = "Noise|System.Single|0.0|1.0|1|How mmuch noise to add";
			RetVal.Add(Item3);



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

			//int Blurps = 2;
			//if the source material is missing
			if(SourceMaterial == null)
			{
				//just return an empty blit
				Graphics.Blit(source, destination);
			}
			else
			{

				//SourceMaterial .SetFloat("_texelStrength",texelStrength);
				source.filterMode = FilterMode.Bilinear;

				//downsample the version of source we pass into blur
				RenderTexture RTDS;
				RTDS = source; 

				int TexWidth = source.width /2;
				int TexHeight = source.height /2;


				float TS = 8192;
				for(int i =0; i < 6; i++)
				{

					float NN = Random.Range(Noise,Noise + 0.1f);
					SourceMaterial.SetFloat("_texelStrength",TS);
					SourceMaterial.SetFloat("_Noise",NN);
					SourceMaterial.SetFloat("_Seed",Noise);
					RenderTexture RTTemp = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
					RTTemp.filterMode = FilterMode.Bilinear;
					Graphics.Blit(RTDS, RTTemp,SourceMaterial,6);
					RTDS = RTTemp;
					RenderTexture.ReleaseTemporary(RTTemp);

					RTTemp = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
					RTTemp.filterMode = FilterMode.Bilinear;
					Graphics.Blit(RTDS, RTTemp,SourceMaterial,1);
					RTDS = RTTemp;




					for(int j=0; j< Blurps; j++)
					{

						RenderTexture RTBP;

						//horizontal blur
						RTBP = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
						RTBP.filterMode = FilterMode.Bilinear;
						Graphics.Blit(RTTemp,RTBP, SourceMaterial,2);
						RenderTexture.ReleaseTemporary(RTTemp);
						RTTemp = RTBP;

						//vertical blur
						RTBP = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
						RTBP.filterMode = FilterMode.Bilinear;
						Graphics.Blit(RTTemp,RTBP, SourceMaterial,3);
						RenderTexture.ReleaseTemporary(RTTemp);
						RTTemp = RTBP;
		
						//diagonal 1
						RTBP = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
						RTBP.filterMode = FilterMode.Bilinear;
						Graphics.Blit(RTTemp,RTBP, SourceMaterial,4);
						RenderTexture.ReleaseTemporary(RTTemp);
						RTTemp = RTBP;

						//diagonal 2
						RTBP = RenderTexture.GetTemporary(TexWidth, TexHeight,0,source.format);
						RTBP.filterMode = FilterMode.Bilinear;
						Graphics.Blit(RTTemp,RTBP, SourceMaterial,5);
						RenderTexture.ReleaseTemporary(RTTemp);
						RTTemp = RTBP;

					}

					switch(i)
					{
					case 0:
						SourceMaterial.SetTexture("_BloomPass1",RTTemp);
						break;

					case 1:
						SourceMaterial.SetTexture("_BloomPass2",RTTemp);
						break;

					case 2:
						SourceMaterial.SetTexture("_BloomPass3",RTTemp);
						break;

					case 3:
						SourceMaterial.SetTexture("_BloomPass4",RTTemp);
						break;

					case 4:
						SourceMaterial.SetTexture("_BloomPass5",RTTemp);
						break;

					case 5:
						SourceMaterial.SetTexture("_BloomPass6",RTTemp);
						break;

					}

					RenderTexture.ReleaseTemporary(RTTemp);
					TexHeight = TexHeight / 2;
					TexWidth = TexWidth / 2;
					TS = TS /2;
				}

				SourceMaterial.SetFloat("_BlewmStrength",BlewmStrength);
				Graphics.Blit(source,destination,SourceMaterial,0);
			}
		}
	}
}