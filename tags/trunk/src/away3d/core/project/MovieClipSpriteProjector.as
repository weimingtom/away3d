package away3d.core.project
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class MovieClipSpriteProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _vertexDictionary:Dictionary;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _movieClipSprite:MovieClipSprite;
		private var _movieclip:DisplayObject;
		private var _screenVertex:ScreenVertex;
		private var _persp:Number;
        
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
			
			_movieClipSprite = source as MovieClipSprite;
			
			_movieclip = _movieClipSprite.movieclip;
			
			_screenVertex = _view.camera.lens.project(viewTransform, _movieClipSprite.center);
			
            _persp = view.camera.zoom / (1 + _screenVertex.z / view.camera.focus);
            
            _screenVertex.z += _movieClipSprite.deltaZ;
            _screenVertex.x -= _movieclip.width/2;
            _screenVertex.y -= _movieclip.height/2;
			 
			if(_movieClipSprite.rescale)
				_movieclip.scaleX = _movieclip.scaleY = _persp*_movieClipSprite.scaling;
			
            consumer.primitive(_drawPrimitiveStore.createDrawDisplayObject(source, _screenVertex, _movieClipSprite.session, _movieclip));
		}
	}
}