package away3d.core.project
{
	import away3d.cameras.Camera3D;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.render.SpriteRenderSession;
	import away3d.core.utils.*;
	
	import flash.utils.*;
	
	public class ObjectContainerProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _vertexDictionary:Dictionary;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _cameraViewMatrix:Matrix3D;
		private var _viewTransformDictionary:Dictionary;
		private var _container:ObjectContainer3D;
		private var _camera:Camera3D;
		private var _child:Object3D;
		private var _screenVertex:ScreenVertex;
		private var _depthPoint:Number3D = new Number3D();
		
		public function get view():View3D
        {
        	return _view;
        }
        public function set view(val:View3D):void
        {
        	_view = val;
        	_drawPrimitiveStore = view.drawPrimitiveStore;
        }
        
		public function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			_vertexDictionary = _drawPrimitiveStore.createVertexDictionary(source);
			
			_container = source as ObjectContainer3D;
			
			_cameraViewMatrix = _view.camera.viewMatrix;
			_viewTransformDictionary = _view.cameraVarsStore.viewTransformDictionary;
			
        	for each (_child in _container.children) {
				if (_child.ownCanvas && _child.visible) {
					
					if (_child.ownSession is SpriteRenderSession)
						(_child.ownSession as SpriteRenderSession).cacheAsBitmap = true;
					
					_screenVertex = _drawPrimitiveStore.createScreenVertex(_child.center);
					_screenVertex.x = 0;
					_screenVertex.y = 0;
					
					if (_child.scenePivotPoint.modulo) {
						_depthPoint.clone(_child.scenePivotPoint);
						_depthPoint.rotate(_depthPoint, _cameraViewMatrix);
						_depthPoint.add(_viewTransformDictionary[_child].position, _depthPoint);
						
		             	_screenVertex.z = _depthPoint.modulo;
						
					} else {
						_screenVertex.z = _viewTransformDictionary[_child].position.modulo;
					}
		             
	             	
	             	if (_child.pushback)
	             		_screenVertex.z += _child.boundingRadius;
	             		
	             	if (_child.pushfront)
	             		_screenVertex.z -= _child.boundingRadius;
	            	
	             	consumer.primitive(_drawPrimitiveStore.createDrawDisplayObject(source, _screenVertex, _container.session, _child.session.getContainer(view)));
	   			}
        	}
		}
	}
}