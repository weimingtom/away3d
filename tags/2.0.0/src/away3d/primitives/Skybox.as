package away3d.primitives
{
    import away3d.core.*;
    import away3d.core.base.*
    import away3d.core.base.*;
    import away3d.materials.*;
    import away3d.core.utils.*;
	import away3d.core.stats.*;

    /** Skybox that is initialized with six images */ 
    public class Skybox extends Mesh
    {
        public function Skybox(front:ITriangleMaterial, left:ITriangleMaterial, back:ITriangleMaterial, right:ITriangleMaterial, up:ITriangleMaterial, down:ITriangleMaterial)
        {
            super();

            var width:Number = 800000;
            var height:Number = 800000;
            var depth:Number = 800000;

            var v000:Vertex = new Vertex(-width/2, -height/2, -depth/2); 
            var v001:Vertex = new Vertex(-width/2, -height/2, +depth/2); 
            var v010:Vertex = new Vertex(-width/2, +height/2, -depth/2); 
            var v011:Vertex = new Vertex(-width/2, +height/2, +depth/2); 
            var v100:Vertex = new Vertex(+width/2, -height/2, -depth/2); 
            var v101:Vertex = new Vertex(+width/2, -height/2, +depth/2); 
            var v110:Vertex = new Vertex(+width/2, +height/2, -depth/2); 
            var v111:Vertex = new Vertex(+width/2, +height/2, +depth/2); 

            var uva:UV = new UV(1, 0);
            var uvb:UV = new UV(0, 0);
            var uvc:UV = new UV(0, 1);
            var uvd:UV = new UV(1, 1);

            addFace(new Face(v000, v001, v010, back, uva, uvb, uvd));
            addFace(new Face(v010, v001, v011, back, uvd, uvb, uvc));
                                           
            addFace(new Face(v100, v110, v101, front, uvb, uvc, uva));
            addFace(new Face(v110, v111, v101, front, uvc, uvd, uva));
                                           
            addFace(new Face(v000, v100, v001, down, uvb, uvc, uva));
            addFace(new Face(v001, v100, v101, down, uva, uvc, uvd));
                                                 
            addFace(new Face(v010, v011, v110,  up, uvc, uvd, uvb));
            addFace(new Face(v011, v111, v110,  up, uvd, uva, uvb));

            addFace(new Face(v000, v010, v100, left, uvb, uvc, uva));
            addFace(new Face(v100, v010, v110, left, uva, uvc, uvd));
                                                                
            addFace(new Face(v011, v001, v101, right, uvd, uva, uvb));
            addFace(new Face(v011, v101, v111, right, uvd, uvb, uvc));

            quarterFaces();
            quarterFaces();

            mouseEnabled = false;
			
			type = "Skybox";
        	url = "primitive";
        }
    }
    
}