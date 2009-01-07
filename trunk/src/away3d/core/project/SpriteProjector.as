package away3d.core.project
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	public class SpriteProjector extends AbstractProjector implements IPrimitiveProvider
	{
		private var _sprite:Sprite2D;
		private var _center:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _drawScaledBitmap:DrawScaledBitmap;
		
		public override function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
        	super.primitives(source, viewTransform, consumer);
        	
			_sprite = source as Sprite2D;
			
			_center = _sprite.center;
			
			if (!(_screenVertex = primitiveDictionary[_center]))
				_screenVertex = primitiveDictionary[_center] = new ScreenVertex();
            
            view.camera.project(viewTransform, _center, _screenVertex);
            
            if (!_screenVertex.visible)
                return;
                   
            _screenVertex.z += _sprite.deltaZ;
            
            if (!(_drawScaledBitmap = primitiveDictionary[_sprite])) {
				_drawScaledBitmap = primitiveDictionary[_sprite] = new DrawScaledBitmap();
	            _drawScaledBitmap.screenvertex = _screenVertex;
	            _drawScaledBitmap.source = source;
			}
            _drawScaledBitmap.screenvertex = _screenVertex;
            _drawScaledBitmap.smooth = _sprite.smooth;
            _drawScaledBitmap.bitmap = _sprite.bitmap;
            _drawScaledBitmap.scale = _sprite.scaling*view.camera.zoom / (1 + _screenVertex.z / view.camera.focus);
            _drawScaledBitmap.rotation = _sprite.rotation;
            _drawScaledBitmap.calc();
            
            consumer.primitive(_drawScaledBitmap);
		}
	}
}