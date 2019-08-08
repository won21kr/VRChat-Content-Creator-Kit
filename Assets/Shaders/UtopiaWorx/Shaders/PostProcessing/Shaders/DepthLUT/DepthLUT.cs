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
	[HelpURL("http://www.utopiaworx.com/Photoelectric/Vol1/DepthLUT.aspx")]
	[RequireComponent (typeof (UnityEngine.Camera))]
	[AddComponentMenu("Photoelectric Shaders/Depth LUT")]
	public class DepthLUT : PhotoelectricBase {

		public Texture2D LookupTexture;
		private Texture2D previousTexture;

		public Texture2D AlphaMask;
		public float Strength;
		public float Noise = 0.03f;
		private Texture3D converted3DLut = null;
		private int lutSize = 1;
		public int Iterations =2 ;
		public bool Near = false;
		protected override string ShaderName()
		{
			return "Utopiaworx/Shaders/PostProcessing/DepthLUT";
		}


		public static List<string> ZonePluginActivator()
		{
			//declare the return value list
			List<string> RetVal = new List<string>();

			string Item1 = "Strength|System.Single|0.0|8.0|1|how much fog";
			RetVal.Add(Item1);

			string Item2 = "Noise|System.Single|0.0|0.055|1|how much fog";
			RetVal.Add(Item2);



			//return the list to Zone
			return RetVal;
		}

		private void Update()
		{


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


		void Start () 
		{
			GetComponent<Camera>().depthTextureMode = DepthTextureMode.Depth;
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

			if(SourceMaterial == null ||  LookupTexture == null)
			{
				Graphics.Blit(source, destination);
			}
			else
			{
				if (converted3DLut == null)
				{
					SetIdentityLut();
				}
				if(Near == true)
				{
					SourceMaterial.SetFloat("_Near", 1);
				}
				else
				{
					SourceMaterial.SetFloat("_Near", 0);					
				}
				SourceMaterial.SetFloat("_Iterations", Iterations);
				SourceMaterial.SetFloat("_Seed", UnityEngine.Random.Range(0.01f,0.02f));
				SourceMaterial.SetFloat("_Noise", Noise);
				SourceMaterial.SetTexture("_ClutTex", converted3DLut);
				SourceMaterial.SetFloat("_Scale", (lutSize - 1) / (1.0f * lutSize));
				SourceMaterial.SetFloat("_Offset", 1.0f / (2.0f * lutSize));

				Graphics.Blit(source, destination, SourceMaterial);

			}

		}
	}
}
