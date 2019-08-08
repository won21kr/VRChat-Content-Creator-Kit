using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.Bloom))]
	public class Bloom_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/Blewm") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();


			SerializedProperty sp_BlewmStrength = serializedObject.FindProperty ("BlewmStrength");
			SerializedProperty sp_Blurps = serializedObject.FindProperty ("Blurps");
			SerializedProperty sp_Noise = serializedObject.FindProperty ("Noise");



			EditorGUI.BeginChangeCheck();






			sp_BlewmStrength.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","Blend amount of this bloom effect"),sp_BlewmStrength.floatValue,0.0f,1.0f);
			sp_Blurps.intValue = EditorGUILayout.IntSlider(new GUIContent("Samples","How many times to smooth the buffer."),sp_Blurps.intValue,1,60);
			sp_Noise.floatValue = EditorGUILayout.Slider(new GUIContent("Noise","Amount of noise to apply to the image"),sp_Noise.floatValue,0.0f,1.0f);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}



	}
}
