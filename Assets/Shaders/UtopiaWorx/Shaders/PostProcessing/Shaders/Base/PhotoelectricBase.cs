using UnityEngine;
using System.Collections;


namespace Utopiaworx.Shaders.PostProcessing
{
public class PhotoelectricBase : MonoBehaviour 
{
	public bool UsesHDR;
	public bool UsesLinear;
	public bool UsesRenderTextures;
	public bool UsesDeffered;
	public bool UsesSM3;
	public bool UsedDepth;



	public Shader _Shader;
	public Shader TheShader
	{
		get
		{
			if (_Shader == null)
				_Shader = Shader.Find(ShaderName());

			return _Shader;
		}
	}

	protected Material _Material;
	public Material SourceMaterial
	{
		get
		{
			if (_Material == null)
			{
				_Material = new Material(TheShader);
				_Material.hideFlags = HideFlags.HideAndDontSave;
			}

			return _Material;
		}
	}

	public void OnEnable()
	{
		
		if(UsesHDR == true)
		{
			if(gameObject.GetComponent<Camera>().hdr == false)
			{
				Debug.LogWarning("Warning, The shader " + ShaderName() + " requires HDR Rendering on your camera.");
				enabled = false;
				return;
			}
		}
		#if UNITY_EDITOR 
		if(UsesLinear == true)
		{
			if(UnityEditor.PlayerSettings.colorSpace != ColorSpace.Linear)
			{
				Debug.LogWarning("Warning, The shader " + ShaderName() + " requires Linear Color Space enabled.");			
				enabled = false;
				return;
			}
		}

		if(UsesDeffered == true)
		{
			if(UnityEditor.PlayerSettings.renderingPath != RenderingPath.DeferredShading)
			{
				Debug.LogWarning("Warning, The shader " + ShaderName() + " requires Deferred Rendering Mode.");			
				enabled = false;
				return;
			}
		}

		// Disable if we don't support image effects
		if (!SystemInfo.supportsImageEffects)
		{
			Debug.LogWarning("Warning, the configuration you have selected does not support image effects.");
			enabled = false;
			return;
		}

		// Disable if we don't support render textures
		if (!SystemInfo.supportsRenderTextures)
		{
			Debug.LogWarning("Warning, the configuration you have selected does not support render texures");
			enabled = false;
			return;
		}
		if(UsesSM3 == true)
		{
			if (SystemInfo.graphicsShaderLevel <3)
			{
				Debug.LogWarning("Warning, Shader Level 3 is required.");
				enabled = false;
				return;
			}
		}

		// Disable the image effect if the shader is missing
		if (TheShader == null)
		{
			Debug.LogWarning("The Shader " + ShaderName().ToString() + " is missng, please re-install Photoelectric Shaders.");
			enabled = false;
			return;
		}

		if(UsedDepth == true)
		{
			if (!SystemInfo.SupportsRenderTextureFormat(RenderTextureFormat.Depth))
			{
				Debug.LogWarning("Warning,Depth Textures and Z Buffers are required to run this shader");
				enabled = false;
				return;
			}
		}

		#endif
	}


	protected virtual void OnDisable()
	{
		if (_Material) 
		{
			DestroyImmediate (_Material);
		}
		_Material = null;
	}

	protected virtual void OnRenderImage(RenderTexture source, RenderTexture destination) { }
	protected virtual string ShaderName() { return "null"; }
}
}