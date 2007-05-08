package away3d.objects
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    import away3d.shapes.*;

    public class IrregularPlane extends Mesh3D
    {
    	private var xMin:Number = 1000000;
    	private var xMax:Number = -1000000;
    	private var yMin:Number = 1000000;
    	private var yMax:Number = -1000000;
    	
    	public var width:Number;
    	public var height:Number;
       	public var sides:Number = 3;
                
        public function IrregularPlane(material:IMaterial, vertices:Array, init:Object = null)
        {
            super(material, init);
    		
    		this.vertices = vertices;
    		
    		sides = vertices.length;
    		var i:String, vx:Number, vy:Number, v:Vertex3D;
    		for (i in vertices) {
    			v = vertices[i];
    			vx = v.x;
    			vy = v.y;
    			if (xMin > vx)
    				xMin = vx;
    			if (xMax < vx)
    				xMax = vx;
    			if (yMin > vy)
    				yMin = vy;
    			if (yMax < vy)
    				yMax = vy;
    		}
    		width = xMax - xMin;
    		height = yMax - yMin;
            buildPlane(width, height);
        }
    
        private function buildPlane(width:Number, height:Number):void
        {
        	var i:Number;
			
			var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
			var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
			
			for (i=0;i<sides-2;i++) {
				// uv
				var iI:int = Math.floor(i/2);
				aP1 = vertices[iI];
				aP2 = (i%2==0)? (vertices[sides-2-iI]) : (vertices[iI+1]);
				aP3 = (i%2==0)? (vertices[sides-1-iI]) : (vertices[sides-2-iI]);

				aP1uv = new NumberUV( (xMin - aP1.x)/width, (aP1.y - yMin)/height );
				aP2uv = new NumberUV( (xMin - aP2.x)/width, (aP2.y - yMin)/height );
				aP3uv = new NumberUV( (xMin - aP3.x)/width, (aP3.y - yMin)/height );

				// face
				faces.push( new Face3D(aP1,aP2,aP3, null, aP1uv,aP2uv,aP3uv) );
			}
        }
    }
}
