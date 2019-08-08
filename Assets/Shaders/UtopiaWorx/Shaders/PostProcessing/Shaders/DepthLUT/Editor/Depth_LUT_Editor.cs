using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.DepthLUT))]
	public class Depth_LUT_Editor : Editor {

		private Texture2D Logo;
		public override void OnInspectorGUI()
		{
			if(Logo == null)
			{
				Logo = Resources.Load("Images/DepthLut") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();
			serializedObject.Update();



			SerializedProperty sp_Iterations = serializedObject.FindProperty ("Iterations");
			SerializedProperty sp_LookupTexture = serializedObject.FindProperty ("LookupTexture");
			SerializedProperty sp_Noise = serializedObject.FindProperty ("Noise");
			SerializedProperty sp_Near = serializedObject.FindProperty ("Near");




			EditorGUI.BeginChangeCheck();






			EditorGUILayout.LabelField(new GUIContent("LUT","LUT is the Look Up Texture you want to use.") );
			sp_LookupTexture.objectReferenceValue= EditorGUILayout.ObjectField(sp_LookupTexture.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_LookupTexture.objectReferenceValue == null)
			{
				sp_LookupTexture.objectReferenceValue = Resources.Load("LUTs/Honeymooners");
				serializedObject.ApplyModifiedProperties();
			}



			sp_Iterations.intValue = EditorGUILayout.IntSlider(new GUIContent("Spread","How deep the effect is spread against the depth"),sp_Iterations.intValue,0,8);


			sp_Noise.floatValue = EditorGUILayout.Slider(new GUIContent("Noise","The amount of random noise to add to the image output"),sp_Noise.floatValue,0.0f,0.055f);

			sp_Near.boolValue = EditorGUILayout.Toggle(new GUIContent("Far / Near","Apply the LUT further away from the camera or near."),sp_Near.boolValue);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
