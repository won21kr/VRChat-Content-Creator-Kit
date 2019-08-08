using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.DayDream))]
	public class Dream_Editor : Editor 
	{
		private Texture2D Logo;
		public override void OnInspectorGUI()
		{

			if(Logo == null)
			{
				Logo = Resources.Load("Images/DayDream") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();


			serializedObject.Update();



			SerializedProperty sp_AlphaMask = serializedObject.FindProperty ("AlphaMask");
			SerializedProperty sp_Strength = serializedObject.FindProperty ("Strength");
			SerializedProperty sp_LookupTexture = serializedObject.FindProperty ("LookupTexture");
			SerializedProperty sp_Noise = serializedObject.FindProperty ("Noise");




			EditorGUI.BeginChangeCheck();








			EditorGUILayout.LabelField(new GUIContent("LUT","LUT is the Look Up Texture you want to use.") );
			sp_LookupTexture.objectReferenceValue= EditorGUILayout.ObjectField(sp_LookupTexture.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_LookupTexture.objectReferenceValue == null)
			{
				sp_LookupTexture.objectReferenceValue = Resources.Load("LUTs/Sullivan");
				serializedObject.ApplyModifiedProperties();
			}

			EditorGUILayout.LabelField(new GUIContent("Alpha Mask","Alpha Mask is a texture used to map out where on the screen the effect will be applied.") );
			sp_AlphaMask.objectReferenceValue= EditorGUILayout.ObjectField(sp_AlphaMask.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_AlphaMask.objectReferenceValue == null)
			{
				sp_AlphaMask.objectReferenceValue = Resources.Load("AlphaMaps/Alpha1");
				serializedObject.ApplyModifiedProperties();
			}


			sp_Strength.floatValue = EditorGUILayout.Slider(new GUIContent("Strength","Strength is the power of how much this effect will be applied to areas which have alpha data on the Alpha Mask."),sp_Strength.floatValue,0.0f,1.0f);


			sp_Noise.floatValue = EditorGUILayout.Slider(new GUIContent("Noise","The amount of random noise to add to the image output"),sp_Noise.floatValue,0.0f,0.055f);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}


	}
}