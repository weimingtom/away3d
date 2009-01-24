package away3d.cameras.lenses
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.geom.Frustum;
	import away3d.core.math.*;
	
	import flash.utils.Dictionary;
	
	public class PerspectiveLens extends AbstractLens
	{
		
        public override function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum
		{
			_frustum = cameraVarsStore.createFrustum(node);
			
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
			_plane.a = (_clipTop - _clipBottom)*camera.focus/camera.zoom;
			_plane.b = 0;
			_plane.c = (_clipBottom - _clipTop)*_clipLeft/(camera.zoom*camera.zoom);
			_plane.d = _plane.c*camera.focus;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.RIGHT];
			_plane.a = -(_clipTop - _clipBottom)*camera.focus/camera.zoom;
			_plane.b = 0;
			_plane.c = -(_clipBottom - _clipTop)*_clipRight/(camera.zoom*camera.zoom);
			_plane.d = _plane.c*camera.focus;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.TOP];
			_plane.a = 0;
			_plane.b = (_clipRight - _clipLeft)*camera.focus/camera.zoom;
			_plane.c = -(_clipLeft - _clipRight)*_clipTop/(camera.zoom*camera.zoom);
			_plane.d = _plane.c*camera.focus;
			_plane.transform(viewTransform);
			
			_plane = _frustum.planes[Frustum.BOTTOM];
			_plane.a = 0;
			_plane.b = -(_clipRight - _clipLeft)*camera.focus/camera.zoom;
			_plane.c = (_clipLeft - _clipRight)*_clipBottom/(camera.zoom*camera.zoom);
			_plane.d = _plane.c*camera.focus;
			_plane.transform(viewTransform);
			
			return _frustum;
			//(cameraVarsStore.viewTransformDictionary[node] as Matrix3D).perspectiveProjectionMatrix(camera.fov, camera.aspect, camera.near, camera.far);
		}
		
		public override function getFOV():Number
		{
			return Math.atan2(_clipTop - _clipBottom, camera.focus*camera.zoom + _clipTop*_clipBottom)*toDEGREES;
		}
		
		public override function getZoom():Number
		{
			return ((_clipTop - _clipBottom)/Math.tan(camera.fov*toRADIANS) - _clipTop*_clipBottom)/camera.focus;
		}
		
		/**
		 * @inheritDoc
		 */
		public override function updateView(clip:Clipping, sceneTransform:Matrix3D, flipY:Matrix3D):void
        {
        	//update view matrix
        	view.multiply(sceneTransform, flipY);
        	view.inverse(view);
        	
        	//clear visible dictionary
        	nodeVisible = new Dictionary(true);
        }
        
		/**
		 * @inheritDoc
		 */
        public override function preCheckNode(node:Object3D):Boolean
        {
        	//view.nodeVisible[node] == IN;
        	return true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function resolveTransform(node:Object3D):void
		{
			if (!(viewTransform = nodeTransform[node]))
				viewTransform = nodeTransform[node] = new Matrix3D();
			
			//node.viewTransform = viewTransform;
			
			viewTransform.multiply(view, node.sceneTransform);
		}
        
		/**
		 * @inheritDoc
		 */
		public override function postCheckNode(node:Object3D):Boolean
        {
        	//determine whether the 3d object is visible based on LOD settings.
        	var z:Number = viewTransform.tz;
            var persp:Number = camera.zoom / (1 + z / camera.focus);
			/*
            if (persp < node.minp || persp >= node.maxp) {
            	delete nodeVisible[node];
                return false;
            }
			*/
            return true;
        }
        
        
		/**
		 * @inheritDoc
		 */
        
       /**
        * Projects the vertex to the screen space of the view.
        */
        public override function project(viewTransform:Matrix3D, vertex:Vertex):ScreenVertex
        {
        	_screenVertex = drawPrimitiveStore.createScreenVertex(vertex);
        	
        	if (_screenVertex.viewTimer == camera.view.viewTimer)
        		return _screenVertex;
        	
        	_screenVertex.viewTimer = camera.view.viewTimer;
        	
        	_vx = vertex.x;
        	_vy = vertex.y;
        	_vz = vertex.z;
        	
            _screenVertex.z = _sz = _vx * viewTransform.szx + _vy * viewTransform.szy + _vz * viewTransform.szz + viewTransform.tz;
    		/*/
    		//modified
    		var wx:Number = x * view.sxx + y * view.sxy + z * view.sxz + view.tx;
    		var wy:Number = x * view.syx + y * view.syy + z * view.syz + view.ty;
    		var wz:Number = x * view.szx + y * view.szy + z * view.szz + view.tz;
			var wx2:Number = Math.pow(wx, 2);
			var wy2:Number = Math.pow(wy, 2);
    		var c:Number = Math.sqrt(wx2 + wy2 + wz*wz);
			var c2:Number = (wx2 + wy2);
			persp = c2? projection.focus*(c - wz)/c2 : 0;
			sz = (c != 0 && wz != -c)? c*Math.sqrt(0.5 + 0.5*wz/c) : 0;
			//*/
    		//end modified
    		
            if (isNaN(_sz))
                throw new Error("isNaN(sz)");
            
            _screenVertex.vx = (_vx * viewTransform.sxx + _vy * viewTransform.sxy + _vz * viewTransform.sxz + viewTransform.tx)*camera.zoom;
            _screenVertex.vy = (_vx * viewTransform.syx + _vy * viewTransform.syy + _vz * viewTransform.syz + viewTransform.ty)*camera.zoom;
            
            if (_sz < _near) {
                _screenVertex.visible = false;
                return _screenVertex;
            }
            
         	_persp = 1 / (1 + _sz / camera.focus);
			
            _screenVertex.x = _sx = _screenVertex.vx * _persp;
            _screenVertex.y = _sy = _screenVertex.vy * _persp;
            /*
            if (_sx < clip.minX || _sx > clip.maxX || _sy < clip.minY || _sy > clip.maxY) {
                _screenVertex.visible = false;
                return;
            }
            */
            _screenVertex.visible = true;
            /*
            projected.x = wx * persp;
            projected.y = wy * persp;
			*/
			return _screenVertex;
        }
	}
}