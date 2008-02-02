package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
	import away3d.core.stats.*;
    
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
    
        private var grid:Array;

        private function buildPlane(width:Number, height:Number, segmentsW:int, segmentsH:int):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsW+1);
            for (i = 0; i <= segmentsW; i++)
            {
                grid[i] = new Array(segmentsH+1);
                for (j = 0; j <= segmentsH; j++)
                    grid[i][j] = new Vertex((i / segmentsW - 0.5) * width, 0, (j / segmentsH - 0.5) * height);
            }

            for (i = 0; i < segmentsW; i++)
                for (j = 0; j < segmentsH; j++)
                {
                    var a:Vertex = grid[i  ][j  ]; 
                    var b:Vertex = grid[i+1][j  ];
                    var c:Vertex = grid[i  ][j+1]; 
                    var d:Vertex = grid[i+1][j+1];

                    var uva:UV = new UV(i     / segmentsW, j     / segmentsH);
                    var uvb:UV = new UV((i+1) / segmentsW, j     / segmentsH);
                    var uvc:UV = new UV(i     / segmentsW, (j+1) / segmentsH);
                    var uvd:UV = new UV((i+1) / segmentsW, (j+1) / segmentsH);

                    addFace(new Face(a, b, c, null, uva, uvb, uvc));
                    addFace(new Face(d, c, b, null, uvd, uvc, uvb));
                }
				
			type = "Plane";
        	url = "primitive";
        }

        public function vertex(i:int, j:int):Vertex
        {
            return grid[i][j];
        }

    }
}
