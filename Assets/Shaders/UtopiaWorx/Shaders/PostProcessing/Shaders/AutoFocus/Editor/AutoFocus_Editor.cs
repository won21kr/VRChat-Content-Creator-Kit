using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.AutoFocus))]
	public class AutoFocus_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/AutoFocus") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();



			SerializedProperty sp_Blend = serializedObject.FindProperty ("Blend");


			SerializedProperty sp_UpdateTime = serializedObject.FindProperty ("UpdateTime");
			SerializedProperty sp_FocusSpeed = serializedObject.FindProperty ("FocusSpeed");

			SerializedProperty sp_FallbackLocation = serializedObject.FindProperty ("FallbackLocation");

			SerializedProperty sp_MyLM = serializedObject.FindProperty ("MyLM");
			SerializedProperty sp_Exposure = serializedObject.FindProperty ("Exposure");



				




			EditorGUI.BeginChangeCheck();





			sp_Exposure.floatValue = EditorGUILayout.Slider(new GUIContent("Exposure","Amount of Bloom"),sp_Exposure.floatValue,1.0f,10.0f);
			sp_Blend.floatValue = EditorGUILayout.Slider(new GUIContent("Blend","Mixture of the blur and the original pixel value"),sp_Blend.floatValue,0.0f,1.0f);


			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("");
			EditorGUILayout.EndHorizontal();

			sp_UpdateTime.floatValue = EditorGUILayout.Slider(new GUIContent("Update Frequency","How frequently to check for new camera locations"),sp_UpdateTime.floatValue,0.0f,1.0f);
			sp_FocusSpeed.floatValue = EditorGUILayout.Slider(new GUIContent("Focus Speed","How fast to focus the camera on the new item"),sp_FocusSpeed.floatValue,0.0f,100.0f);

			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("");
			EditorGUILayout.EndHorizontal();

			EditorGUILayout.LabelField(new GUIContent("Fallback Object","What to focus on if nothing else selected") );
			sp_FallbackLocation.objectReferenceValue= EditorGUILayout.ObjectField(sp_FallbackLocation.objectReferenceValue,typeof(Transform),true) as Transform;

			EditorGUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("");
			EditorGUILayout.EndHorizontal();

			 EditorGUILayout.PropertyField(sp_MyLM,new GUIContent("Layer Mask","Which layers to use"));
			EditorGUI.showMixedValue = sp_MyLM.hasMultipleDifferentValues;
			EditorGUI.showMixedValue = false;

			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}


	}
}
