using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.SSAO))]
	public class SSAOEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/SSAO") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Amount = serializedObject.FindProperty ("Amount");
			SerializedProperty sp_Distance = serializedObject.FindProperty ("Distance");
			SerializedProperty sp_Tolerance = serializedObject.FindProperty ("Tolerance");
			SerializedProperty sp_Blurs = serializedObject.FindProperty ("Blurs");
			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");
			SerializedProperty sp_Radius = serializedObject.FindProperty ("Radius");
			SerializedProperty sp_DownsampleRate = serializedObject.FindProperty ("DownsampleRate");


			EditorGUI.BeginChangeCheck();


			string[] DownsampleRates = {"Full Resolution","Half Resolution","Quarter Resolution","Eighth Resolution"};
			EditorGUILayout.LabelField("AO Texture Downsampling");
			sp_DownsampleRate.intValue = EditorGUILayout.Popup(sp_DownsampleRate.intValue,DownsampleRates);
			sp_Amount.floatValue = EditorGUILayout.Slider(new GUIContent("AO Amount","How much of this effect do you want to apply"),sp_Amount.floatValue,0.001f,2.0f);
			sp_Radius.floatValue = EditorGUILayout.Slider(new GUIContent("AO Radius",""),sp_Radius.floatValue,0.0f,1.0f);
			sp_Distance.floatValue = EditorGUILayout.Slider(new GUIContent("AO Distance","How far do you want the AO to cast in the scene depth"),sp_Distance.floatValue,0.001f,2.0f);
			sp_Tolerance.floatValue = EditorGUILayout.Slider(new GUIContent("AO Tolerance",""),sp_Tolerance.floatValue,0.0f,1.0f);
			sp_Blurs.intValue = EditorGUILayout.IntSlider(new GUIContent("Blur passes",""),sp_Blurs.intValue,0,20);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Preview",""),sp_Blend.floatValue,0.0f,1.0f);
			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}
