package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class WirePlane extends Mesh3D
    {
        public var segmentsW:Number;
        public var segmentsH:Number;
    
        public function WirePlane(material:IMaterial = null, width:Number = 0, height:Number = 0, segmentsW:Number = 0, segmentsH:Number = 0, init:Object = null)
        {
            super(material, null, init);
    
            this.segmentsW = segmentsW || 1;
            this.segmentsH = segmentsH || this.segmentsW;
    
            var scale:Number = 1;
    
            if (!height)
            {
                if (width)
                    scale = width;
    
                width  = 500 * scale;
                height = 500 * scale;
            }
    
            buildPlane(width, height);
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsH + 1) + iy];
        }

        private function buildPlane(width:Number, height:Number):void
        {
            for (var ix:int = 0; ix < segmentsW + 1; ix++)
                for (var iy:int = 0; iy < segmentsH + 1; iy++)
                    this.vertices.push(new Vertex3D((ix / segmentsW - 0.5) * width, 0, (iy / segmentsH - 0.5) * height));

            for (ix = 0; ix < segmentsW; ix++)
                for (iy = 0; iy < segmentsH + 1; iy++)
                {
                    var a:Vertex3D = vertices[ix     * (segmentsH + 1) + iy    ]; 
                    var b:Vertex3D = vertices[(ix+1) * (segmentsH + 1) + iy    ];

                    this.segments.push(new Segment3D(a, b));
                }

            for (ix = 0; ix < segmentsW + 1; ix++)
                for (iy = 0; iy < segmentsH; iy++)
                {
                    var c:Vertex3D = vertices[ix * (segmentsH + 1) + iy    ]; 
                    var d:Vertex3D = vertices[ix * (segmentsH + 1) + (iy+1)];

                    this.segments.push(new Segment3D(c, d));
                }
        }
    }
}
