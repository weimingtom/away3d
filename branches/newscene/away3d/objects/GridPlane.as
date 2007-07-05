package away3d.objects
{
    import away3d.core.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Grid plane */ 
    public class GridPlane extends Mesh3D
    {
        public var segmentsW:int = 1;
        public var segmentsH:int = 1;
    
        public function GridPlane(material:ISegmentMaterial, init:Object = null)
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
    
        private function buildPlane():void
        {
            for (var ix:int = 0; ix <= segmentsW; ix++)
            {
                var a:Vertex3D = new Vertex3D((ix / segmentsW - 0.5) * width, 0,  - 0.5 * height);
                var b:Vertex3D = new Vertex3D((ix / segmentsW - 0.5) * width, 0,    0.5 * height);

                vertices.push(a);
                vertices.push(b);
                segments.push(new Segment3D(a, b));
            }

            for (var iy:int = 0; iy <= segmentsH; iy++)
            {
                var c:Vertex3D = new Vertex3D( -0.5 * width, 0, (iy / segmentsH - 0.5) * height);
                var d:Vertex3D = new Vertex3D(  0.5 * width, 0, (iy / segmentsH - 0.5) * height);

                vertices.push(c);
                vertices.push(d);
                segments.push(new Segment3D(c, d));
            }
        }
    }
}
