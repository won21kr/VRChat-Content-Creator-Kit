using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.ChromaticBlur))]
	public class CromaticBlurEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/CromaticBlur") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();

			SerializedProperty sp_blurMax = serializedObject.FindProperty ("blurMax");
			SerializedProperty sp_aberrationMax = serializedObject.FindProperty ("aberrationMax");
			SerializedProperty sp_numIters = serializedObject.FindProperty ("numIters");

			EditorGUI.BeginChangeCheck();
			sp_blurMax.floatValue = EditorGUILayout.Slider(new GUIContent("Max Blur","The maximum amount of blur to use."),sp_blurMax.floatValue,0.0f,1.0f);
			sp_aberrationMax.floatValue = EditorGUILayout.Slider(new GUIContent("Aberration Max","The maximum amount of Aberration to use."),sp_aberrationMax.floatValue,0.0f,2.0f);
			sp_numIters.intValue = EditorGUILayout.IntSlider(new GUIContent("Iterations","The number of blur itertions to use"),sp_numIters.intValue,10,100);

			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
