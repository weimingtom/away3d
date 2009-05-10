package away3d.core.project
{
	import away3d.cameras.lenses.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.sprites.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class DirSpriteProjector implements IPrimitiveProvider
	{
		private var _view:View3D;
		private var _drawPrimitiveStore:DrawPrimitiveStore;
		private var _dirsprite:DirSprite2D;
		private var _vertices:Array;
		private var _bitmaps:Dictionary;
		private var _lens:ILens;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _screenVertices:Array;
		private var _index:int;
		private var _screenIndexStart:int;
		private var _screenIndexEnd:int;
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
			_screenVertices = _drawPrimitiveStore.createScreenArray(source);
			
			_dirsprite = source as DirSprite2D;
			
			_vertices = _dirsprite.vertices;
			_bitmaps = _dirsprite.bitmaps;
			
			_lens = _view.camera.lens;
			
            if (_vertices.length == 0)
                return;
                
            var minz:Number = Infinity;
            var bitmap:BitmapData = null;
            
			_screenIndexStart = _screenVertices.length;
            
            if (!_lens.project(viewTransform, _vertices))
                return;
            
            _screenIndexEnd = _screenVertices.length;
            
            _index = _screenIndexEnd;
            while (_index-- > _screenIndexStart) {
                var z:Number = (_screenVertices[_index] as ScreenVertex).z;
                
                if (z < minz) {
                    minz = z;
                    bitmap = _bitmaps[_vertex];
                }
            }
			
            if (bitmap == null)
                return;
            
            _screenIndexStart = _screenVertices.length;
            
            if (!_lens.project(viewTransform, _dirsprite.center))
                return;
            
            _screenVertex = _screenVertices[_screenIndexStart];
                
            _persp = view.camera.zoom / (1 + _screenVertex.z / view.camera.focus);
            _screenVertex.z += _dirsprite.deltaZ;
            
            consumer.primitive(_drawPrimitiveStore.createDrawScaledBitmap(source, _screenVertex, _dirsprite.smooth, bitmap, _persp*_dirsprite.scaling, _dirsprite.rotation));
		}
	}
}