using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Diagnostic))]
	public class DiagnosticEditor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Diagnostic") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Mode = serializedObject.FindProperty ("Mode");

			string[] Blends = {"World Normal","Diffuse","AO", "Specular", "Roughness", "Emission", "Lighting","Lightmaps","Reflection Probes","Depth"};




			EditorGUI.BeginChangeCheck();






			EditorGUILayout.LabelField("Mode");
			sp_Mode.intValue = EditorGUILayout.Popup(sp_Mode.intValue,Blends);




			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}