using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class GlobalShaderVariables : MonoBehaviour
{
    private void OnPreRender()
    {
        Shader.SetGlobalVector("_CamPos", this.transform.position);
        Shader.SetGlobalVector("_CamRight", this.transform.right);      // x Axis
        Shader.SetGlobalVector("_CamUp", this.transform.up);            // y Axis
        Shader.SetGlobalVector("_CamForward", this.transform.forward);  // z Axis

        Shader.SetGlobalFloat("_AspectRatio", (float)Screen.width / (float)Screen.height);
        Shader.SetGlobalFloat("_FieldOfView", Mathf.Tan(Camera.main.fieldOfView * Mathf.Deg2Rad * 0.5f) * 2f);
    }
}
