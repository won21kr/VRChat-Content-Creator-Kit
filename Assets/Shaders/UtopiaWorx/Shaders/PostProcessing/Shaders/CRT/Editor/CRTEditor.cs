using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.CRT))]
	public class CRTEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/CRT") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Comp_X = serializedObject.FindProperty ("Comp_X");
			SerializedProperty sp_Comp_Y = serializedObject.FindProperty ("Comp_Y");
			SerializedProperty sp_Factor= serializedObject.FindProperty ("Factor");
			SerializedProperty sp_Rad= serializedObject.FindProperty ("Rad");
			SerializedProperty sp_Zoom = serializedObject.FindProperty ("Zoom");
			SerializedProperty sp_Amount = serializedObject.FindProperty ("Amount");

			string[] Factors = {"128","256","512","1024","2048"};
			EditorGUI.BeginChangeCheck();




			sp_Comp_X.floatValue = EditorGUILayout.Slider(new GUIContent("Moire","How much Moire to add"),sp_Comp_X.floatValue,0.1f,1.0f);
			sp_Comp_Y.floatValue = EditorGUILayout.Slider(new GUIContent("Horizontal Lines","How much Moir to add"),sp_Comp_Y.floatValue,0.1f,0.5f);
			EditorGUILayout.LabelField("");
			EditorGUILayout.LabelField("Resolution");
			sp_Factor.intValue = EditorGUILayout.Popup(sp_Factor.intValue,Factors);
			EditorGUILayout.LabelField("");
			sp_Rad.floatValue = EditorGUILayout.Slider(new GUIContent("Screen Bend Radius","How much bend radius to add"),sp_Rad.floatValue,0.0f,0.5f);
			sp_Zoom.floatValue = EditorGUILayout.Slider(new GUIContent("Screen Zoom","How much Zoom"),sp_Zoom.floatValue,0.0f,2.0f);
			sp_Amount.floatValue = EditorGUILayout.Slider(new GUIContent("Aberration Amount","How much Chromatic Aberration to add"),sp_Amount.floatValue,0.0f,5.0f);


			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}