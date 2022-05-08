using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Texture3DCustom : MonoBehaviour
{

    // public attributes : we can change them in unity or specify them
    public Material mat;
    public float size = 0.5f;



    // private attributes : we don't need to take care of them
    private Texture3D tex;
    private Object[] cell;
    private TextAsset tracks;

    
   
    void LoadTexture()
    {
        cell = Resources.LoadAll("3DFilm", typeof(Texture3D));    
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
        // test du script
        size = 0.5f;  
        mat.SetFloat("_Size", size);

        // time interval between 2 images
        float frame_per_sec = 3;

        // on a dans le tableau cell toutes les images 
        // indexees de 0 a cell.Length-1
        float idx = (Time.time*frame_per_sec) % cell.Length;
        int index = (int)idx;
        tex = cell[index] as Texture3D;
        mat.SetTexture("_MainTex", tex);


        
    }


    
}