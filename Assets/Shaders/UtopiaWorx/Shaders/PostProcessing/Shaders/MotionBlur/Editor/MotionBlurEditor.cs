using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.MotionBlur))]
	public class MotionBlurEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/MotionBlur") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");
			SerializedProperty sp_blur1 = serializedObject.FindProperty ("blur1");
			SerializedProperty sp_blur2 = serializedObject.FindProperty ("blur2");
			SerializedProperty sp_blur3 = serializedObject.FindProperty ("blur3");
			SerializedProperty sp_blur4 = serializedObject.FindProperty ("blur4");
			SerializedProperty sp_blur5 = serializedObject.FindProperty ("blur5");
			SerializedProperty sp_Steps = serializedObject.FindProperty ("Steps");




			EditorGUI.BeginChangeCheck();



			sp_Steps.intValue = EditorGUILayout.IntSlider(new GUIContent("Frames","How many frames of motion blur to add"),sp_Steps.intValue,1,4);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","how much effect to apply"),sp_Blend.floatValue,0.0f,1.0f);
			//sp_blur1.objectReferenceValue= EditorGUILayout.ObjectField(sp_blur1.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_blur1.objectReferenceValue== null)
			{
				sp_blur1.objectReferenceValue = (RenderTexture)Resources.Load("RenderTextures/RT1");
				serializedObject.ApplyModifiedProperties();
			}
			//sp_blur2.objectReferenceValue= EditorGUILayout.ObjectField(sp_blur2.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_blur2.objectReferenceValue== null)
			{
				sp_blur2.objectReferenceValue = (RenderTexture)Resources.Load("RenderTextures/RT2");
				serializedObject.ApplyModifiedProperties();
			}
			//sp_blur3.objectReferenceValue= EditorGUILayout.ObjectField(sp_blur3.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_blur3.objectReferenceValue== null)
			{
				sp_blur3.objectReferenceValue = (RenderTexture)Resources.Load("RenderTextures/RT3");
				serializedObject.ApplyModifiedProperties();
			}
			//sp_blur4.objectReferenceValue= EditorGUILayout.ObjectField(sp_blur4.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_blur4.objectReferenceValue== null)
			{
				sp_blur4.objectReferenceValue = (RenderTexture)Resources.Load("RenderTextures/RT4");
				serializedObject.ApplyModifiedProperties();
			}
			//sp_blur5.objectReferenceValue= EditorGUILayout.ObjectField(sp_blur5.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_blur5.objectReferenceValue== null)
			{
				sp_blur5.objectReferenceValue = (RenderTexture)Resources.Load("RenderTextures/RT5");
				serializedObject.ApplyModifiedProperties();
			}

			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}