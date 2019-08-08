using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.DepthFog))]
	public class DepthFog_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/DepthFog") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Volume = serializedObject.FindProperty ("Volume");
			SerializedProperty sp_Tint = serializedObject.FindProperty ("Tint");

			EditorGUI.BeginChangeCheck();


			sp_Volume.floatValue = EditorGUILayout.Slider(new GUIContent("Volume","How much volume of Fog to add."),sp_Volume.floatValue,0.0f,100.0f);
			sp_Tint.colorValue = EditorGUILayout.ColorField(new GUIContent("Tint","The tint of the Fog"),sp_Tint.colorValue);

			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}


	}
}
