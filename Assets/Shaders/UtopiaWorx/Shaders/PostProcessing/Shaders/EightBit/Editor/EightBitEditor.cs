using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.EightBit))]
	public class EightBitEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/EightBit") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();

			SerializedProperty sp_pixel_h = serializedObject.FindProperty ("pixel_h");


			EditorGUI.BeginChangeCheck();
			sp_pixel_h.floatValue = EditorGUILayout.Slider(new GUIContent("Pixel Size","Size of the Pixel Block."),sp_pixel_h.floatValue,4.0f,64.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
