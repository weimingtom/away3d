package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
    import away3d.core.material.*;
    import away3d.core.utils.*;
    
    /** Torus */ 
    public class Torus extends Mesh
    {
        public function Torus(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var tube:Number = init.getNumber("tube", 40, {min:0, max:radius});
            var segmentsR:int = init.getInt("segmentsR", 8, {min:3});
            var segmentsT:int = init.getInt("segmentsT", 6, {min:3})

            buildTorus(radius, tube, segmentsR, segmentsT);
        }
    
        private var grid:Array;

        private function buildTorus(radius:Number, tube:Number, segmentsR:int, segmentsT:int):void
        {
            var i:int;
            var j:int;

            grid = new Array(segmentsR);
            for (i = 0; i < segmentsR; i++)
            {
                grid[i] = new Array(segmentsT);
                for (j = 0; j < segmentsT; j++)
                {
                    var u:Number = i / segmentsR * 2 * Math.PI;
                    var v:Number = j / segmentsT * 2 * Math.PI;
                    grid[i][j] = new Vertex((radius + tube*Math.cos(v))*Math.cos(u), tube*Math.sin(v), (radius + tube*Math.cos(v))*Math.sin(u));
                }
            }

            for (i = 0; i < segmentsR; i++)
                for (j = 0; j < segmentsT; j++)
                {
                    var ip:int = (i+1) % segmentsR;
                    var jp:int = (j+1) % segmentsT;
                    var a:Vertex = grid[i ][j]; 
                    var b:Vertex = grid[ip][j];
                    var c:Vertex = grid[i ][jp]; 
                    var d:Vertex = grid[ip][jp];

                    var uva:UV = new UV(i     / segmentsR, j     / segmentsT);
                    var uvb:UV = new UV((i+1) / segmentsR, j     / segmentsT);
                    var uvc:UV = new UV(i     / segmentsR, (j+1) / segmentsT);
                    var uvd:UV = new UV((i+1) / segmentsR, (j+1) / segmentsT);

                    addFace(new Face(a, b, c, null, uva, uvb, uvc));
                    addFace(new Face(d, c, b, null, uvd, uvc, uvb));
                }
				
			type = "Torus";
        	url = "primitive";
        }

        public function vertex(i:int, j:int):Vertex
        {
            return vertices[i][j];
        }

    }
}
