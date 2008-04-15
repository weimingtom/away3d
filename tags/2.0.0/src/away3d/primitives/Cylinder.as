package away3d.primitives
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.math.*;
    import away3d.core.stats.*;
    import away3d.core.utils.*;
    import away3d.materials.*;
    
    /** Cylinder */ 
    public class Cylinder extends Mesh
    {
        public function Cylinder(init:Object = null)
        {
            super(init);
            
            init = Init.parse(init);

            var radius:Number = init.getNumber("radius", 100, {min:0});
            var height:Number = init.getNumber("height", 200, {min:0});
            var segmentsW:int = init.getInt("segmentsW", 8, {min:3});
            var segmentsH:int = init.getInt("segmentsH", 1, {min:1});
            var openEnded:Boolean = init.getBoolean("openEnded", false);
			var yUp:Boolean = init.getBoolean("yUp", true);
			
            buildCylinder(radius, height, segmentsW, segmentsH, openEnded, yUp);
        }
    
        private var grid:Array;
        private var jMin:int;
        private var jMax:int;
        
        private function buildCylinder(radius:Number, height:Number, segmentsW:int, segmentsH:int, openEnded:Boolean, yUp:Boolean):void
        {
            var i:int;
            var j:int;

            height /= 2;

            grid = new Array();
            
			if (!openEnded) {
	            segmentsH += 2;
				jMin = 1;
				jMax = segmentsH - 1;
			
	            var bottom:Vertex = yUp? new Vertex(0, -height, 0) : new Vertex(0, 0, -height);
	            grid[0] = new Array(segmentsW);
	            for (i = 0; i < segmentsW; i++) 
	                grid[0][i] = bottom;
	                
	            var top:Vertex = yUp? new Vertex(0, height, 0) : new Vertex(0, 0, height);
	            grid[segmentsH] = new Array(segmentsW);
	            for (i = 0; i < segmentsW; i++) 
	                grid[segmentsH][i] = top;
	                
			} else {
				jMin = 0;
				jMax = segmentsH;
			}
			
            for (j = jMin; j <= jMax; j++)  
            { 
                var z:Number = -height + 2 * height * (j-1) / (segmentsH-2);

                grid[j] = new Array(segmentsW);
                for (i = 0; i < segmentsW; i++) 
                { 
                    var verangle:Number = 2 * i / segmentsW * Math.PI;
                    var x:Number = radius * Math.sin(verangle);
                    var y:Number = radius * Math.cos(verangle);
                    if (yUp)
                    	grid[j][i] = new Vertex(y, z, x);
                    else
                    	grid[j][i] = new Vertex(y, -x, z);
                }
            }
			

            for (j = 1; j <= segmentsH; j++) 
                for (i = 0; i < segmentsW; i++) 
                {
                    var a:Vertex = grid[j][i];
                    var b:Vertex = grid[j][(i-1+segmentsW) % segmentsW];
                    var c:Vertex = grid[j-1][(i-1+segmentsW) % segmentsW];
                    var d:Vertex = grid[j-1][i];
					
					var i2:int = i
					if (i == 0) i2 = segmentsW
					
                    var vab:Number = j / segmentsH;
                    var vcd:Number = (j-1) / segmentsH;
                    var uad:Number = i2 / segmentsW;
                    var ubc:Number = (i2-1) / segmentsW;
                    var uva:UV = new UV(uad,vab);
                    var uvb:UV = new UV(ubc,vab);
                    var uvc:UV = new UV(ubc,vcd);
                    var uvd:UV = new UV(uad,vcd);

                    if (j <= jMax)
                        addFace(new Face(a,b,c, null, uva,uvb,uvc));
                    if (j > jMin)                
                        addFace(new Face(a,c,d, null, uva,uvc,uvd));
                }
        	
        	type = "Cylinder";
        	url = "primitive";
		}

        public function vertex(i:int, j:int):Vertex
        {
            return grid[j][i];
        }
    }
}