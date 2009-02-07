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
        }
        
		/**
		 * @inheritDoc
		 */
        public override function check(pri:DrawPrimitive):Boolean
        {
            /*
	            if (pri.maxX < minX)
	                return false;
	            if (pri.minX > maxX)
	                return false;
	            if (pri.maxY < minY)
	                return false;
	            if (pri.minY > maxY)
	                return false;
	        */

            return true;
        }
        
        		
		public override function checkFace(faceVO:FaceVO, source:Object3D):Array
		{
			_session = source.session;
			_frustum = _cameraVarsStore.frustumDictionary[source];
			
			_pass = true;
			
			_v0C = _cameraVarsStore.createVertexClassification(faceVO.v0);
			_v1C = _cameraVarsStore.createVertexClassification(faceVO.v1);
			_v2C = _cameraVarsStore.createVertexClassification(faceVO.v2);
			
			if (_v0C.plane || _v1C.plane || _v2C.plane) {
				if ((_plane = _v0C.plane)) {
					_v0d = _v0C.distance;
					_v1d = _v1C.getDistance(_plane);
					_v2d = _v2C.getDistance(_plane);
				} else if ((_plane = _v1C.plane)) {
					_v0d = _v0C.getDistance(_plane);
					_v1d = _v1C.distance;
					_v2d = _v2C.getDistance(_plane);
				} else if ((_plane = _v2C.plane)) {
					_v0d = _v0C.getDistance(_plane);
					_v1d = _v1C.getDistance(_plane);
					_v2d = _v2C.distance;
				}
				
				if (_v0d < 0 && _v1d < 0 && _v2d < 0)
					return [];
				
				if (_v0d < 0 || _v1d < 0 || _v2d < 0)
					_pass = false;
			} else {
				for each (_plane in _frustum.planes) {
					_v0d = _v0C.getDistance(_plane);
					_v1d = _v1C.getDistance(_plane);
					_v2d = _v2C.getDistance(_plane);
					
					if (_v0d < 0 && _v1d < 0 && _v2d < 0)
						return [];
					
					if (_v0d < 0 || _v1d < 0 || _v2d < 0) {
						_pass = false;
						break;
					}
				}
			}
			
			
			if (_pass)
				return [faceVO];
			
			if (_v0d >= 0 && _v1d < 0) {
				_v0w = _v0d;
				_v1w = _v1d;
				_v2w = _v2d;
				_v0 = faceVO.v0;
    			_v1 = faceVO.v1;
    			_v2 = faceVO.v2;
    			_uv0 = faceVO.uv0;
    			_uv1 = faceVO.uv1;
    			_uv2 = faceVO.uv2;
			} else if (_v1d >= 0 && _v2d < 0) {
				_v0w = _v1d;
				_v1w = _v2d;
				_v2w = _v0d;
				_v0 = faceVO.v1;
    			_v1 = faceVO.v2;
    			_v2 = faceVO.v0;
    			_uv0 = faceVO.uv1;
    			_uv1 = faceVO.uv2;
    			_uv2 = faceVO.uv0;
			} else if (_v2d >= 0 && _v0d < 0) {
				_v0w = _v2d;
				_v1w = _v0d;
				_v2w = _v1d;
    			_v0 = faceVO.v2;
    			_v1 = faceVO.v0;
    			_v2 = faceVO.v1;
    			_uv0 = faceVO.uv2;
    			_uv1 = faceVO.uv0;
    			_uv2 = faceVO.uv1;
			}
    		
        	_d = (_v0w - _v1w);
        	
        	_v01 = _cameraVarsStore.createVertex((_v1.x*_v0w - _v0.x*_v1w)/_d, (_v1.y*_v0w - _v0.y*_v1w)/_d, (_v1.z*_v0w - _v0.z*_v1w)/_d);
        	
        	_uv01 = _uv0? _cameraVarsStore.createUV((_uv1.u*_v0w - _uv0.u*_v1w)/_d, (_uv1.v*_v0w - _uv0.v*_v1w)/_d, _session) : null;
    		
        	if (_v2w < 0) {
	        	
				_d = (_v0w - _v2w);
				
        		_v20 = _cameraVarsStore.createVertex((_v2.x*_v0w - _v0.x*_v2w)/_d, (_v2.y*_v0w - _v0.y*_v2w)/_d, (_v2.z*_v0w - _v0.z*_v2w)/_d);
        		
        		_uv20 = _uv0? _cameraVarsStore.createUV((_uv2.u*_v0w - _uv0.u*_v2w)/_d, (_uv2.v*_v0w - _uv0.v*_v2w)/_d, _session) : null;
        		
        		return checkFace(_cameraVarsStore.createFaceVO(faceVO.face, _v0, _v01, _v20, faceVO.material, faceVO.back,  _uv0, _uv01, _uv20), source);
        	} else {
        		_d = (_v2w - _v1w);
        		
        		_v12 = _cameraVarsStore.createVertex((_v1.x*_v2w - _v2.x*_v1w)/_d, (_v1.y*_v2w - _v2.y*_v1w)/_d, (_v1.z*_v2w - _v2.z*_v1w)/_d);
        		
        		_uv12 = _uv0? _cameraVarsStore.createUV((_uv1.u*_v2w - _uv2.u*_v1w)/_d, (_uv1.v*_v2w - _uv2.v*_v1w)/_d, _session) : null;
        		
        		var _f0:FaceVO = _cameraVarsStore.createFaceVO(faceVO.face, _v0, _v01, _v2, faceVO.material, faceVO.back, _uv0, _uv01, _uv2);
        		var _f1:FaceVO = _cameraVarsStore.createFaceVO(faceVO.face, _v01, _v12, _v2, faceVO.material, faceVO.back, _uv01, _uv12, _uv2);
        		return checkFace(_f0, source).concat(checkFace(_f1, source));
        	}
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