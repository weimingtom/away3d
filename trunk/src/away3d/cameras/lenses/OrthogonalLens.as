package away3d.cameras.lenses
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	
	public class OrthogonalLens extends AbstractLens implements ILens
	{
		
		public override function setView(val:View3D):void
		{
			super.setView(val);
			
			if (_clipping.minZ == -Infinity)
        		_near = _camera.focus/2;
        	else
        		_near = _clipping.minZ;
		}
		
        public function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			_frustum = _cameraVarsStore.createFrustum(node);
			_focusOverZoom = _camera.focus/_camera.zoom;
			
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
			_plane.a = 1;
			_plane.b = 0;
			_plane.c = 0;
			_plane.d = -_clipLeft*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.RIGHT];
			_plane.a = -1;
			_plane.b = 0;
			_plane.c = 0;
			_plane.d = _clipRight*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.TOP];
			_plane.a = 0;
			_plane.b = 1;
			_plane.c = 0;
			_plane.d = _clipTop*_focusOverZoom;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.BOTTOM];
			_plane.a = 0;
			_plane.b = -1;
			_plane.c = 0;
			_plane.d = -_clipBottom*_focusOverZoom;
			_plane.transform(viewTransform);
			
			return _frustum;
		}
		
		public function getFOV():Number
		{
			return 0;
		}
		
		public function getZoom():Number
		{
			return _camera.zoom;
		}
        
       /**
        * Projects the vertices to the screen space of the view.
        */
        public function project(viewTransform:Matrix3D, vertices:Array):Boolean
        {
        	for each (_vertex in vertices) {
	        	_screenVertex = _drawPrimitiveStore.createScreenVertex(_vertex);
	        	
	        	if (_screenVertex.viewTimer != _camera.view.viewTimer) {
		        	_screenVertex.viewTimer = _camera.view.viewTimer;
		        	
		        	_vx = _vertex.x;
		        	_vy = _vertex.y;
		        	_vz = _vertex.z;
		        	
		            _sz = _vx * viewTransform.szx + _vy * viewTransform.szy + _vz * viewTransform.szz + viewTransform.tz;
		    		
		            if (isNaN(_sz))
		                throw new Error("isNaN(sz)");
		            
		            if (_sz < _near && _clipping is RectangleClipping) {
		                _screenVertex.visible = false;
		                return false;
		            }
		            
		         	_persp = _camera.zoom/_camera.focus;
					
		            _screenVertex.x = (_screenVertex.vx = (_vx * viewTransform.sxx + _vy * viewTransform.sxy + _vz * viewTransform.sxz + viewTransform.tx)) * _persp;
		            _screenVertex.y = (_screenVertex.vy = (_vx * viewTransform.syx + _vy * viewTransform.syy + _vz * viewTransform.syz + viewTransform.ty)) * _persp;
		            _screenVertex.z = _sz;
		            _screenVertex.visible = true;
	        	}
	            
		        if (!_screenVertex.visible)
		        	return false;
        	}
        	
			return true;
        }
	}
}