using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Mirage))]
	public class Mirage_Editor : Editor 
	{
		

		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/MirageShader") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Iterations = serializedObject.FindProperty ("Iterations");
			SerializedProperty sp_EffectWidth = serializedObject.FindProperty ("EffectWidth");
			SerializedProperty sp_NormalRange = serializedObject.FindProperty ("NormalRange");
			SerializedProperty sp_DisplaceTex = serializedObject.FindProperty ("DisplaceTex");
			SerializedProperty sp_Magnitude = serializedObject.FindProperty ("Magnitude");
			SerializedProperty sp_Speed = serializedObject.FindProperty ("Speed");
			SerializedProperty sp_MaxWorldHeight = serializedObject.FindProperty ("MaxWorldHeight");
			SerializedProperty sp_ShowDebug = serializedObject.FindProperty ("ShowDebug");
			SerializedProperty sp_IsDebug = serializedObject.FindProperty ("IsDebug");
			SerializedProperty sp_MatchWeight = serializedObject.FindProperty ("MatchWeight");





			EditorGUI.BeginChangeCheck();






			EditorGUILayout.LabelField(new GUIContent("Distance","How far away the Mirage effect will work.") );
			sp_Iterations.floatValue= EditorGUILayout.Slider(sp_Iterations.floatValue,-20.0f,20.0f);

			EditorGUILayout.LabelField(new GUIContent("Volume","How much effect to use.") );
			sp_EffectWidth.floatValue= EditorGUILayout.Slider(sp_EffectWidth.floatValue,-1.0f,20.0f);

			EditorGUILayout.LabelField(new GUIContent("Normal Angle","What direction of world normal to apply the effect to") );
			sp_NormalRange.floatValue= EditorGUILayout.Slider(sp_NormalRange.floatValue,0.45f,1.35f);

			EditorGUILayout.LabelField(new GUIContent("Displacement Texture","The noise texture to create the mirage shimmer with.") );
			sp_DisplaceTex.objectReferenceValue= EditorGUILayout.ObjectField(sp_DisplaceTex.objectReferenceValue,typeof(Texture2D),true) as Texture2D;
			if(sp_DisplaceTex.objectReferenceValue == null)
			{
				sp_DisplaceTex.objectReferenceValue = Resources.Load("Textures/Noise");
				serializedObject.ApplyModifiedProperties();
			}
			EditorGUILayout.LabelField(new GUIContent("Magnitude","How strong is the effect") );
			sp_Magnitude.floatValue= EditorGUILayout.Slider(sp_Magnitude.floatValue,0.0f,0.09f);

			EditorGUILayout.LabelField(new GUIContent("Speed","How fast is the effect") );
			sp_Speed.floatValue= EditorGUILayout.Slider(sp_Speed.floatValue,-2.0f,2.0f);

			EditorGUILayout.LabelField(new GUIContent("Maximum World Height","The maximum height which the effect will be applied on the world scale.") );
			sp_MaxWorldHeight.floatValue= EditorGUILayout.Slider(sp_MaxWorldHeight.floatValue,0.0f,10000.0f);

			EditorGUILayout.LabelField(new GUIContent("Color Tolerance","Use this value to tune out the blend of character vs. Mirage") );
			sp_MatchWeight.floatValue= EditorGUILayout.Slider(sp_MatchWeight.floatValue,0.0f,1.0f);


			EditorGUILayout.LabelField(new GUIContent("Debug","Show where the effect will be applied.") );
			sp_IsDebug.boolValue = EditorGUILayout.Toggle(sp_IsDebug.boolValue);

			if(sp_IsDebug.boolValue == true)
			{
				sp_ShowDebug.intValue = 1;
			}
			else
			{
				sp_ShowDebug.intValue = 0;				
			}




			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}
