using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.LensArtifacts))]
	public class LensArtifactsEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/LensArtifact") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();

			SerializedProperty sp_Boost = serializedObject.FindProperty ("Boost");
			SerializedProperty sp_Volume = serializedObject.FindProperty ("Volume");
			SerializedProperty sp_LensTexture = serializedObject.FindProperty ("LensTexture");
			EditorGUI.BeginChangeCheck();



			sp_LensTexture.objectReferenceValue= EditorGUILayout.ObjectField(sp_LensTexture.objectReferenceValue,typeof(Texture2D),true) as Texture2D;
			if(sp_LensTexture.objectReferenceValue == null)
			{
				sp_LensTexture.objectReferenceValue = Resources.Load("Textures/Lens_Dirt/lens5");
				serializedObject.ApplyModifiedProperties();
			}
			sp_Boost.floatValue = EditorGUILayout.Slider(new GUIContent("Boost","Just a little extra."),sp_Boost.floatValue,1.0f,1.5f);

			sp_Volume.floatValue = EditorGUILayout.Slider(new GUIContent("Volume","How much volume of Fog to add."),sp_Volume.floatValue,0.0f,1.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}


	}
}
