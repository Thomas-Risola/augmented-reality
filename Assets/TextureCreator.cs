using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class TextureCreator : MonoBehaviour
{
    public void CreateTexture3D(string output, string basename, int size, int zeropad)
    {

        for(int t=1; t<31; t++)

        {
            int k = 1;

            string basenameTime;
            if (t <10)
                basenameTime = basename + "000" + t.ToString()  + "_z";
            else
                basenameTime = basename + "00" + t.ToString()  + "_z";

            name = basenameTime + k.ToString().PadLeft(zeropad, '0');
    
            Texture2D img = Resources.Load<Texture2D>(name);


            int width = img.width;
            int height = img.height;

            Texture3D tex = new Texture3D(width, height, size, TextureFormat.RGBA32, false);
            tex.wrapMode = TextureWrapMode.Clamp;

            for(int z=1; z < size+1; z++)
            {
                name = basenameTime + z.ToString().PadLeft(zeropad, '0');
                // Debug.Log(name);
                img = Resources.Load<Texture2D>(basenameTime + z.ToString().PadLeft(zeropad, '0'));
                for (int y=0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        tex.SetPixel(x, y, z-1, img.GetPixel(x, y));
                    }
                }
            }

            tex.Apply();
            string outputName = output + t.ToString()  + "_tex3D.asset";
            UnityEditor.AssetDatabase.CreateAsset(tex, outputName);
        }
    }

    // Start is called before the first frame update
    void Start()
    {
        // Args : 
        // - path to the output file
        // - path to the 2D textures (needs to be in the Resources folder), only the base name (not the file number) + remember to set the textures readable in Unity interface
        // - number of images to read (counter from 0 to size-1)
        // - zero padding size
        CreateTexture3D("Assets/Cell03_09042021_frame", "AllFrames/Cell03_09042021_CellMaskDeepRed_Decon_t", 50, 4);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
