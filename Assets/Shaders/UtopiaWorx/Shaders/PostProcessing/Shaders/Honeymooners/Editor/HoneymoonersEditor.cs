


using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Honeymooners))]
	public class HoneymoonersEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Honeymooners") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_GhostRate = serializedObject.FindProperty ("GhostRate");
			SerializedProperty sp_Noise = serializedObject.FindProperty ("Noise");
			SerializedProperty sp_Rad = serializedObject.FindProperty ("Rad");
			SerializedProperty sp_Rad2 = serializedObject.FindProperty ("Rad2");
			SerializedProperty sp_LookupTexture = serializedObject.FindProperty ("LookupTexture");
			SerializedProperty sp_LUTBlend = serializedObject.FindProperty ("LUTBlend");
			SerializedProperty sp_Ghost1 = serializedObject.FindProperty ("Ghost1");
			SerializedProperty sp_ChromaticOffset = serializedObject.FindProperty ("ChromaticOffset");





			EditorGUI.BeginChangeCheck();







			sp_GhostRate.intValue = EditorGUILayout.IntSlider(new GUIContent("Rate","How often to Ghost"),sp_GhostRate.intValue,1,5);
			sp_Noise.floatValue = EditorGUILayout.Slider(new GUIContent("Grain","How much grain to apply"),sp_Noise.floatValue,0.0f,1.0f);
			sp_ChromaticOffset.floatValue = EditorGUILayout.Slider(new GUIContent("Chroma Split","How much Chromatic Split to apply"),sp_ChromaticOffset.floatValue,1.0f,50.0f);


			sp_Rad.floatValue = EditorGUILayout.Slider(new GUIContent("Vignette","How much vignette to apply"),sp_Rad.floatValue,0.0f,1.0f);
			sp_Rad2.floatValue = EditorGUILayout.Slider(new GUIContent("Lens Warp","How much lens curve to apply"),sp_Rad2.floatValue,-0.1f,0.1f);

			EditorGUILayout.LabelField(new GUIContent("Render Texture","A Render Texture to store the Ghost Frames into") );
			sp_Ghost1.objectReferenceValue= EditorGUILayout.ObjectField(sp_Ghost1.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_Ghost1.objectReferenceValue == null)
			{
				sp_Ghost1.objectReferenceValue = Resources.Load("RenderTextures/HoneyMooners_Low");
				serializedObject.ApplyModifiedProperties();
			}

			EditorGUILayout.LabelField(new GUIContent("LUT","LUT is the Look Up Texture you want to use.") );
			sp_LookupTexture.objectReferenceValue= EditorGUILayout.ObjectField(sp_LookupTexture.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_LookupTexture.objectReferenceValue == null)
			{
				sp_LookupTexture.objectReferenceValue = Resources.Load("LUTs/Honeymooners");
				serializedObject.ApplyModifiedProperties();
			}

			sp_LUTBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Color Blend","How much of the color table effect to apply"),sp_LUTBlend.floatValue,0.0f,1.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}



	}
}
