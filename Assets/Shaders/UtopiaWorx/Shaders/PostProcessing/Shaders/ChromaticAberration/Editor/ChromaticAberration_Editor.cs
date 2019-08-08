using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.ChromaticAberration))]
	public class ChromaticAberration_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Chromatic") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Mix = serializedObject.FindProperty ("Mix");
			SerializedProperty sp_Amount= serializedObject.FindProperty ("Amount");

			EditorGUI.BeginChangeCheck();





			sp_Amount.floatValue = EditorGUILayout.Slider(new GUIContent("Split","How much of this effect to apply"),sp_Amount.floatValue,1.0f,50.0f);
			sp_Mix.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","How this effect is blended"),sp_Mix.floatValue,0.0f,1.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}