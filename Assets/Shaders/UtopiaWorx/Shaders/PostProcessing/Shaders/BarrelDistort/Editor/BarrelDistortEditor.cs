using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.BarrelDistort))]
	public class BarrelDistortEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Barrel") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();

			SerializedProperty sp_Rad = serializedObject.FindProperty ("Rad");
			SerializedProperty sp_Zoom = serializedObject.FindProperty ("Zoom");


			EditorGUI.BeginChangeCheck();
			sp_Zoom.floatValue = EditorGUILayout.Slider(new GUIContent("Zoom","The Zoom of the effect."),sp_Zoom.floatValue,0.5f,2.0f);
			sp_Rad.floatValue = EditorGUILayout.Slider(new GUIContent("Radius","The Radius of the Barrel."),sp_Rad.floatValue,-0.2f,2.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
