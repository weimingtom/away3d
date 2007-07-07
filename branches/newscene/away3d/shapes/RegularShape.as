package away3d.shapes
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    /** Regular shape */
    public class RegularShape extends Vertices3D
    {   
        public var xradius:Number = 100;
        public var sides:int = 3;
        
        public function RegularShape(init:Object = null)
        {
            super(init);

            init = Init.parse(init);

            xradius = init.getNumber("radius", 100);
            width  = init.getNumber("width", xradius*2);
            height = init.getNumber("height", xradius*2);
            sides  = init.getInt("sides", 3, {min:2});

            buildShape();
        }
    
        private function buildShape():void
        {
            var fRad:Number = 2*Math.PI/sides;
            var w:Number = width/2;
            var h:Number = height/2;
            var i:int, j:String, vx:Number, vy:Number, fRad2:Number, oldV:Vertex3D, v:Vertex3D;
            
            length = 0;
            for (i=0;i<sides;i++) 
            {
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

            if (sides > 2 && wrap) 
                length += Math.sqrt(Math.pow(vx - vertices[0].x,2) + Math.pow(vy - vertices[0].y,2));

            var xScale:Number = (Math.abs(xMax - xMin) < 0.1) ? 1 : width/(xMax - xMin);
            var yScale:Number = (Math.abs(yMax - yMin) < 0.1) ? 1 : height/(yMax - yMin);

            for (j in vertices) 
            {
                v = vertices[j];
                v.x *= xScale;
                v.y *= yScale;
            }
        }
    }
}
