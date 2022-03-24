Shader "Unlit/Ray Marching"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _Size ("Size", Range (0, 1)) = .5
        _Radius("Radius", Range(0, 1)) = .5
        _Tol("Tol", Range(0, 1)) = 0
        _Arc("Arc", Range(-.5,.5)) = 0
        _Stretching("Stretching", Range(0.1, 2)) = 1
    }
    SubShader
    {
        Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            #include "UnityCG.cginc"

#define MAX_STEPS 100
#define MAX_DIST 100
#define SURF_DIST 1e-3
#define pi 3.141592653589793238462
#define epsilon 1e-5

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 ro : TEXCOORD1;
                float3 hitPos : TEXCOORD2;
            };


            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            float _Size;
            float _Radius;
            float _Tol;
            float _Arc;
            float _Stretching;
            


            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.ro = _WorldSpaceCameraPos;
                o.hitPos = v.vertex;

                return o;
            }

            float Cylinder(float3 p, float3 a, float3 b, float r){
                float3 ab = b - a;
                float3 ap = p - a;

                float t = dot(ab, ap) / dot(ab, ab);

                float3 c = a + t*ab;

                float x = length(p-c)-r;
                float y = (abs(t-.5)-.5)*length(ab);
                float e = length(max(float2(x, y), 0.));
                float i = min(max(x, y), 0.);

                return e+i;
            }

            float OpenCylinder(float3 p, float3 a, float3 b, float r){
                float3 ab = b - a;
                float3 ap = p - a;

                float t = dot(ab, ap) / dot(ab, ab);

                float3 c = a + t*ab;

                float x = abs(length(p-c)-r);
                float y = (abs(t-.5)-.5)*length(ab);
                float e = length(max(float2(x, y), 0.));
                float i = min(max(x, y), 0.);

                return e+i;
            }

            float OpenPartialCylinder(float3 p, float3 a, float3 b, float r, float arc){
                float3 ab = b - a;
                float3 ap = p - a;

                float3 n = normalize(float3( -ab.y, ab.x, 0)); // Changement de 3.14/2 à 100*pi

                float orientation = -dot(n, ap); // Changement de signe pour l'orientation du cylindre

                float t = dot(ab, ap) / dot(ab, ab);

                float3 c = a + t*ab;

                float x = max(abs(length(p-c)-r),orientation + arc);
                float y = (abs(t-.5)-.5)*length(ab);
                float e = length(max(float2(x, y), 0.));
                float i = min(max(x, y), 0.);

                return e+i;
            }

            float Cube(float3 p, float3 s){
                p = abs(p)-s;

                return length(max(p, 0.))+min(max(p.x, max(p.y, p.z)), 0.);
            }


            float GetDist(float3 p) {
                // for a sphere
                // float d = length(p) - .5;

                // for a cylinder
                float d = OpenPartialCylinder(p, float3(0,_Size,0), float3(0,-_Size,0), _Radius, _Arc);

                // for a cube
                //float d = Cube(p, float3(1,1,1)) ;
                

                return d;
            }

            // Rajout pour modéliser le cylindre transparent
            float GetDist_Cylinder(float3 p) {
                float d = Cylinder(p, float3(0,_Size,0), float3(0,-_Size,0), _Radius);
                return d;
            }

            float3 GetNormal(float3 p) {
                float2 e = float2(1e-2, 0);
                float3 n = GetDist(p) - float3(
                    GetDist(p-e.xyy),
                    GetDist(p-e.yxy),
                    GetDist(p-e.yyx) 
                );
                return normalize(n);
            }
            
            // Modif pour avoir le RM pour le semii-cylindre et le cylindre
            float2 Raymarch(float3 ro, float3 rd) {
                float dO_partial = 0;
                float dO_cylinder = 0;
                float dS_partial;
                float dS_cylinder;
                for (int i = 0; i < MAX_STEPS; i++){
                    float3 p_partial = ro + dO_partial * rd;
                    float3 p_cylinder = ro + dO_cylinder * rd;
                    dS_partial = GetDist(p_partial);
                    dS_cylinder = GetDist_Cylinder(p_cylinder);
                    dO_partial += dS_partial;
                    dO_cylinder += dS_cylinder;
                    if ((dS_partial < SURF_DIST || dO_partial > MAX_DIST) && (dS_cylinder < SURF_DIST || dO_cylinder > MAX_DIST)) break;
                }

                return float2(dO_partial, dO_cylinder);
            }

            // Conversion de cartésien à cylindrique 
            float3 Cart_To_Cyl(float3 p) {
                float r = _Radius;
                float theta = acos(_Stretching*p.z/r);
                return float3(r, theta/pi, p.y);
            }


            fixed4 DiscardBlack(fixed4 col) {
                if (col.r < _Tol && col.g < _Tol && col.b < _Tol)
                    col = fixed4(0.1, 0.1, 0.1, 0.1);
                return col;
            }

            fixed4 VanishingBlack(fixed4 col){
                if (col.r < _Tol && col.g < _Tol && col.b < _Tol)
                    col = fixed4(0.1, 0.1, 0.1, 0.1);
                col = fixed4(col.r, col.g, col.b, max(0.4+(col.r+col.g+col.b)/3.,0.4));
                return col;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                
                float2 uv = i.uv - .5;
                float3 ro = i.ro; // float3(0, 0, -3);
                float3 rd = normalize(i.hitPos-ro); // normalize(float3(uv.x, uv.y, 1));


                float2 d = Raymarch(ro, rd);
                float d_partial = d.x;
                float d_cylinder = d.y;
                

 
                // sample the texture
                fixed4 col = fixed4(0,0,0,0);
                float m = dot(uv, uv);
                if (d_partial >= MAX_DIST) {
                    if (d_cylinder >= MAX_DIST)
                        discard;
                    else 
                        // col = fixed4(1,1,1,1);
                        discard;
                }
                
                else {
                    float3 p = ro + rd * d_partial;
                    float3 n = GetNormal(p);
                    float3 p_cyl = Cart_To_Cyl(p);

                    // float dif = dot(n, normalize(float3(1,2,3)))*.5+.5;
                    //col += dif*dif;
                    //float3 colXZ = tex2D(_MainTex, p.xz*.5+.5).rgb;
                    //float3 colYZ = tex2D(_MainTex, p.yz*.5+.5).rgb;
                    //float3 colXY = tex2D(_MainTex, p.xy*.5+.5).rgb;
                    // n = abs(n);
                    // col.rgb = colYZ*n.x + colXZ*n.y + colXY*n.z ;
                    //col.rgb = colXY*n.z + colYZ*n.x; 
                    //col = tex2D(_MainTex, i.uv);

                    col = tex2D(_MainTex, p_cyl.yz-float2(0,_Size));
                    //if (abs(p_cyl.y+.5) <= 1e-3)
                    //    col = tex2D(_MainTex, float2(-.48,p_cyl.z)-float2(0,_Size));
                    //col = float4(p_cyl.y+1.5, 0, 0, 1.);
                    
                    col = VanishingBlack(col);

                   
                }
                
                //col += smoothstep(.1, .2, m);
                

                return col;
            }
            ENDCG
        }
    }
}
