package away3d.core.render
{
	import away3d.containers.View3D;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.filters.BitmapFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.utils.Dictionary;
    
	public class BitmapRenderSession extends AbstractRenderSession
	{
		private var _container:Bitmap;
		private var _output:BitmapData;
		private var _width:uint;
		private var _height:uint;
		private var _clearColor:uint;
		private var _transparency:Boolean;
		private var _cx:Number;
		private var _cy:Number;
		
		private var _base:BitmapData;
		
		private var _shapeDirty:Boolean;
		
		public function BitmapRenderSession(width:Number, height:Number, transparency:Boolean, clearColor:uint)
		{
			_width = width;
			_height = height;
			_clearColor = clearColor;
			_transparency = transparency;
			graphics = shape.graphics;
			
			cm = new Matrix();
			cm.translate(width/2, height/2);
		}
        
        public override function set view(val:View3D):void
        {
        	super.view = val;
        	
        	if (!_containers[_view])
        		_containers[_view] = new Bitmap(new BitmapData(_width, _height, _transparency, _clearColor));
        	
        	_container = _containers[_view];
        	_cx = _container.x = -_width/2;
			_cy = _container.y = -_height/2;
        	_output = _base = _container.bitmapData;
        }
        
		public override function get container():DisplayObject
		{
			return _container;
		}                      
		
		public function get bitmapData():BitmapData
		{
			return _base;
		}
		
		private var shape:Shape = new Shape();

        private var lastSource:Object3D;
        
        private var newCanvas:Bitmap;
		
		public var cm:Matrix;
		
					
        public override function addDisplayObject(child:DisplayObject):void
        {
        	if (_shapeDirty)
        		commitShape();
        	
			//add child to children
            children[child] = child;
            
            //add child to layers
            layers.push(child);
            
            child.visible = true;
            
            _layerDirty = true;
        }
        
        private function createLayer():void
        {
            //create new canvas for remaining triangles
            if (doStore.length) {
            	newCanvas = doStore.pop();
            	_output = newCanvas.bitmapData;
            } else {
            	_output = new BitmapData(_base.width, _base.height, _transparency, _clearColor);
            	_output.lock();
            	newCanvas = new Bitmap(_output);
            }
            
            //store new canvas
            doActive.push(newCanvas);
            
            //add new canvas to layers
            layers.push(newCanvas);
            
            _layerDirty = false;
        }
        
        internal var i:int;
        internal var cont:BitmapData;
        
        /** Clear rendering area */
        public override function clear():void
        {
        	super.clear();
        	
        	//clear graphics
        	graphics.clear();
        	
        	//clear base canvas
        	_base.lock();
        	_base.fillRect(_base.rect, _clearColor);
        	
        	//clear doActive canvases
            i = doActive.length;
            for each (newCanvas in doActive) {
            	cont = newCanvas.bitmapData;
            	cont.fillRect(cont.rect, _clearColor);
            	doStore.push(doActive.pop());
            }
            
            //remove all children
            children = new Dictionary(true);
            
            //remove all layers
            layers = [];
        }
        
        private function commitShape():void
        {
       		_output.draw(shape, cm);
			graphics.clear();
			_shapeDirty = false;
        }
        
        public override function renderTriangleBitmap(bitmap:BitmapData, map:Matrix, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex, smooth:Boolean, repeat:Boolean, layerGraphics:Graphics = null):void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	a2 = (v1x = v1.x) - (v0x = v0.x);
        	b2 = (v1y = v1.y) - (v0y = v0.y);
        	c2 = (v2x = v2.x) - v0x;
        	d2 = (v2y = v2.y) - v0y;
        	
			m.a = (a = map.a)*a2 + (b = map.b)*c2;
			m.b = a*b2 + b*d2;
			m.c = (c = map.c)*a2 + (d = map.d)*c2;
			m.d = c*b2 + d*d2;
			m.tx = (tx = map.tx)*a2 + (ty = map.ty)*c2 + v0x;
			m.ty = tx*b2 + ty*d2 + v0y;
			
			if (layerGraphics) {
	            layerGraphics.moveTo(v0x, v0y);       
	            layerGraphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            layerGraphics.lineTo(v1x, v1y);
	            layerGraphics.lineTo(v2x, v2y);
	            layerGraphics.endFill();
			} else {
	            graphics.moveTo(v0x, v0y);       
	            graphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            graphics.lineTo(v1x, v1y);
	            graphics.lineTo(v2x, v2y);
	            graphics.endFill();
			}
            
            _shapeDirty = true;
        }
        
        public override function renderBitmap(bitmap:BitmapData, v0:ScreenVertex, smooth:Boolean = false):void
        {
        	if (_shapeDirty)
        		commitShape();
        	
        	m.identity();
        	m.tx = v0.x - bitmap.width/2 + _cx; 
        	m.ty = v0.y - bitmap.height/2 + _cy;
       		_output.draw(bitmap, m, null, null, null, smooth);
        }
        
        /**
         * Renders bitmap with precalculated matrix to screen.
         */
        public override function renderScaledBitmap(primitive:DrawScaledBitmap, bitmap:BitmapData, mapping:Matrix, smooth:Boolean = false):void
        {
        	if (_shapeDirty)
        		commitShape();
        	
        	mapping.tx -= _cx;
        	mapping.ty -= _cy;
       		_output.draw(bitmap, mapping, null, null, null, smooth);
        }
        
        public override function renderLine(v0:ScreenVertex, v1:ScreenVertex, width:Number, color:uint, alpha:Number):void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineStyle();
            
            _shapeDirty = true;
        }
        
        public override function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {    
        	if (_layerDirty)
        		createLayer();
        	
            graphics.moveTo(v0.x, v0.y); // Always move before begin will to prevent bugs
            graphics.beginFill(color, alpha);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.endFill();
            
            _shapeDirty = true;
        }
        
        public override function renderTriangleLine(color:int, alpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	if (_layerDirty)
        		createLayer();
        	
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0x = v0.x, v0y = v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.lineTo(v0x, v0y);
			graphics.lineStyle();
			
			_shapeDirty = true;
        }
        
        public override function renderTriangleLineFill(color:int, alpha:Number, wirecolor:int, wirealpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	if (_layerDirty)
        		createLayer();
        	
            if (wirealpha > 0)
                graphics.lineStyle(width, wirecolor, wirealpha);
    
            graphics.moveTo(v0.x, v0.y);

            if (alpha > 0)
                graphics.beginFill(color, alpha);
    
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
    
            if (wirealpha > 0)
            {
                graphics.lineTo(v0.x, v0.y);
                graphics.lineStyle();
            }
    
            if (alpha > 0)
                graphics.endFill();
                
            _shapeDirty = true;
        }
                
        /**
         * Renders fog from FogFilter to screen.
         */
        public override function renderFogColor(color:int, alpha:Number):void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	graphics.lineStyle();
            graphics.beginFill(color, alpha);
            graphics.drawRect(_view.clip.minX, _view.clip.minY, _view.clip.maxX - _view.clip.minX, _view.clip.maxY - _view.clip.minY);
            graphics.endFill();
        }
        
		internal var layers:Array = [];
		internal var layer:DisplayObject;
		internal var sourceBitmap:BitmapData;
		internal var filterBitmap:BitmapData;
		internal var filter:BitmapFilter;
		internal var zeroPoint:Point = new Point();
		
        public override function flush():void
        {
        	super.flush();
        	
       		if (_shapeDirty)
        		commitShape();
        	
            for each (layer in layers) {
            	if (layer is Bitmap) {
            		sourceBitmap = (layer as Bitmap).bitmapData;
            		if (layer.filters.length) {
	            		if (!filterBitmap) {
	            			filterBitmap = new BitmapData(_base.width, _base.height, _transparency, _clearColor);
	            			filterBitmap.lock();
	            		}
	            		
	            		for each (filter in layer.filters) {
	            			filterBitmap.applyFilter(sourceBitmap, sourceBitmap.rect, zeroPoint, filter);
	            			if (layer.blendMode != BlendMode.NORMAL)
	            				sourceBitmap.draw(filterBitmap, null, null, layer.blendMode);
	            			else
	            				sourceBitmap.copyPixels(filterBitmap, sourceBitmap.rect, zeroPoint);
	            		}
            		}
            		_base.draw(sourceBitmap);
            	} else {
            		_base.draw(layer, cm);
            	}
            }
           	
           _base.unlock();
           	
           	//reset output
           	_output = _base;
        }
        
        /**
         *  Returns graphics layer for debug & custom drawing,
         *  performance is not guaranteed as rendering session
         *  may not support this natively
         * 
         *  In case of SpriteAbstractRenderSession though, we can just return the canvas
         */
        public override function get customGraphics():Graphics
        {
        	if (_shapeDirty)
        		commitShape();
        	
        	lastSource = null;
        	return graphics;
        }        

        public override function clone():AbstractRenderSession
        {
        	return new BitmapRenderSession(_output.width, _output.height, _transparency, _clearColor);
        }
                
	}
}