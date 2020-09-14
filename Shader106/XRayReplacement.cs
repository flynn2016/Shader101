using UnityEngine;
using System.Collections;
using System.Collections.Generic;

[ExecuteInEditMode]
public class XRayReplacement : MonoBehaviour
{
    public Shader XRayShader;

    void OnEnable()
    {
        GetComponent<Camera>().SetReplacementShader(XRayShader, "XRay");
    }
}