using UnityEngine;
using System.Collections;
using UnityEditor;

namespace Utopiaworx.Shaders.PostProcessing
{
	[CustomEditor(typeof(Utopiaworx.Shaders.PostProcessing.ColorCorrection))]
	public class ColorCorrectionEditor : Editor {

		private Texture2D Logo;
		public override void OnInspectorGUI()
		{
			if(Logo == null)
			{
				Logo = Resources.Load("Images/ColorCorrection") as Texture2D;
			}


			EditorGUILayout.BeginHorizontal();
			GUILayout.FlexibleSpace();
			GUILayout.Label(Logo);
			GUILayout.FlexibleSpace();
			EditorGUILayout.EndHorizontal();
			serializedObject.Update();




			SerializedProperty sp_LookupTexture = serializedObject.FindProperty ("LookupTexture");

			SerializedProperty sp_MixMode = serializedObject.FindProperty ("MixMode");

			SerializedProperty sp_RedBlend = serializedObject.FindProperty ("RedBlend");
			SerializedProperty sp_GreenBlend = serializedObject.FindProperty ("GreenBlend");
			SerializedProperty sp_BlueBlend = serializedObject.FindProperty ("BlueBlend");

			SerializedProperty sp_HueBlend = serializedObject.FindProperty ("HueBlend");
			SerializedProperty sp_SaturationBlend = serializedObject.FindProperty ("SaturationBlend");
			SerializedProperty sp_VibranceBlend = serializedObject.FindProperty ("VibranceBlend");

			SerializedProperty sp_MasterMix = serializedObject.FindProperty ("MasterMix");






			EditorGUI.BeginChangeCheck();




			string[] Modes = {"No Blending","HSV Blending","RGB Blending"};

			EditorGUILayout.LabelField(new GUIContent("Lookup Texture","LUT is the Look Up Texture you want to use.") );
			sp_LookupTexture.objectReferenceValue= EditorGUILayout.ObjectField(sp_LookupTexture.objectReferenceValue,typeof(Texture2D),true) as Texture2D;

			if(sp_LookupTexture.objectReferenceValue == null)
			{
				sp_LookupTexture.objectReferenceValue = Resources.Load("LUTs/Honeymooners");
				serializedObject.ApplyModifiedProperties();
			}

			EditorGUILayout.LabelField("");
			EditorGUILayout.LabelField(new GUIContent("Blending Mode","Which color blending mode to use") );
			sp_MixMode.intValue = EditorGUILayout.Popup(sp_MixMode.intValue,Modes);
			EditorGUILayout.LabelField("");
			if(sp_MixMode.intValue > 0)
			{
				if(sp_MixMode.intValue == 1)
				{
					sp_HueBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Hue Mix","How to mix the Hues"),sp_HueBlend.floatValue,0.0f,1.0f);
					sp_SaturationBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Saturation Mix","How to mix the Saturation"),sp_SaturationBlend.floatValue,0.0f,1.0f);
					sp_VibranceBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Vibrance Mix","How to mix the Vibrance"),sp_VibranceBlend.floatValue,0.0f,1.0f);
				}

				if(sp_MixMode.intValue == 2)
				{
					sp_RedBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Red Mix","How to mix the red"),sp_RedBlend.floatValue,0.0f,1.0f);
					sp_GreenBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Green Mix","How to mix the green"),sp_GreenBlend.floatValue,0.0f,1.0f);
					sp_BlueBlend.floatValue = EditorGUILayout.Slider(new GUIContent("Blue Mix","How to mix the blue"),sp_BlueBlend.floatValue,0.0f,1.0f);				
				}
			}
			EditorGUILayout.LabelField("");
			sp_MasterMix.floatValue = EditorGUILayout.Slider(new GUIContent("Master Mix","Overall color mixing"),sp_MasterMix.floatValue,0.0f,1.0f);



			if(EditorGUI.EndChangeCheck())
			{
				serializedObject.ApplyModifiedProperties();
			}
		}
	}
}
