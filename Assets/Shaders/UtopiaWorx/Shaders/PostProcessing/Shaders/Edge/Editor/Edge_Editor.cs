using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Edge))]
	public class Edge_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/EdgeShadow") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Weight = serializedObject.FindProperty ("Weight");
			SerializedProperty sp_Width = serializedObject.FindProperty ("Width");


			EditorGUI.BeginChangeCheck();





			sp_Width.floatValue = EditorGUILayout.Slider(new GUIContent("Width","How far to apply the effect"),sp_Width.floatValue,0.001f,0.009f);
			sp_Weight.floatValue = EditorGUILayout.Slider(new GUIContent("Weight","How much of this effect to apply"),sp_Weight.floatValue,0.1f,10.0f);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}
