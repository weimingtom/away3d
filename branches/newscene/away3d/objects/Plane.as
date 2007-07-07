package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Plane */ 
    public class Plane extends Mesh
    {
        public function Plane(init:Object = null)
        {
            super(init);
    
            init = Init.parse(init);

            var width:Number = init.getNumber("width", 0, {min:0});
            var height:Number = init.getNumber("height", 0, {min:0});
            var segments:int = init.getInt("segments", 1, {min:1});
            var segmentsW:int = init.getInt("segmentsW", segments, {min:1});
            var segmentsH:int = init.getInt("segmentsH", segments, {min:1});

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
            buildPlane(width, height, segmentsW, segmentsH);
        }
    
        private var buildvertices:Array = [];

        private function buildPlane(width:Number, height:Number, segmentsW:int, segmentsH:int):void
        {
            buildvertices = [];
            for (var i:int = 0; i < segmentsW + 1; i++)
            {
                buildvertices[i] = [];
                for (var j:int = 0; j < segmentsH + 1; j++)
                    buildvertices[i][j] = new Vertex((i / segmentsW - 0.5) * width, 0, (j / segmentsH - 0.5) * height);
            }

            for (i = 0; i < segmentsW; i++)
                for (j = 0; j < segmentsH; j++)
                {
                    var a:Vertex = buildvertices[i  ][j  ]; 
                    var b:Vertex = buildvertices[i+1][j  ];
                    var c:Vertex = buildvertices[i  ][j+1]; 
                    var d:Vertex = buildvertices[i+1][j+1];

                    var uva:UV = new UV(i     / segmentsW, j     / segmentsH);
                    var uvb:UV = new UV((i+1) / segmentsW, j     / segmentsH);
                    var uvc:UV = new UV(i     / segmentsW, (j+1) / segmentsH);
                    var uvd:UV = new UV((i+1) / segmentsW, (j+1) / segmentsH);

                    addFace(new Face(a, b, c, null, uva, uvb, uvc));
                    addFace(new Face(d, c, b, null, uvd, uvc, uvb));
                }
        }

        public function vertex(i:int, j:int):Vertex
        {
            return buildvertices[i][j];
        }

    }
}
