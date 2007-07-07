package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.geom.*;

    /** Cube */ 
    public class Cube extends Mesh
    {
        public function Cube(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var width:Number  = init.getNumber("width",  100, {min:0});
            var height:Number = init.getNumber("height", 100, {min:0});
            var depth:Number  = init.getNumber("depth",  100, {min:0});
            var faceMaterials:Array  = init.getArray("faceMaterials");

            var v000:Vertex = new Vertex(-width/2, -height/2, -depth/2); 
            var v001:Vertex = new Vertex(-width/2, -height/2, +depth/2); 
            var v010:Vertex = new Vertex(-width/2, +height/2, -depth/2); 
            var v011:Vertex = new Vertex(-width/2, +height/2, +depth/2); 
            var v100:Vertex = new Vertex(+width/2, -height/2, -depth/2); 
            var v101:Vertex = new Vertex(+width/2, -height/2, +depth/2); 
            var v110:Vertex = new Vertex(+width/2, +height/2, -depth/2); 
            var v111:Vertex = new Vertex(+width/2, +height/2, +depth/2); 

            var uva:UV = new UV(1, 1);
            var uvb:UV = new UV(0, 1);
            var uvc:UV = new UV(0, 0);
            var uvd:UV = new UV(1, 0);
            
            //left face
            addFace(new Face(v000, v010, v001, faceMaterials[0], uvd, uva, uvc));
            addFace(new Face(v010, v011, v001, faceMaterials[0], uva, uvb, uvc));
            //right face
            addFace(new Face(v100, v101, v110, faceMaterials[1], uvc, uvd, uvb));
            addFace(new Face(v110, v101, v111, faceMaterials[1], uvb, uvd, uva));
            //bottom face
            addFace(new Face(v000, v001, v100, faceMaterials[2], uvb, uvc, uva));
            addFace(new Face(v001, v101, v100, faceMaterials[2], uvc, uvd, uva));
            //top face
            addFace(new Face(v010, v110, v011, faceMaterials[3], uvc, uvd, uvb));
            addFace(new Face(v011, v110, v111, faceMaterials[3], uvb, uvd, uva));
            //front face
            addFace(new Face(v000, v100, v010, faceMaterials[4], uvc, uvd, uvb));
            addFace(new Face(v100, v110, v010, faceMaterials[4], uvd, uva, uvb));
            //back face
            addFace(new Face(v001, v011, v101, faceMaterials[5], uvd, uva, uvc));
            addFace(new Face(v101, v011, v111, faceMaterials[5], uvc, uva, uvb));
        }
    }
    
}