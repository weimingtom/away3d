package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;

    public class Cube extends Mesh3D
    {
        public function Cube(material:IMaterial = null, width:Number = 50, height:Number = 50, depth:Number = 50, init:Object = null)
        {
            super(material, null, init);

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
            
            faces.push(new Face3D(v000, v010, v001, null, uva, uvd, uvb));
            faces.push(new Face3D(v010, v011, v001, null, uvd, uvc, uvb));

            faces.push(new Face3D(v100, v101, v110, null, uva, uvb, uvd));
            faces.push(new Face3D(v110, v101, v111, null, uvd, uvb, uvc));

            faces.push(new Face3D(v000, v001, v100, null, uva, uvd, uvb));
            faces.push(new Face3D(v001, v101, v100, null, uvd, uvc, uvb));
                                                
            faces.push(new Face3D(v010, v110, v011, null, uva, uvb, uvd));
            faces.push(new Face3D(v011, v110, v111, null, uvd, uvb, uvc));

            faces.push(new Face3D(v000, v100, v010, null, uva, uvd, uvb));
            faces.push(new Face3D(v100, v110, v010, null, uvd, uvc, uvb));
                                                  
            faces.push(new Face3D(v001, v011, v101, null, uva, uvb, uvd));
            faces.push(new Face3D(v101, v011, v111, null, uvd, uvb, uvc));
        }
    }
    
}