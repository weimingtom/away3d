package away3d.core.clip
{
    import away3d.core.base.*;
    import away3d.core.draw.*;

    /** Rectangle clipping */
    public class RectangleClipping extends Clipping
    {
    	private var tri:DrawTriangle;
    	private var _v0w:Number;
    	private var _v1w:Number;
    	private var _v2w:Number;
    	private var _p:Number;
    	private var _d:Number;
    	private var _v0:ScreenVertex;
    	private var _v01:ScreenVertex;
    	private var _v1:ScreenVertex;
    	private var _v12:ScreenVertex;
    	private var _v2:ScreenVertex;
    	private var _v20:ScreenVertex;
    	private var _uv0:UV;
    	private var _uv01:UV;
    	private var _uv1:UV;
    	private var _uv12:UV;
    	private var _uv2:UV;
    	private var _uv20:UV;
    	private var _singleTriangle:Boolean;
    	
        public function RectangleClipping(init:Object = null)
        {
            super(init);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function check(pri:DrawPrimitive):Boolean
        {
        	/*
            if (pri is DrawTriangle) {
            	tri = pri as DrawTriangle;
            	if (!tri.v1.visible && tri.v0.visible) {
        			_v0 = tri.v0;
        			_v1 = tri.v1;
        			_v2 = tri.v2;
        			_uv0 = tri.uv0;
        			_uv1 = tri.uv1;
        			_uv2 = tri.uv2;
            	} else if (!tri.v2.visible && tri.v1.visible) {
        			_v0 = tri.v1;
        			_v1 = tri.v2;
        			_v2 = tri.v0;
        			_uv0 = tri.uv1;
        			_uv1 = tri.uv2;
        			_uv2 = tri.uv0;
            	} else if (!tri.v0.visible && tri.v2.visible) {
        			_v0 = tri.v2;
        			_v1 = tri.v0;
        			_v2 = tri.v1;
        			_uv0 = tri.uv2;
        			_uv1 = tri.uv0;
        			_uv2 = tri.uv1;
            	} else {
            		return [pri];
            	}
            	
            	//create clipped triangle(s)
            	_v0w = (minZ - _v1.z);
            	_v1w = (_v0.z - minZ);
            	_d = (_v0.z - _v1.z);
            	_p = 1/(_d*(1 + minZ/tri.view.camera.focus));
            	_v01 = new ScreenVertex((_v0.vx*_v0w + _v1.vx*_v1w)*_p, (_v0.vy*_v0w + _v1.vy*_v1w)*_p, minZ);
            	_uv01 = _uv0? new UV((_uv0.u*_v0w + _uv1.u*_v1w)/_d, (_uv0.v*_v0w + _uv1.v*_v1w)/_d) : null;
        		
            	if (!_v2.visible) {
            		_v0w = (minZ - _v2.z);
            		_v2w = (_v0.z - minZ);
            		_d = (_v0.z - _v2.z);
            		_p = 1/(_d*(1 + minZ/tri.view.camera.focus));
            		_v20 = new ScreenVertex((_v0.vx*_v0w + _v2.vx*_v2w)*_p, (_v0.vy*_v0w + _v2.vy*_v2w)*_p, minZ);
            		_uv20 = _uv0? new UV((_uv0.u*_v0w + _uv2.u*_v2w)/_d, (_uv0.v*_v0w + _uv2.v*_v2w)/_d) : null;
            		
            		return [tri.create(tri.source, tri.face, tri.material,  _v0, _v01, _v20,  _uv0, _uv01, _uv20, true)];
            	} else {
            		_v2w = (minZ - _v1.z);
            		_v1w = (_v2.z - minZ);
            		_d = (_v2.z - _v1.z);
            		_p = 1/(_d*(1 + minZ/tri.view.camera.focus));
            		_v12 = new ScreenVertex((_v2.vx*_v2w + _v1.vx*_v1w)*_p, (_v2.vy*_v2w + _v1.vy*_v1w)*_p, minZ);
            		_uv12 = _uv0? new UV((_uv1.u*_v1w + _uv2.u*_v2w)/_d, (_uv1.v*_v1w + _uv2.v*_v2w)/_d) : null;
            		
            		return [tri.create(tri.source, tri.face, tri.material,  _v0, _v01, _v2,  _uv0, _uv01, _uv2, true),
            				tri.create(tri.source, tri.face, tri.material,  _v01, _v12, _v2,  _uv01, _uv12, _uv2, true)];
            	}
        		return [pri];
        		*/
            //} else {
	            if (pri.maxX < minX)
	                return false;
	            if (pri.minX > maxX)
	                return false;
	            if (pri.maxY < minY)
	                return false;
	            if (pri.minY > maxY)
	                return false;
            //}

            return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function rect(minX:Number, minY:Number, maxX:Number, maxY:Number):Boolean
        {
            if (this.maxX < minX)
                return false;
            if (this.minX > maxX)
                return false;
            if (this.maxY < minY)
                return false;
            if (this.minY > maxY)
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