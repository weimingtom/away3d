package away3d.core.project;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.render.SpriteRenderSession;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	
	class SessionProjector extends AbstractProjector, implements IPrimitiveProvider {
		public function new() {
		_depthPoint = new Number3D();
		}
		
		var _container:ObjectContainer3D;
		var _child:Object3D;
		var _center:Vertex;
		var _screenVertex:ScreenVertex;
		var _drawDisplayObject:DrawDisplayObject;
		var _depthPoint:Number3D ;
		
		public override function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void
		{
			super.primitives(view, viewTransform, consumer);
			
			_container = cast( source, ObjectContainer3D);
			
			if (!_container)
				Debug.error("SessionProjector must process an ObjectContainer3D object");
			
        	for (_child in _container.children) {
				if (_child.ownCanvas && _child.visible) {
					_center = _child.center;
					
					if (Std.is( _child.ownSession, SpriteRenderSession))
						(cast( _child.ownSession, SpriteRenderSession)).cacheAsBitmap = true;
					
					if (!(_screenVertex = primitiveDictionary[_center]))
						_screenVertex = primitiveDictionary[_center] = new ScreenVertex();
					
					if (_child.scenePivotPoint.modulo) {
						_depthPoint.clone(_child.scenePivotPoint);
						_depthPoint.rotate(_depthPoint, view.camera.view);
						_depthPoint.add(view.camera.viewTransforms[_child].position, _depthPoint);
						
		             	_screenVertex.z = _depthPoint.modulo;
						
					} else {
						_screenVertex.z = view.camera.viewTransforms[_child].position.modulo;
					}
		             
	             	
	             	if (_child.pushback)
	             		_screenVertex.z += _child.boundingRadius;
	             		
	             	if (_child.pushfront)
	             		_screenVertex.z -= _child.boundingRadius;
	             	
	            	if (!(_drawDisplayObject = primitiveDictionary[_child])) {
						_drawDisplayObject = primitiveDictionary[_child] = new DrawDisplayObject();
		            	_drawDisplayObject.view = view;
		            	_drawDisplayObject.screenvertex = _screenVertex;
		            }
	             	
	            	_drawDisplayObject.displayobject = _child.session.getContainer(view);
	            	_drawDisplayObject.session = _container.session;
	            	_drawDisplayObject.calc();
	            	
	             	consumer.primitive(_drawDisplayObject);
	   			}
        	}
		}
		
		public function clone():IPrimitiveProvider
		{
			return new SessionProjector();
		}
	}
