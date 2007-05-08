package away3d.shapes
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class RegularShape extends Vertices3D
    {	
    	public var width:Number;
    	public var height:Number;
    	public var radius:Number = 100;
        public var sides:Number = 3;
        public var length:Number;
		
        public function RegularShape(init:Object = null)
        {
            super(init);
    		if (init != null)
            {
                width = init.width || NaN;
                height = init.height || NaN;
                radius = init.radius || 100;
                sides = init.sides || sides;
            }
    		if (sides < 2) sides = 2; //minimum number of sides 2 (line)
            var scale:Number = 1;
    		
            buildShape(width, height, radius);
        }
    
        private function buildShape(width:Number, height:Number, radius:Number):void
        {
        	var fRad:Number = 2*Math.PI/sides;
        	var w:Number = (isNaN(width))? radius : width/2;
        	var h:Number = (isNaN(height))? radius : height/2;
        	var xMin:Number = 1000000;
    		var xMax:Number = -1000000;
    		var yMin:Number = 1000000;
    		var yMax:Number = -1000000;
    		var i:int, j:String, vx:Number, vy:Number, fRad2:Number, v:Vertex3D;
    		
    		length = 0;
			for (i=0;i<sides;i++) {
				fRad2 = fRad*i - fRad/2;
				vertices.push(new Vertex3D(vx = w*Math.sin(fRad2),vy = h*Math.cos(fRad2),0));
				if (i) length += Math.sqrt(Math.pow(vx - vertices[i-1].x,2) + Math.pow(vy - vertices[i-1].y,2));
    			if (xMin > vx)
    				xMin = vx;
    			if (xMax < vx)
    				xMax = vx;
    			if (yMin > vy)
    				yMin = vy;
    			if (yMax < vy)
    				yMax = vy;
			}
			if (sides > 2) length += Math.sqrt(Math.pow(vx - vertices[0].x,2) + Math.pow(vy - vertices[0].y,2));
			var xScale:Number = (isNaN(width) || Math.abs(xMax - xMin) < 0.1)? 1 : width/(xMax - xMin);
			var yScale:Number = (isNaN(height) || Math.abs(yMax - yMin) < 0.1)? 1 : height/(yMax - yMin);

			for (j in vertices) {
				v = vertices[j];
				v.x *= xScale;
				v.y *= yScale;
			}
        }
    }
}
