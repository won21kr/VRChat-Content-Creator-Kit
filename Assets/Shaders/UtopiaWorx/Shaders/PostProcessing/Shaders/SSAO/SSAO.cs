/*
Photoelectric Shaders Volume 1 by John Rossitter 2016
Honeymooners Shader
contact john@smarterphonelabs.com
*/
using UnityEngine;
using System.Collections;
using System.Collections.Generic;


namespace Utopiaworx.Shaders.PostProcessing
{
	public enum AO_Pass
	{
		WhitePass =0,
		AOPass=1,
		BlurPassH = 2,
		BlurPassV = 3,
		BlendPass=4
	};

	public enum DownsampleValue
	{
		ZeroX = 1,
		OneX = 2,
		TwoX = 4,
		Fourx = 8
	}

	#if UNITY_EDITOR
	[ExecuteInEditMode]
	#endif
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/SSAO.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/SSAO")]
	public class SSAO : PhotoelectricBase 
	{

		public DownsampleValue DownsampleRate;
		public Camera TheCam;
		public float Amount = 0.55f;
		public float Distance = 0.21f;
		public float Tolerance = 0.113f;
		public int Blurs = 1;
		public float Blend = 1.0f;
		public float Radius = 0.05f;
		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Amount|System.Single|0.0|2.0|1|How much AO";
			RetVal.Add(Item1);

			string Item2 = "Distance|System.Single|0.0|2.0|1|How far";
			RetVal.Add(Item2);

			string Item3 = "SampleRadius|System.Single|0.0|1.0|1|how big is the sample";
			RetVal.Add(Item3);

			string Item4 = "Bias|System.Single|0.0|1.0|1|how much to apply";
			RetVal.Add(Item4);

			string Item5 = "Blurs|System.Int32|0|20|1|how many blurs";
			RetVal.Add(Item5);



			//return the list to Zone
			return RetVal;
		}


		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/SSAO";
		}



		void Start()
		{
			TheCam = gameObject.GetComponent<Camera>();
			TheCam.depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.DepthNormals;

		}

		protected override void OnRenderImage(RenderTexture source, RenderTexture destination)
		{
			UsesHDR = true;
			UsesLinear = true;
			UsesRenderTextures = true;
			UsesDeffered = true;
			UsesSM3 = true;
			UsedDepth = true;

			if(!TheCam)
			{
				TheCam = gameObject.GetComponent<Camera>();
				TheCam.depthTextureMode = DepthTextureMode.Depth | DepthTextureMode.DepthNormals;
			}
			
			if(SourceMaterial == null )
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				int DownSampleConverter = 1;
				switch((int)DownsampleRate)
				{
				case 0:
					DownSampleConverter = 1;
					break;
				case 1:
					DownSampleConverter = 2;
					break;
				case 2:
					DownSampleConverter = 4;
					break;
				case 3:
					DownSampleConverter = 8;
					break;
				}
				SourceMaterial.SetMatrix("_Projection", (TheCam.projectionMatrix * TheCam.worldToCameraMatrix).inverse);
				SourceMaterial.SetMatrix("_Cam", TheCam.cameraToWorldMatrix);
				SourceMaterial.SetFloat("_Amount",Amount);
				SourceMaterial.SetFloat("_Distance",Distance);
				SourceMaterial.SetFloat("_Tolerance",Tolerance);
				SourceMaterial.SetFloat("_Blend",Blend);
				SourceMaterial.SetFloat("_Radius",Radius);

				RenderTexture RTBackup = RenderTexture.GetTemporary(source.width, source.height,0,RenderTextureFormat.ARGB32);
				Graphics.Blit(source,RTBackup);

				source.filterMode = FilterMode.Bilinear;
				//White pass
				RenderTexture RTWhite =  RenderTexture.GetTemporary(source.width/DownSampleConverter, source.height/DownSampleConverter,0,RenderTextureFormat.ARGB32);
				RTWhite.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTWhite, SourceMaterial,(int)AO_Pass.WhitePass);
				source = RTWhite;

				source.filterMode = FilterMode.Bilinear;
				//White pass
				RenderTexture RTAO =  RenderTexture.GetTemporary(source.width, source.height,0,RenderTextureFormat.ARGB32);
				RTAO.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTAO, SourceMaterial,(int)AO_Pass.AOPass);
				source = RTAO;

				for(int k =0; k < Blurs; k++)
				{
					source.filterMode = FilterMode.Bilinear;
					RenderTexture RTBlur =  RenderTexture.GetTemporary(source.width, source.height,0,RenderTextureFormat.ARGB32);
					RTBlur.filterMode = FilterMode.Bilinear;
					Graphics.Blit(source, RTBlur, SourceMaterial,(int)AO_Pass.BlurPassH);
					source = RTBlur;

					source.filterMode = FilterMode.Bilinear;
					RenderTexture RTBlur2 =  RenderTexture.GetTemporary(source.width, source.height,0,RenderTextureFormat.ARGB32);
					RTBlur2.filterMode = FilterMode.Bilinear;
					Graphics.Blit(source, RTBlur2, SourceMaterial,(int)AO_Pass.BlurPassV);
					source = RTBlur2;

					RenderTexture.ReleaseTemporary(RTBlur);
					RenderTexture.ReleaseTemporary(RTBlur2);
				}


				SourceMaterial.SetTexture("_Backup",RTBackup);
				Graphics.Blit(source, destination, SourceMaterial,(int)AO_Pass.BlendPass);
				RenderTexture.ReleaseTemporary(RTWhite);
				RenderTexture.ReleaseTemporary(RTAO);
	
				RenderTexture.ReleaseTemporary(RTBackup);
			}
		}
	}
}
