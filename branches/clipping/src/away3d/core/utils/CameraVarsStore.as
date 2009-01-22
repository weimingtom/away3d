package away3d.core.utils
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	
	import flash.utils.*;
	
	public class CameraVarsStore
	{
		private var _vt:Matrix3D;
		private var _frustum:Frustum;
		private var _vtActive:Array = new Array();
        private var _vtStore:Array = new Array();
		private var _fActive:Array = new Array();
        private var _fStore:Array = new Array();
        
		public var view:View3D;
    	
        /**
        * Dictionary of all objects transforms calulated from the camera view for the last render frame
        */
        public var viewTransformDictionary:Dictionary;
        
        public var nodeClassificationDictionary:Dictionary;
        
        public var vertexClassificationDictionary:Dictionary;
        
        public var frustumDictionary:Dictionary;
        
		public function createViewTransform(node:Object3D):Matrix3D
        {
        	if (_vtStore.length)
        		_vtActive.push(_vt = viewTransformDictionary[node] = _vtStore.pop());
        	else
        		_vtActive.push(_vt = viewTransformDictionary[node] = new Matrix3D());
        	
        	return _vt;
        }
        
		public function createFrustum(node:Object3D):Frustum
        {
        	if (_fStore.length)
        		_fActive.push(_frustum = frustumDictionary[node] = _fStore.pop());
        	else
        		_fActive.push(_frustum = frustumDictionary[node] = new Frustum());
        	
        	return _frustum;
        }
        
        public function reset():void
        {
        	viewTransformDictionary = new Dictionary(true);
        	frustumDictionary = new Dictionary(true);
        	nodeClassificationDictionary = new Dictionary(true);
        	vertexClassificationDictionary = new Dictionary(true);
        	
        	_vtStore = _vtStore.concat(_vtActive);
        	_vtActive = new Array();
        	_fStore = _fStore.concat(_fActive);
        	_fActive = new Array();
        }
	}
}