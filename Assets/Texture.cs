using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Texture : MonoBehaviour
{

    // public attributes : we can change them in unity or specify them
    public Material mat;
    public float size = 0.5f;



    // private attributes : we don't need to take care of them
    private Texture2D tex;
    private Object[] cell;
    private TextAsset tracks;
    private LineRenderer lr;

    
   
    void LoadTexture()
    {
        cell = Resources.LoadAll("Tracks/images", typeof(Texture2D));    
    }

    void LoadTracks()
    {
        tracks = Resources.Load("Tracks/3DTracks") as TextAsset; 
    }

    // Start is called before the first frame update
    void Start()
    {
        mat.SetFloat("_Size", size);
        LoadTexture();
        LoadTracks();
        lr = GetComponent<LineRenderer>();
    }

    // Update is called once per frame
    void Update()
    {
        // test du script
        size = 0.5f;  
        mat.SetFloat("_Size", size);

        // time interval between 2 images
        float frame_per_sec = 15;

        // on a dans le tableau cell toutes les images 
        // indexees de 0 a cell.Length-1
        float idx = (Time.time*frame_per_sec) % cell.Length;
        int index = (int)idx;
        tex = cell[index] as Texture2D;
        mat.SetTexture("_MainTex", tex);

        // create line for tracks
        lr.positionCount = 2;
        UnityEngine.Vector3 tab1 = new Vector3(0, 0, 0);
        UnityEngine.Vector3 tab2 = new Vector3(1, 1, 1);
        
        lr.SetPosition(0, tab1);
        lr.SetPosition(1, tab2);

        
    }


    
}