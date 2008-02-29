package away3d.objects
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.mesh.*;
    import away3d.core.stats.*;
    import away3d.core.utils.*;
    
    /** Cube */ 
    public class Cube extends Mesh
    {
        public function Cube(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);
			
			
            var size:Number  = init.getNumber("size", 100, {min:0});
            var width:Number  = init.getNumber("width",  size, {min:0});
            var height:Number = init.getNumber("height", size, {min:0});
            var depth:Number  = init.getNumber("depth",  size, {min:0});
            var faces:Init  = init.getInit("faces");
            
            buildCube(width, height, depth, faces);
        }
        
        public function buildCube(width:Number, height:Number, depth:Number, faces:Init):void
        {
            var left:ITriangleMaterial   = faces.getMaterial("left");
            var right:ITriangleMaterial  = faces.getMaterial("right");
            var bottom:ITriangleMaterial = faces.getMaterial("bottom");
            var top:ITriangleMaterial    = faces.getMaterial("top");
            var front:ITriangleMaterial  = faces.getMaterial("front");
            var back:ITriangleMaterial   = faces.getMaterial("back");

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
            addFace(new Face(v000, v010, v001, left, uvd, uva, uvc));
            addFace(new Face(v010, v011, v001, left, uva, uvb, uvc));
            //right face
            addFace(new Face(v100, v101, v110, right, uvc, uvd, uvb));
            addFace(new Face(v110, v101, v111, right, uvb, uvd, uva));
            //bottom face
            addFace(new Face(v000, v001, v100, bottom, uvb, uvc, uva));
            addFace(new Face(v001, v101, v100, bottom, uvc, uvd, uva));
            //top face
            addFace(new Face(v010, v110, v011, top, uvc, uvd, uvb));
            addFace(new Face(v011, v110, v111, top, uvb, uvd, uva));
            //front face
            addFace(new Face(v000, v100, v010, front, uvc, uvd, uvb));
            addFace(new Face(v100, v110, v010, front, uvd, uva, uvb));
            //back face
            addFace(new Face(v001, v011, v101, back, uvd, uva, uvc));
            addFace(new Face(v101, v011, v111, back, uvc, uva, uvb));
            
            type = "Cube";
        	url = "primitive";
        }
    } 
}