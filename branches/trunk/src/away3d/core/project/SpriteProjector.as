package away3d.core.project
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	import flash.utils.*;
	
	public class SpriteProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _vertexDictionary:Dictionary;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _sprite:Sprite2D;
		private var _screenVertex:ScreenVertex;
		private var _drawScaledBitmap:DrawScaledBitmap;
		
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
        	
			_sprite = source as Sprite2D;
			
			_screenVertex = _view.camera.lens.project(viewTransform, _sprite.center);
            
            if (!_screenVertex.visible)
                return;
                   
            _screenVertex.z += _sprite.deltaZ;
            
            consumer.primitive(_drawPrimitiveStore.createDrawScaledBitmap(source, _screenVertex, _sprite.smooth, _sprite.bitmap, _sprite.scaling*_view.camera.zoom / (1 + _screenVertex.z / _view.camera.focus), _sprite.rotation));
		}
	}
}