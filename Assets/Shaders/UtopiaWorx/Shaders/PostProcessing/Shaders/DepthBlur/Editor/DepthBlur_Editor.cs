using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.DepthBlur))]
	public class DepthBlur_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/DepthBlur") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_radius = serializedObject.FindProperty ("radius");
			SerializedProperty sp_resolution = serializedObject.FindProperty ("resolution");
			SerializedProperty sp_Iterations = serializedObject.FindProperty ("Iterations");
			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");
			SerializedProperty sp_Desaturate = serializedObject.FindProperty ("Desaturate");



			EditorGUI.BeginChangeCheck();






			sp_Desaturate.floatValue = EditorGUILayout.Slider(new GUIContent("Desaturate","Amount of desaturation to apply to the blurred region"),sp_Desaturate.floatValue,0.0f,1.0f);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","Mixture of the blur and the original pixel value"),sp_Blend.floatValue,0.0f,1.0f);
			sp_radius.floatValue = EditorGUILayout.Slider(new GUIContent("Pixel Radius","How large is the radius adound the pixel"),sp_radius.floatValue,0.003f,0.01f);
			sp_resolution.floatValue = EditorGUILayout.Slider(new GUIContent("Resolution","How much effect to apply"),sp_resolution.floatValue,1.0f,2.0f);
			sp_Iterations.floatValue = EditorGUILayout.Slider(new GUIContent("Depth","How far away in scren space to begin aplying the effect."),sp_Iterations.floatValue,-5.0f,20.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}


	}
}
