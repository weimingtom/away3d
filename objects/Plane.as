package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class Plane extends Mesh3D
    {
        public var segmentsW:Number;
        public var segmentsH:Number;
    
        public function Plane(material:IMaterial = null, width:Number = 0, height:Number = 0, segmentsW:Number = 0, segmentsH:Number = 0, init:Object = null)
        {
            super(material, null, init);
    
            this.segmentsW = segmentsW || 1;
            this.segmentsH = segmentsH || this.segmentsW;
    
            var scale:Number = 1;
    
            if (!height)
            {
                if (width)
                    scale = width;
    
                if (material is IUVMaterial)
                {
                	var uvm:IUVMaterial = material as IUVMaterial;
	                width  = uvm.width * scale;
    	            height = uvm.height * scale;
                }
                else
                {
        	        width  = 500 * scale;
            	    height = 500 * scale;
                }
            }
    
            buildPlane(width, height);
        }
    
        private function buildPlane(width:Number, height:Number):void
        {
            for (var ix:int = 0; ix < segmentsW + 1; ix++)
                for (var iy:int = 0; iy < segmentsH + 1; iy++)
                    this.vertices.push(new Vertex3D((ix / segmentsW - 0.5) * width, 0, (iy / segmentsH - 0.5) * height));

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

                    this.faces.push(new Face3D(a, b, c, null, uva, uvb, uvc));
                    this.faces.push(new Face3D(d, c, b, null, uvd, uvc, uvb));
                }
        }

        public function vertice(ix:int, iy:int):Vertex3D
        {
            return vertices[ix * (segmentsH + 1) + iy];
        }

    }
}
