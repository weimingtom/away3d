package away3d.core.clip
{
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    /** Rectangle clipping */
    public class RectangleClipping extends Clipping
    {
    	private var tri:DrawTriangle;
    	private var _v0C:VertexClassification;
    	private var _v1C:VertexClassification;
    	private var _v2C:VertexClassification;
    	private var _v0d:Number;
    	private var _v1d:Number;
    	private var _v2d:Number;
    	private var _v0w:Number;
    	private var _v1w:Number;
    	private var _v2w:Number;
    	private var _p:Number;
    	private var _d:Number;
    	private var _session:AbstractRenderSession;
    	private var _frustum:Frustum;
    	private var _pass:Boolean;
    	private var _v0Classification:Plane3D;
		private var _v1Classification:Plane3D;
		private var _v2Classification:Plane3D;
		private var _plane:Plane3D;
		private var _v0:Vertex;
    	private var _v01:Vertex;
    	private var _v1:Vertex;
    	private var _v12:Vertex;
    	private var _v2:Vertex;
    	private var _v20:Vertex;
    	private var _uv0:UV;
    	private var _uv01:UV;
    	private var _uv1:UV;
    	private var _uv12:UV;
    	private var _uv2:UV;
    	private var _uv20:UV;
    	private var _f0:FaceVO;
    	private var _f1:FaceVO;
    	
        public function RectangleClipping(init:Object = null)
        {
            super(init);
            
            objectCulling = ini.getBoolean("objectCulling", false);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function checkPrimitive(pri:DrawPrimitive):Boolean
        {
            if (pri.maxX < minX)
                return false;
            if (pri.minX > maxX)
                return false;
            if (pri.maxY < minY)
                return false;
            if (pri.minY > maxY)
                return false;
			
            return true;
        }
        
		public override function clone(object:Clipping = null):Clipping
        {
        	var clipping:RectangleClipping = (object as RectangleClipping) || new RectangleClipping();
        	
        	super.clone(clipping);
        	
        	return clipping;
        }
    }
}