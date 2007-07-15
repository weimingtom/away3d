package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Plane */ 
    public class Plane extends Mesh3D
    {
        public var segmentsW:int;
        public var segmentsH:int;
    
        public function Plane(material:IMaterial, init:Object = null)
        {
            super(material, init);
    
            init = Init.parse(init);

            width = init.getNumber("width", 0, {min:0});
            height = init.getNumber("height", 0, {min:0});
            var segments:int = init.getInt("segments", 1, {min:1});
            segmentsW = init.getInt("segmentsW", segments, {min:1});
            segmentsH = init.getInt("segmentsH", segments, {min:1});

            if (width*height == 0)
            {
                if (material is IUVMaterial)
                {
                    var uvm:IUVMaterial = material as IUVMaterial;
                    if (width == 0)
                        width = uvm.width;
                    if (height == 0)
                        height = uvm.height;
                }
                else
                {
                    width = 100;
                    height = 100;
                }
            }
            buildPlane();
        }
    
        private function buildPlane():void
        {
            for (var ix:int = 0; ix < segmentsW + 1; ix++)
                for (var iy:int = 0; iy < segmentsH + 1; iy++)
                    addVertex3D(new Vertex3D((ix / segmentsW - 0.5) * width, 0, (iy / segmentsH - 0.5) * height));

            for (ix = 0; ix < segmentsW; ix++)
                for (iy = 0; iy < segmentsH; iy++)
                {
                    var a:Vertex3D = vertices[ix     * (segmentsH + 1) + iy    ]; 
                    var b:Vertex3D = vertices[(ix+1) * (segmentsH + 1) + iy    ];
                    var c:Vertex3D = vertices[ix     * (segmentsH + 1) + (iy+1)]; 
                    var d:Vertex3D = vertices[(ix+1) * (segmentsH + 1) + (iy+1)];

                    var uva:NumberUV = new NumberUV(ix     / segmentsW, iy     / segmentsH);
                    var uvb:NumberUV = new NumberUV((ix+1) / segmentsW, iy     / segmentsH);
                    var uvc:NumberUV = new NumberUV(ix     / segmentsW, (iy+1) / segmentsH);
                    var uvd:NumberUV = new NumberUV((ix+1) / segmentsW, (iy+1) / segmentsH);

                    var face1:Face3D = addFace3D(new Face3D(a, b, c, null, uva, uvb, uvc));
                    var face2:Face3D = addFace3D(new Face3D(d, c, b, null, uvd, uvc, uvb));
                    face1.fixed = true;
                    face2.fixed = true;
                }
            
            surfaces = faces;
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsH + 1) + iy];
        }

    }
}
