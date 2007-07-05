package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.math.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.geom.*;

    /** Cube that utilities TransformBitmapMaterial */
    public class RobCube extends Mesh3D
    {
        public var faceMaterials:Array = [];
        
        public function RobCube(material:IMaterial, init:Object = null)
        {
            super(material, init);
            
            init = Init.parse(init);

            width  = init.getNumber("width", 100, {min:0});
            height = init.getNumber("height", 100, {min:0});
            depth  = init.getNumber("depth", 100, {min:0});
            faceMaterials  = init.getArray("faceMaterials");

            var v000:Vertex3D = new Vertex3D(-width/2, -height/2, -depth/2); 
            var v001:Vertex3D = new Vertex3D(-width/2, -height/2, +depth/2); 
            var v010:Vertex3D = new Vertex3D(-width/2, +height/2, -depth/2); 
            var v011:Vertex3D = new Vertex3D(-width/2, +height/2, +depth/2); 
            var v100:Vertex3D = new Vertex3D(+width/2, -height/2, -depth/2); 
            var v101:Vertex3D = new Vertex3D(+width/2, -height/2, +depth/2); 
            var v110:Vertex3D = new Vertex3D(+width/2, +height/2, -depth/2); 
            var v111:Vertex3D = new Vertex3D(+width/2, +height/2, +depth/2); 

            vertices.push(v000);
            vertices.push(v001);
            vertices.push(v010);
            vertices.push(v011);
            vertices.push(v100);
            vertices.push(v101);
            vertices.push(v110);
            vertices.push(v111);
            
            var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
            var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
            var mat:TransformBitmapMaterial = material as TransformBitmapMaterial;
            var isTransform:Boolean = material is TransformBitmapMaterial;
            var trans:Matrix = (isTransform)? mat.getTransform(width, height) : new Matrix();
            var isNormalized:Boolean = (isTransform)? mat.isNormalized : false;
            var t1:Point = new Point();
            var t2:Point = new Point();
            var t3:Point = new Point();
            var t4:Point = new Point();
            var test1:Point = new Point(1,1);
            var test2:Point = new Point(0,1);
            var test3:Point = new Point(0,0);
            var test4:Point = new Point(1,0);
            
            var iFaces:Array = [{a:v011, b:v001, c:v000, d:v010},
                                {a:v100, b:v101, c:v111, d:v110},
                                {a:v101, b:v100, c:v000, d:v001},
                                {a:v010, b:v110, c:v111, d:v011},
                                {a:v110, b:v010, c:v000, d:v100},
                                {a:v001, b:v011, c:v111, d:v101}];
            var face:Object;
            var tDiffx:Number, tDiffy:Number;
            var iFaceNum:Number = iFaces.length;
            
            for (var i:Number=0;i<iFaceNum;i++) {
                face = iFaces[i];
                aP1 = face.a;
                aP2 = face.b;
                aP3 = face.c;
                aP4 = face.d;
                if (faceMaterials[i]) {
                    isTransform = faceMaterials[i] is TransformBitmapMaterial;
                    mat = faceMaterials[i] as TransformBitmapMaterial;
                    if (isTransform) {
                        trans = mat.getTransform(width, height);
                        isNormalized = mat.isNormalized;
                    } else {
                        isNormalized = false;
                    }
                } else if (mat != material) {
                    isTransform = material is TransformBitmapMaterial;
                    mat = material as TransformBitmapMaterial;
                    if (isTransform) {
                        trans = mat.getTransform(width, height);
                        isNormalized = mat.isNormalized;
                    } else {
                        isNormalized = false;
                    } 
                }
                if (isNormalized) {
                    mat.setUVPoint(t1, aP1);
                    mat.setUVPoint(t2, aP2);
                    mat.setUVPoint(t3, aP3);
                    mat.setUVPoint(t4, aP4);
                } else if (isTransform) {
                    t1.x = width;
                    t1.y = height;
                    t2.x = 0;
                    t2.y = height;
                    t3.x = 0;
                    t3.y = 0;
                    t4.x = width;
                    t4.y = 0;
                } else {
                    t1.x = 1;
                    t1.y = 1;
                    t2.x = 0;
                    t2.y = 1;
                    t3.x = 0;
                    t3.y = 0;
                    t4.x = 1;
                    t4.y = 0;
                }
                if (isTransform) {
                    t1 = trans.transformPoint(t1);
                    t2 = trans.transformPoint(t2);
                    t3 = trans.transformPoint(t3);
                    t4 = trans.transformPoint(t4);                  
                    if (mat.repeat) {
                        tDiffx = t1.x - (t1.x %= 1);
                        tDiffy = t1.y - (t1.y %= 1);
                        t2.x -= tDiffx;
                        t2.y -= tDiffy;
                        t3.x -= tDiffx;
                        t3.y -= tDiffy;
                        t4.x -= tDiffx;
                        t4.y -= tDiffy;
                    }
                }
                aP1uv = new NumberUV(t1.x,t1.y);
                aP2uv = new NumberUV(t2.x,t2.y);
                aP3uv = new NumberUV(t3.x,t3.y);
                aP4uv = new NumberUV(t4.x,t4.y);
                if ((isTransform && mat.repeat) || insideShape([test1,test2,test3,test4], [t1,t2,t4])) {
                    faces.push(new Face3D(aP1, aP2, aP4, mat as ITriangleMaterial, aP1uv, aP2uv, aP4uv));
                }
                if ((isTransform && mat.repeat) || insideShape([test1,test2,test3,test4], [t3,t4,t2])) {
                    faces.push(new Face3D(aP3, aP4, aP2, mat as ITriangleMaterial, aP3uv, aP4uv, aP2uv));
                }
            }
            /*
            //left face
            faces.push(new Face3D(v011, v001, v010, faceMaterials[0], t1, t2, t4));
            faces.push(new Face3D(v000, v010, v001, faceMaterials[0], t3, t4, t2));
            //right face
            faces.push(new Face3D(v100, v101, v110, faceMaterials[1], t1, t2, t4));
            faces.push(new Face3D(v111, v110, v101, faceMaterials[1], t3, t4, t2));
            //bottom face
            faces.push(new Face3D(v101, v100, v001, faceMaterials[2], t1, t2, t4));
            faces.push(new Face3D(v000, v001, v100, faceMaterials[2], t3, t4, t2));
            //top face
            faces.push(new Face3D(v010, v110, v011, faceMaterials[3], t1, t2, t4));
            faces.push(new Face3D(v111, v011, v110, faceMaterials[3], t3, t4, t2));
            //front face
            faces.push(new Face3D(v110, v010, v100, faceMaterials[4], t1, t2, t4));
            faces.push(new Face3D(v000, v100, v010, faceMaterials[4], t3, t4, t2));
            //back face
            faces.push(new Face3D(v001, v011, v101, faceMaterials[5], t1, t2, t4));
            faces.push(new Face3D(v111, v101, v011, faceMaterials[5], t3, t4, t2));
            */
        }
    }
    
}