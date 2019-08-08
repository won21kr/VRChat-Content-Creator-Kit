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
	#if UNITY_EDITOR
	[ExecuteInEditMode]
	#endif
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/Honeymooners.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Honeymooners")]
	public class Honeymooners : PhotoelectricBase 
	{
		public Texture2D LookupTexture ;
		private Texture2D previousTexture;
		private Texture3D converted3DLut = null;
		private int lutSize = 1;

		public float Blend;

		public float Rad = 0.3f;
		public float Rad2 = 0.03f;
		public RenderTexture Ghost1;
		public int GhostFrame =0;
		public int GhostRate = 3;
		public float Noise = 0.2f;
		public float LUTBlend = 0.6f;
		public float ChromaticOffset = 12.0f;



		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "GhostRate|System.Int32|1|5|1|Frame Lag";
			RetVal.Add(Item1);

			string Item2 = "Noise|System.Single|0.0|1.0|1|How much noise";
			RetVal.Add(Item2);

			string Item3 = "Rad|System.Single|0.0|1.0|1|Vignette Size";
			RetVal.Add(Item3);

			string Item4 = "Rad2|System.Single|-0.1|0.1|1|Lens Warping";
			RetVal.Add(Item4);



			//return the list to Zone
			return RetVal;
		}


		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/Honeymooners";
		}

		private void Update()
		{

			//ChromaticOffset =  15.0f +  (Mathf.Abs(Mathf.Sin(Time.frameCount)) * 4.0f);
			if (LookupTexture != previousTexture)
			{
				previousTexture = LookupTexture;
				Convert(LookupTexture);
			}
		}

		public bool ValidDimensions(Texture2D tex2d)
		{
			if (tex2d == null)
			{
				return false;
			}

			int h = tex2d.height;
			if (h != Mathf.FloorToInt(Mathf.Sqrt(tex2d.width)))
			{
				return false;
			}
			return true;
		}

		internal bool Convert(Texture2D lookupTexture)
		{
			if (!SystemInfo.supports3DTextures)
			{
				Debug.LogError("System does not support 3D textures");
				return false;
			}
			else if (lookupTexture == null)
			{
				SetIdentityLut();
			}
			else
			{
				if (converted3DLut != null)
				{
					DestroyImmediate(converted3DLut);
				}

				if (lookupTexture.mipmapCount > 1)
				{
					Debug.LogError("Lookup texture must not have mipmaps");
					return false;
				}

				try
				{
					int dim = lookupTexture.width * lookupTexture.height;
					dim = lookupTexture.height;

					if (!ValidDimensions(lookupTexture))
					{
						Debug.LogError("Lookup texture dimensions must be a power of two. The height must equal the square root of the width.");
						return false;
					}

					var c = lookupTexture.GetPixels();
					var newC = new Color[c.Length];

					for (int i = 0; i < dim; i++)
					{
						for (int j = 0; j < dim; j++)
						{
							for (int k = 0; k < dim; k++)
							{
								int j_ = dim - j - 1;
								newC[i + (j * dim) + (k * dim * dim)] = c[k * dim + i + j_ * dim * dim];
							}
						}
					}

					converted3DLut = new Texture3D(dim, dim, dim, TextureFormat.ARGB32, false);
					converted3DLut.SetPixels(newC);
					converted3DLut.Apply();
					lutSize = converted3DLut.width;
					converted3DLut.wrapMode = TextureWrapMode.Clamp;
				}
				catch (System.Exception ex)
				{
					Debug.LogError("Unable to convert texture to LUT texture, make sure it is read/write. Error: " + ex);
				}
			}

			return true;
		}


		private void OnDestroy()
		{
			if (converted3DLut != null)
			{
				DestroyImmediate(converted3DLut);
			}
			converted3DLut = null;
		}
		public void SetIdentityLut()
		{
			if (!SystemInfo.supports3DTextures)
			{
				return;
			}
			else if (converted3DLut != null)
			{
				DestroyImmediate(converted3DLut);
			}

			int dim = 16;
			var newC = new Color[dim * dim * dim];
			float oneOverDim = 1.0f / (1.0f * dim - 1.0f);

			for (int i = 0; i < dim; i++)
			{
				for (int j = 0; j < dim; j++)
				{
					for (int k = 0; k < dim; k++)
					{
						newC[i + (j * dim) + (k * dim * dim)] = new Color((i * 1.0f) * oneOverDim, (j * 1.0f) * oneOverDim, (k * 1.0f) * oneOverDim, 1.0f);
					}
				}
			}


			converted3DLut = new Texture3D(dim, dim, dim, TextureFormat.ARGB32, false);
			converted3DLut.SetPixels(newC);
			converted3DLut.Apply();
			lutSize = converted3DLut.width;
			converted3DLut.wrapMode = TextureWrapMode.Clamp;
		}

		void Start()
		{
			//gameObject.GetComponent<Camera>().depthTextureMode = DepthTextureMode.DepthNormals;
			Camera.main.depthTextureMode = DepthTextureMode.None;
			GhostFrame = 0;
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
			if(SourceMaterial == null || LookupTexture == null)
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				if (converted3DLut == null)
				{
					SetIdentityLut();
				}
					
				source.filterMode = FilterMode.Bilinear;
				SourceMaterial.SetTexture("_Ghost1",Ghost1);	
				SourceMaterial.SetFloat("_Blend",0.5f);
				SourceMaterial.SetFloat("_Rad",Rad);
				SourceMaterial.SetFloat("_Rad2",Rad2);
				SourceMaterial.SetFloat("_Seed", UnityEngine.Random.Range(0.01f,0.02f));
				SourceMaterial.SetFloat("_Noise", Noise);
				SourceMaterial.SetFloat("_LUTBlend", LUTBlend);
				SourceMaterial.SetFloat("_ChromaticOffset", ChromaticOffset);

				SourceMaterial.SetTexture("_ClutTex", converted3DLut);
				SourceMaterial.SetFloat("_Scale", (lutSize - 1) / (1.0f * lutSize));
				SourceMaterial.SetFloat("_Offset", 1.0f / (2.0f * lutSize));





				if(GhostFrame == GhostRate)
				{
					//ghost pass
					Graphics.Blit(source, Ghost1, SourceMaterial,0);
					GhostFrame =0;
				}



				//barrel pass
				RenderTexture RTBW =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTBW.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTBW, SourceMaterial,1);
				source = RTBW;



				RenderTexture RTCA =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTCA.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTCA, SourceMaterial,2);
				source = RTCA;


				//bw pass
				RenderTexture RTBRL =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTBRL.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTBRL, SourceMaterial,3);
				source = RTBRL;




				//grain pass
				RenderTexture RTGR =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTGR.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTGR, SourceMaterial,4);
				source = RTGR;


				//h blur pass
				RenderTexture RTBH =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTBH.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTBH, SourceMaterial,5);
				source = RTBH;


				//v blur pass
				RenderTexture RTBV =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTBV.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTBV, SourceMaterial,6);
				source = RTBV;


				//lut pass
				RenderTexture RTLUT =  RenderTexture.GetTemporary(source.width, source.height,0,source.format);
				RTLUT.filterMode = FilterMode.Bilinear;
				Graphics.Blit(source, RTLUT, SourceMaterial,7);
				source = RTLUT;
			





				Graphics.Blit(source, destination, SourceMaterial,8);
				RenderTexture.ReleaseTemporary(RTBW);
				RenderTexture.ReleaseTemporary(RTCA);
				RenderTexture.ReleaseTemporary(RTBRL);
				RenderTexture.ReleaseTemporary(RTGR);
				RenderTexture.ReleaseTemporary(RTBH);
				RenderTexture.ReleaseTemporary(RTBV);
				RenderTexture.ReleaseTemporary(RTLUT);

			}

		}

	}
}
