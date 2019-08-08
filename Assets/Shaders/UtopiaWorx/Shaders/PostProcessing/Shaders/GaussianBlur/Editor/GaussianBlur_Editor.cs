using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.GaussianBlur))]

	public class GaussianBlur_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Gaussian") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();



			SerializedProperty sp_Passes = serializedObject.FindProperty ("Passes");
			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");

			EditorGUI.BeginChangeCheck();




			sp_Passes.intValue = EditorGUILayout.IntSlider(new GUIContent("Passes","How many blur passes to use"),sp_Passes.intValue,1,100);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","How strong is ghe blur"),sp_Blend.floatValue,0.0f,1.0f);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
