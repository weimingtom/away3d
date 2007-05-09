package away3d.objects
{
	import away3d.shapes.*;
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.geom.*;
    import away3d.core.material.*;
    
    import flash.display.BitmapData;
    
    public class RegularPlane extends Mesh3D
    {
    	public var width:Number;
    	public var height:Number;
       	public var sides:Number;
       	
        public function RegularPlane(material:IMaterial = null, init:Object = null)
        {
            super(material, init);
        }
        
        private function buildPlane():void
        {
    		var shape:RegularShape = new RegularShape(init);
    		sides = shape.sides;
    		width = shape.width;
    		height = shape.height;
    		
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
