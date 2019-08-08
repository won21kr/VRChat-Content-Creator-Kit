using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.HDRPreamp))]
	public class HDRPreampEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/HDRPreamp") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");
			SerializedProperty sp_Intensity = serializedObject.FindProperty ("Intensity");





			EditorGUI.BeginChangeCheck();


			sp_Intensity.floatValue = EditorGUILayout.Slider(new GUIContent("Intensity","How much to excite the HDR range."),sp_Intensity.floatValue,0.5f,2.0f);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","Blend is the amount of the ghosting effect to apply."),sp_Blend.floatValue,0.0f,2.0f);





			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}