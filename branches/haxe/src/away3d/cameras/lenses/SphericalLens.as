package away3d.cameras.lenses
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	
	public class SphericalLens extends AbstractLens implements ILens
	{
		private var _wx:Number;
		private var _wy:Number;
		private var _wz:Number;
		private var _wx2:Number;
		private var _wy2:Number;
		private var _c:Number;
		private var _c2:Number;
		
		public override function setView(val:View3D):void
		{
			super.setView(val);
			
			if (_clipping.minZ == -Infinity)
        		_near = _clipping.minZ = _camera.focus/2;
        	else
        		_near = _clipping.minZ;
		}
		
        public function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			_frustum = _cameraVarsStore.createFrustum(node);
			_focusOverZoom = _camera.focus/_camera.zoom;
			_zoom2 = _camera.zoom*_camera.zoom;
			
			_plane = _frustum.planes[Frustum.NEAR];
			_plane.a = 0;
			_plane.b = 0;
			_plane.c = 1;
			_plane.d = -_near;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.FAR];
			_plane.a = 0;
			_plane.b = 0;
			_plane.c = -1;
			_plane.d = _far;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.LEFT];
			_plane.a = -_clipHeight*_focusOverZoom;
			_plane.b = 0;
			_plane.c = _clipHeight*_clipLeft/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.RIGHT];
			_plane.a = _clipHeight*_focusOverZoom;
			_plane.b = 0;
			_plane.c = -_clipHeight*_clipRight/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.TOP];
			_plane.a = 0;
			_plane.b = -_clipWidth*_focusOverZoom;
			_plane.c = _clipWidth*_clipTop/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.BOTTOM];
			_plane.a = 0;
			_plane.b = _clipWidth*_focusOverZoom;
			_plane.c = -_clipWidth*_clipBottom/_zoom2;
			_plane.d = 0;
			_plane.transform(viewTransform);
			
			return _frustum;
		}
		
		public function getFOV():Number
		{
			return Math.atan2(_clipTop - _clipBottom, _camera.focus*_camera.zoom + _clipTop*_clipBottom)*toDEGREES;
		}
		
		public function getZoom():Number
		{
			return ((_clipTop - _clipBottom)/Math.tan(_camera.fov*toRADIANS) - _clipTop*_clipBottom)/_camera.focus;
		}
        
       /**
        * Projects the vertex to the screen space of the view.
        */
        public function project(viewTransform:Matrix3D, vertex:Vertex):ScreenVertex
        {
        	_screenVertex = _drawPrimitiveStore.createScreenVertex(vertex);
        	
        	if (_screenVertex.viewTimer == _camera.view.viewTimer)
        		return _screenVertex;
        	
        	_screenVertex.viewTimer = _camera.view.viewTimer;
        	
        	_vx = vertex.x;
        	_vy = vertex.y;
        	_vz = vertex.z;
        	
            
    		_wx = _screenVertex.vx = _vx * viewTransform.sxx + _vy * viewTransform.sxy + _vz * viewTransform.sxz + viewTransform.tx;
    		_wy = _screenVertex.vy = _vx * viewTransform.syx + _vy * viewTransform.syy + _vz * viewTransform.syz + viewTransform.ty;
    		_wz = _vx * viewTransform.szx + _vy * viewTransform.szy + _vz * viewTransform.szz + viewTransform.tz;
			_wx2 = _wx*_wx;
			_wy2 = _wy*_wy;
    		_c = Math.sqrt(_wx2 + _wy2 + _wz*_wz);
			_c2 = (_wx2 + _wy2);
			_sz = (_c != 0 && _wz != -_c)? _c*Math.sqrt(0.5 + 0.5*_wz/_c) : 0;
    		
            if (isNaN(_sz))
                throw new Error("isNaN(sz)");
            
            if (_sz < _near && _clipping is RectangleClipping) {
                _screenVertex.visible = false;
                return _screenVertex;
            }
            
			_persp = _c2? _camera.zoom*_camera.focus*(_c - _wz)/_c2 : 0;
			
            _screenVertex.x = _screenVertex.vx * _persp;
            _screenVertex.y = _screenVertex.vy * _persp;
            _screenVertex.z = _sz;
            _screenVertex.visible = true;
            
			return _screenVertex;
        }
	}
}