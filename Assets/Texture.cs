using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Texture : MonoBehaviour
{

    public Material mat;
    public float size = 0.5f;


    public Texture2D tex;

    private Object[] cell;

    //int compteur = 1;
    
   
    void LoadTexture()
    {
        cell = Resources.LoadAll("Tracks/images", typeof(Texture2D));    
    }

    // Start is called before the first frame update
    void Start()
    {
        mat.SetFloat("_Size", size);
        LoadTexture();
    }

    // Update is called once per frame
    void Update()
    {
        size = 0.5f;  //  / Time.time;
        mat.SetFloat("_Size", size);

        // time interval between 2 images
        float frame_per_sec = 15;

        // on a dans le tableau cell toutes les images 
        // 
        float idx = (Time.time*frame_per_sec) % cell.Length;
        int index = (int)idx;
        tex = cell[index] as Texture2D;
        mat.SetTexture("_MainTex", tex);
        
    }


    
}