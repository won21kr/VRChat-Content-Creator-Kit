using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

#if UNITY_EDITOR
[InitializeOnLoad]
class VisemeFix {
    
    static VisemeFix() {

        Debug.Log("VisemeFix: Fixing VRCSDK files..");
        
        string copyFrom = null;
        IEnumerable<string> fixedFile = Directory.GetFiles(Application.dataPath, "VRCAvatarDescriptorEditor.fixed", SearchOption.AllDirectories);
        foreach (string file in fixedFile) {
            copyFrom = file;
            break;
        }

        if (copyFrom == null) {
            Debug.Log("VisemeFix: Fixed file could not be found!");
            return;
        }

        IEnumerable<string> fileList = Directory.GetFiles(Application.dataPath, "VRCAvatarDescriptorEditor.cs", SearchOption.AllDirectories);

        int files_found_count = 0;
        foreach (string copyTo in fileList) {
            Debug.Log("Fixing " + copyTo);

            FileUtil.ReplaceFile(copyFrom, copyTo);
            files_found_count++;
        }

        if (files_found_count == 0) {
            Debug.Log("VisemeFix: No VRCSDK found!");
            return;
        }

        AssetDatabase.Refresh();
        Debug.Log("VisemeFix: Fixing successfull, reloading now!");
    }

}
#endif