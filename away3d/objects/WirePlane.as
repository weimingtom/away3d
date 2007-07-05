package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Wire plane */ 
    public class WirePlane extends Mesh3D
    {
        public var segmentsW:int = 1;
        public var segmentsH:int = 1;
    
        public function WirePlane(material:ISegmentMaterial, init:Object = null)
        {
            super(material, init);
            
            init = Init.parse(init);

            width = init.getNumber("width", 100, {min:0});
            height = init.getNumber("height", 100, {min:0});
            var segments:int = init.getInt("segments", 1, {min:1});
            segmentsW = init.getInt("segmentsW", segments, {min:1});
            segmentsH = init.getInt("segmentsH", segments, {min:1});
    
            buildPlane();
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsH + 1) + iy];
        }

        private function buildPlane():void
        {
            for (var ix:int = 0; ix < segmentsW + 1; ix++)
                for (var iy:int = 0; iy < segmentsH + 1; iy++)
                    vertices.push(new Vertex3D((ix / segmentsW - 0.5) * width, 0, (iy / segmentsH - 0.5) * height));

            for (ix = 0; ix < segmentsW; ix++)
                for (iy = 0; iy < segmentsH + 1; iy++)
                {
                    var a:Vertex3D = vertices[ix     * (segmentsH + 1) + iy    ]; 
                    var b:Vertex3D = vertices[(ix+1) * (segmentsH + 1) + iy    ];

                    segments.push(new Segment3D(a, b));
                }

            for (ix = 0; ix < segmentsW + 1; ix++)
                for (iy = 0; iy < segmentsH; iy++)
                {
                    var c:Vertex3D = vertices[ix * (segmentsH + 1) + iy    ]; 
                    var d:Vertex3D = vertices[ix * (segmentsH + 1) + (iy+1)];

                    segments.push(new Segment3D(c, d));
                }
        }
    }
}
