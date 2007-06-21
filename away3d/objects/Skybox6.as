package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    /** Skybox that is initialized with one solid image */ 
    public class Skybox6 extends Mesh3D
    {
        public function Skybox6(petermaterial:ITriangleMaterial)
        {
            super(petermaterial, null);

            var udelta:Number = 1 / 600;
            var vdelta:Number = 1 / 400;

            if (petermaterial is IUVMaterial)
            {
                var uvm:IUVMaterial = petermaterial as IUVMaterial;
                udelta = 1 / uvm.width;
                vdelta = 1 / uvm.height;
            }

            var width:Number = 800000;
            var height:Number = 800000;
            var depth:Number = 800000;

            var v000:Vertex3D = new Vertex3D(-width/2, -height/2, -depth/2); 
            var v001:Vertex3D = new Vertex3D(-width/2, -height/2, +depth/2); 
            var v010:Vertex3D = new Vertex3D(-width/2, +height/2, -depth/2); 
            var v011:Vertex3D = new Vertex3D(-width/2, +height/2, +depth/2); 
            var v100:Vertex3D = new Vertex3D(+width/2, -height/2, -depth/2); 
            var v101:Vertex3D = new Vertex3D(+width/2, -height/2, +depth/2); 
            var v110:Vertex3D = new Vertex3D(+width/2, +height/2, -depth/2); 
            var v111:Vertex3D = new Vertex3D(+width/2, +height/2, +depth/2); 

            var uvrighta:NumberUV = new NumberUV(0/3, 1/2+vdelta);
            var uvrightb:NumberUV = new NumberUV(1/3, 1/2+vdelta);
            var uvrightc:NumberUV = new NumberUV(1/3, 2/2);
            var uvrightd:NumberUV = new NumberUV(0/3, 2/2);

            var uvfronta:NumberUV = new NumberUV(1/3, 1/2+vdelta);
            var uvfrontb:NumberUV = new NumberUV(2/3, 1/2+vdelta);
            var uvfrontc:NumberUV = new NumberUV(2/3, 2/2);
            var uvfrontd:NumberUV = new NumberUV(1/3, 2/2);

            var uvlefta:NumberUV = new NumberUV(2/3, 1/2+vdelta);
            var uvleftb:NumberUV = new NumberUV(3/3, 1/2+vdelta);
            var uvleftc:NumberUV = new NumberUV(3/3, 2/2);
            var uvleftd:NumberUV = new NumberUV(2/3, 2/2);

            var uvbacka:NumberUV = new NumberUV(0/3, 0/2);
            var uvbackb:NumberUV = new NumberUV(1/3-udelta, 0/2);
            var uvbackc:NumberUV = new NumberUV(1/3-udelta, 1/2-vdelta);
            var uvbackd:NumberUV = new NumberUV(0/3, 1/2-0.001);

            var uvupa:NumberUV = new NumberUV(1/3+udelta, 0/2);
            var uvupb:NumberUV = new NumberUV(2/3-udelta, 0/2);
            var uvupc:NumberUV = new NumberUV(2/3-udelta, 1/2-vdelta);
            var uvupd:NumberUV = new NumberUV(1/3+udelta, 1/2-vdelta);

            var uvdowna:NumberUV = new NumberUV(2/3+udelta, 0/2);
            var uvdownb:NumberUV = new NumberUV(3/3, 0/2);
            var uvdownc:NumberUV = new NumberUV(3/3, 1/2-vdelta);
            var uvdownd:NumberUV = new NumberUV(2/3+udelta, 1/2-vdelta);
                                                            
            var uva:NumberUV = new NumberUV(0, 0);
            var uvb:NumberUV = new NumberUV(1, 0);
            var uvc:NumberUV = new NumberUV(1, 1);
            var uvd:NumberUV = new NumberUV(0, 1);

            addVertex3D(v000);
            addVertex3D(v001);
            addVertex3D(v010);
            addVertex3D(v011);
            addVertex3D(v100);
            addVertex3D(v101);
            addVertex3D(v110);
            addVertex3D(v111);

            addFace3D(new Face3D(v011, v001, v101, null, uvrightd, uvrighta, uvrightb));
            addFace3D(new Face3D(v011, v101, v111, null, uvrightd, uvrightb, uvrightc));

            addFace3D(new Face3D(v100, v110, v101, null, uvfrontb, uvfrontc, uvfronta));
            addFace3D(new Face3D(v110, v111, v101, null, uvfrontc, uvfrontd, uvfronta));

            addFace3D(new Face3D(v000, v010, v100, null, uvleftb, uvleftc, uvlefta));
            addFace3D(new Face3D(v100, v010, v110, null, uvlefta, uvleftc, uvleftd));

            addFace3D(new Face3D(v000, v001, v010, null, uvbacka, uvbackb, uvbackd));
            addFace3D(new Face3D(v010, v001, v011, null, uvbackd, uvbackb, uvbackc));

            addFace3D(new Face3D(v010, v011, v110, null, uvupb, uvupc, uvupa));
            addFace3D(new Face3D(v011, v111, v110, null, uvupc, uvupd, uvupa));

//            addFace3D(new Face3D(v000, v100, v001, null, uvdownc, uvdownd, uvdownb));
//            addFace3D(new Face3D(v001, v100, v101, null, uvdownb, uvdownd, uvdowna));

            addFace3D(new Face3D(v000, v100, v001, null, uvdowna, uvdownb, uvdownd));
            addFace3D(new Face3D(v001, v100, v101, null, uvdownd, uvdownb, uvdownc));

            quarterFaces();
            quarterFaces();

        }
    }
    
}