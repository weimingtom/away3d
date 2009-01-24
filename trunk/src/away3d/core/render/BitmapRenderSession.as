package away3d.core.render
{
	import away3d.arcane;
	import away3d.containers.View3D;
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	use namespace arcane;
	
    /**
    * Drawing session object that renders all drawing primitives into a <code>Bitmap</code> container.
    */
	public class BitmapRenderSession extends AbstractRenderSession
	{
		private var _container:Sprite;
		private var _bitmapContainer:Bitmap;
		private var _bitmapContainers:Dictionary = new Dictionary(true);
		private var _width:int;
		private var _height:int;
		private var _bitmapwidth:int;
		private var _bitmapheight:int;
		private var _scale:Number;
		private var _cm:Matrix;
		private var _cx:Number;
		private var _cy:Number;
		private var _base:BitmapData;
		private var mStore:Array = new Array();
		private var mActive:Array = new Array();
		private var layers:Array = [];
		private var layer:DisplayObject;
		
		/**
		 * Creates a new <code>BitmapRenderSession</code> object.
		 *
		 * @param	scale	[optional]	Defines the scale of the pixel resolution in base pixels. Default value is 2.
		 */
		public function BitmapRenderSession(scale:Number = 2)
		{
			if (_scale <= 0)
				throw new Error("scale cannot be negative or zero");
			
			_scale = scale;
        }
        
		/**
		 * @inheritDoc
		 */
		public override function getContainer(view:View3D):DisplayObject
		{
    		_bitmapContainer = getBitmapContainer(view);
    		
			if (!_containers[view]) {
        		_container = _containers[view] = new Sprite();
        		_container.addChild(_bitmapContainer);
        		return _container;
   			}
        	
			return _containers[view];
		}
		
		public function getBitmapContainer(view:View3D):Bitmap
		{
			if (!_bitmapContainers[view])
        		return _bitmapContainers[view] = new Bitmap();
        	
			return _bitmapContainers[view];
		}
		
		/**
		 * Returns a bitmapData object containing the rendered view.
		 * 
		 * @param	view	The view object being rendered.
		 * @return			The bitmapData object.
		 */
		public function getBitmapData(view:View3D):BitmapData
		{
			_container = getContainer(view) as Sprite;
			
			if (!_bitmapContainer.bitmapData) {
				_bitmapwidth = int((_width = view.screenClip.maxX - view.screenClip.minX)/_scale);
	        	_bitmapheight = int((_height = view.screenClip.maxY - view.screenClip.minY)/_scale);
	        	
	        	return _bitmapContainer.bitmapData = new BitmapData(_bitmapwidth, _bitmapheight, true, 0);
			}
        	
			return _bitmapContainer.bitmapData;
		}
        
		/**
		 * @inheritDoc
		 */
        public override function addDisplayObject(child:DisplayObject):void
        {
            //add child to layers
            layers.push(child);
            child.visible = true;
        	
			//add child to children
            children[child] = child;
            
            _layerDirty = true;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function addLayerObject(child:Sprite):void
        {
            //add child to layers
            layers.push(child);
            child.visible = true;       
            
            //add child to children
            children[child] = child;
            
            newLayer = child;
        }
        
		/**
		 * @inheritDoc
		 */
        protected override function createLayer():void
        {
            //create new canvas for remaining triangles
            if (_doStore.length) {
            	_shape = _doStore.pop();
            } else {
            	_shape = new Shape();
            }
            
            //update graphics reference
            graphics = _shape.graphics;
            
            //store new canvas
            _doActive.push(_shape);
            
            //add new canvas to layers
            layers.push(_shape);
            
            _layerDirty = false;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clear(view:View3D):void
        {
	        super.clear(view);
	        
        	if (updated) {
	        	_base = getBitmapData(view);
	        	
	        	_cx = _bitmapContainer.x = view.screenClip.minX;
				_cy = _bitmapContainer.y = view.screenClip.minY;
				_bitmapContainer.scaleX = _scale;
				_bitmapContainer.scaleY = _scale;
	        	
	        	_cm = new Matrix();
	        	_cm.scale(1/_scale, 1/_scale);
				_cm.translate(-view.screenClip.minX/_scale, -view.screenClip.minY/_scale);
				
	        	//clear base canvas
	        	_base.lock();
	        	_base.fillRect(_base.rect, 0);
	            
	            //remove all children
	            children = new Dictionary(true);
	            newLayer = null;
	            
	            //remove all layers
	            layers = [];
	            _layerDirty = true;
	        }
	        
	        if ((filters && filters.length) || (_bitmapContainer.filters && _bitmapContainer.filters.length))
        		_bitmapContainer.filters = filters;
        	
        	_bitmapContainer.alpha = alpha || 1;
        	_bitmapContainer.blendMode = blendMode || BlendMode.NORMAL;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render(view:View3D):void
        {
	        super.render(view);
	        	
        	if (updated) {
	            for each (layer in layers)
	            	_base.draw(layer, _cm, layer.transform.colorTransform, layer.blendMode, _base.rect);
	           	
	           _base.unlock();
	        }
        }
        
		/**
		 * @inheritDoc
		 */
        public override function clone():AbstractRenderSession
        {
        	return new BitmapRenderSession(_scale);
        }
                
	}
}