package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    /** Skybox that is initialized with six images */ 
    public class Skybox extends Mesh3D
    {
        public function Skybox(front:ITriangleMaterial, left:ITriangleMaterial, back:ITriangleMaterial, right:ITriangleMaterial, up:ITriangleMaterial, down:ITriangleMaterial)
        {
            super(null, null);

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
            
            addFace3D(new Face3D(v000, v001, v010, back, uva, uvb, uvd));
            addFace3D(new Face3D(v010, v001, v011, back, uvd, uvb, uvc));
                                             
            addFace3D(new Face3D(v100, v110, v101, front, uvb, uvc, uva));
            addFace3D(new Face3D(v110, v111, v101, front, uvc, uvd, uva));
                                             
            addFace3D(new Face3D(v000, v100, v001, down, uva, uvb, uvd));
            addFace3D(new Face3D(v001, v100, v101, down, uvd, uvb, uvc));
                                                   
            addFace3D(new Face3D(v010, v011, v110,  up, uvd, uva, uvc));
            addFace3D(new Face3D(v011, v111, v110,  up, uva, uvb, uvc));

            addFace3D(new Face3D(v000, v010, v100, left, uvb, uvc, uva));
            addFace3D(new Face3D(v100, v010, v110, left, uva, uvc, uvd));
                                                                  
            addFace3D(new Face3D(v011, v001, v101, right, uvd, uva, uvb));
            addFace3D(new Face3D(v011, v101, v111, right, uvd, uvb, uvc));

            quarterFaces();
            quarterFaces();

        }
    }
    
}