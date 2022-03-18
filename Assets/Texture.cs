using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Texture : MonoBehaviour
{

    public Material mat;
    public float size = 0.5f;


    public Texture2D tex;

    //int compteur = 1;
    
   

    // Start is called before the first frame update
    void Start()
    {
        mat.SetFloat("_Size", size);
    }

    // Update is called once per frame
    void Update()
    {
        size = 0.5f;  //  / Time.time;
        mat.SetFloat("_Size", size);

        mat.SetTexture("_MainTex", tex);
        

        
        if (Time.time > 3){
            tex = Resources.Load("Textures/tracks_cylinder") as Texture2D;
            mat.SetTexture("_MainTex", tex);
        }
    }


    
}