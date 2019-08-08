using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.ColorMixer))]
	public class ColorMixer_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/ColorMixer") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();

			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");


			EditorGUI.BeginChangeCheck();
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","The amount to blend this effect with the main image."),sp_Blend.floatValue,0.0f,1.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
