using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Ghost))]
	public class Ghost_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/GhostShader") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");


			SerializedProperty sp_Ghost1 = serializedObject.FindProperty ("Ghost1");
			SerializedProperty sp_GhostRate = serializedObject.FindProperty ("GhostRate");

			SerializedProperty sp_BlendMode = serializedObject.FindProperty ("BlendMode");

			string[] Blends = {"No Effect","Red Only","Green Only", "Blue Only", "All Colors", "Green & Blue", "Red & Blue","Red & Green"};




			EditorGUI.BeginChangeCheck();






			EditorGUILayout.LabelField(new GUIContent("Render Texture","A Render Texture to store the Ghost Frames into") );
			sp_Ghost1.objectReferenceValue= EditorGUILayout.ObjectField(sp_Ghost1.objectReferenceValue,typeof(RenderTexture),true) as RenderTexture;
			if(sp_Ghost1.objectReferenceValue == null)
			{
				sp_Ghost1.objectReferenceValue =Resources.Load("RenderTextures/Ghost_RT_Mid");	
				serializedObject.ApplyModifiedProperties();
			}
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","Blend is the amount of the ghosting effect to apply."),sp_Blend.floatValue,0.0f,0.9f);
			sp_GhostRate.intValue = EditorGUILayout.IntSlider(new GUIContent("Rate","How Frequently to make new Ghost Frames"),sp_GhostRate.intValue,1,10);
			//sp_BlendMode.intValue = EditorGUILayout.IntSlider(new GUIContent("Color Mode","Which color mixing mode to use"),sp_BlendMode.intValue,0,7);
			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("");
			EditorGUILayout.EndHorizontal();
			EditorGUILayout.LabelField("Blending Mode");
			sp_BlendMode.intValue = EditorGUILayout.Popup(sp_BlendMode.intValue,Blends);




			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}

	}
}