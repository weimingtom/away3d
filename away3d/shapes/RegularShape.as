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
    	public var radius:Number = 100;
        public var sides:Number = 3;
		
        public function RegularShape(init:Object = null)
        {
            super(init);
    		if (init != null)
            {
                width = init.width || NaN;
                height = init.height || NaN;
                radius = init.radius || 100;
                sides = init.sides || sides;
                wrap = (init.wrap != null)? init.wrap : wrap;
            }
    		if (sides < 2) sides = 2; //minimum number of sides 2 (line)
    		
            buildShape();
        }
    
        private function buildShape():void
        {
        	var fRad:Number = 2*Math.PI/sides;
        	var w:Number = (isNaN(width))? radius : width/2;
        	var h:Number = (isNaN(height))? radius : height/2;
    		var i:int, j:String, vx:Number, vy:Number, fRad2:Number, oldV:Vertex3D, v:Vertex3D;
    		
    		length = 0;
			for (i=0;i<sides;i++) {
				fRad2 = fRad*i - fRad/2;
				oldV = v;
				vertices.push(v = new Vertex3D(vx = w*Math.sin(fRad2),vy = h*Math.cos(fRad2),0));
				if (i) length += Math.sqrt(Math.pow(vx - oldV.x,2) + Math.pow(vy - oldV.y,2));
    			if (xMin > vx)
    				xMin = vx;
    			if (xMax < vx)
    				xMax = vx;
    			if (yMin > vy)
    				yMin = vy;
    			if (yMax < vy)
    				yMax = vy;
			}
			if (sides > 2 && wrap) length += Math.sqrt(Math.pow(vx - vertices[0].x,2) + Math.pow(vy - vertices[0].y,2));
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
