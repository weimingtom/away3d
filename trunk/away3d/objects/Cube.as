package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    public class Cube extends Mesh3D
    {
    	public var faceMaterials:Array = [];
    	
        public function Cube(material:IMaterial, init:Object = null)
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
 
            var uva:NumberUV = new NumberUV(0, 0);
            var uvb:NumberUV = new NumberUV(1, 0);
            var uvc:NumberUV = new NumberUV(1, 1);
            var uvd:NumberUV = new NumberUV(0, 1);

            vertices.push(v000);
            vertices.push(v001);
            vertices.push(v010);
            vertices.push(v011);
            vertices.push(v100);
            vertices.push(v101);
            vertices.push(v110);
            vertices.push(v111);
            
            faces.push(new Face3D(v000, v010, v001, faceMaterials[0], uva, uvd, uvb));
            faces.push(new Face3D(v010, v011, v001, faceMaterials[0], uvd, uvc, uvb));

            faces.push(new Face3D(v100, v101, v110, faceMaterials[1], uva, uvb, uvd));
            faces.push(new Face3D(v110, v101, v111, faceMaterials[1], uvd, uvb, uvc));

            faces.push(new Face3D(v000, v001, v100, faceMaterials[2], uva, uvd, uvb));
            faces.push(new Face3D(v001, v101, v100, faceMaterials[2], uvd, uvc, uvb));
                                                
            faces.push(new Face3D(v010, v110, v011, faceMaterials[3], uva, uvb, uvd));
            faces.push(new Face3D(v011, v110, v111, faceMaterials[3], uvd, uvb, uvc));

            faces.push(new Face3D(v000, v100, v010, faceMaterials[4], uva, uvd, uvb));
            faces.push(new Face3D(v100, v110, v010, faceMaterials[4], uvd, uvc, uvb));
                                                  
            faces.push(new Face3D(v001, v011, v101, faceMaterials[5], uva, uvb, uvd));
            faces.push(new Face3D(v101, v011, v111, faceMaterials[5], uvd, uvb, uvc));
        }
    }
    
}