package away3d.objects
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class GridPlane extends Mesh3D
    {
        public var segmentsW:int = 1;
        public var segmentsH:int = 1;
    
        public function GridPlane(material:IMaterial, init:Object = null)
        {
            super(material, init);
            
    		if (init != null)
            {
            	width = init.width || 50;
            	height = init.height || 50;
            	segmentsW = init.segmentsW || segmentsW;
            	segmentsH = init.segmentsH || segmentsW;
            }
    
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
    
        private function buildPlane(width:Number, height:Number):void
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
