using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.BendUV))]
	public class BendUVEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/UVBend") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Volume = serializedObject.FindProperty ("Volume");
			SerializedProperty sp_Scale= serializedObject.FindProperty ("Scale");
			SerializedProperty sp_Speed= serializedObject.FindProperty ("Speed");
			SerializedProperty sp_BendTex= serializedObject.FindProperty ("BendTex");
			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");

			EditorGUI.BeginChangeCheck();





			sp_Volume.floatValue = EditorGUILayout.Slider(new GUIContent("Volume","how much of this effect to apply"),sp_Volume.floatValue,0.003f,0.005f);
			sp_Scale.floatValue = EditorGUILayout.Slider(new GUIContent("Scale","How this effect scales"),sp_Scale.floatValue,0.0f,2.0f);
			sp_Speed.floatValue = EditorGUILayout.Slider(new GUIContent("Speed","How fast is this effect"),sp_Speed.floatValue,0.0f,1.0f);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","How much of this effect to blend"),sp_Blend.floatValue,0.0f,1.0f);

			EditorGUILayout.LabelField(new GUIContent("Bend Texture","The texture you use bor bend reference") );
			sp_BendTex.objectReferenceValue= EditorGUILayout.ObjectField(sp_BendTex.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_BendTex.objectReferenceValue == null)
			{
				sp_BendTex.objectReferenceValue = Resources.Load("Textures/Bend3");
				serializedObject.ApplyModifiedProperties();
			}

			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}