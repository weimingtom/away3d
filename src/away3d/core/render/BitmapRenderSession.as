package away3d.core.render
{
	import away3d.containers.View3D;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
    
	public class BitmapRenderSession extends AbstractRenderSession
	{
		private var _container:Bitmap;
		private var _width:int;
		private var _height:int;
		private var _bitmapwidth:int;
		private var _bitmapheight:int;
		private var _scale:Number;
		private var _cm:Matrix;
		private var _cx:Number;
		private var _cy:Number;
		
		private var _base:BitmapData;
		
		private var _shapeDirty:Boolean;
		
		private var mStore:Array = new Array();
		private var mActive:Array = new Array();
		
		public function BitmapRenderSession(scale:Number = 1)
		{
			if (_scale <= 0)
				throw new Error("scale cannot be negative or zero");
			
			_scale = scale;
		}
        
        public override function set view(val:View3D):void
        {
        	super.view = val;
        	
        	_container = getContainer(_view) as Bitmap;
        	_base = getBitmapData(_view);
        	
        	_cx = _container.x = -_width/2;
			_cy = _container.y = -_height/2;
			_container.scaleX = _scale;
			_container.scaleY = _scale;
        	
        	_cm = new Matrix();
        	_cm.scale(1/_scale, 1/_scale);
			_cm.translate(_bitmapwidth/2, _bitmapheight/2);
        }
        
		public override function getContainer(view:View3D):DisplayObject
		{
			if (!_containers[view])
        		return _containers[view] = new Bitmap();
        	
			return _containers[view];
		}
		
		public function getBitmapData(view:View3D):BitmapData
		{
			_container = getContainer(view) as Bitmap;
			
			if (!_container.bitmapData) {
				_bitmapwidth = int((_width = _view.clip.maxX - _view.clip.minX)/_scale);
	        	_bitmapheight = int((_height = _view.clip.maxY - _view.clip.minY)/_scale);
	        	
	        	return _container.bitmapData = new BitmapData(_bitmapwidth, _bitmapheight, true, 0);
			}
        	
			return _container.bitmapData;
		}
					
        public override function addDisplayObject(child:DisplayObject):void
        {
            //add child to layers
            layers.push(child);
            child.visible = true;
        	
			//add child to children
            children[child] = child;
            
            _layerDirty = true;
        }
                   
        public override function addLayerObject(child:Sprite):void
        {
            //add child to layers
            layers.push(child);
            child.visible = true;       
            
            //add child to children
            children[child] = child;
            
            newLayer = child;
        }
        
        private function createLayer():void
        {
            //create new canvas for remaining triangles
            if (doStore.length) {
            	_shape = doStore.pop();
            } else {
            	_shape = new Shape();
            }
            
            //update graphics reference
            graphics = _shape.graphics;
            
            //store new canvas
            doActive.push(_shape);
            
            //add new canvas to layers
            layers.push(_shape);
            
            _layerDirty = false;
        }
        
        internal var _matrix:Matrix;
        internal var matrices:Array;
        internal var smooths:Array;
        
        private function createMatrix():void
        {
        	//create new matrix from store
            if (mStore.length) {
            	_matrix = mStore.pop();
            } else {
            	_matrix = new Matrix();
            }
            
            matrices.push(_matrix);
        }
        
        /** Clear rendering area */
        public override function clear():void
        {
        	super.clear();
        	
        	//clear matricies array
            i = mActive.length;
            while (i--)
            	mStore.push(mActive.pop());
        	
        	matrices = [];
        	
        	//clear smooth array
        	smooths = [];
        	
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
        }
        
        public override function renderBitmap(bitmap:BitmapData, v0:ScreenVertex, smooth:Boolean = false):void
        {
        	createMatrix();
        	_matrix.a = 1/_scale;
        	_matrix.b = 0;
        	_matrix.c = 0;
        	_matrix.d = 1/_scale;
        	_matrix.tx = (v0.x - bitmap.width/2 - _cx)/_scale;
        	_matrix.ty = (v0.y - bitmap.height/2 - _cy)/_scale;
       		
       		//add new bitmapData to layers
            layers.push(bitmap);
            
            //add new smoothing to smooths
            smooths.push(smooth);
            
    		_layerDirty = true;
        }
        
        /**
         * Renders bitmap with precalculated matrix to screen.
         */
        public override function renderScaledBitmap(primitive:DrawScaledBitmap, bitmap:BitmapData, mapping:Matrix, smooth:Boolean = false):void
        {/*
        	createMatrix();
        	_matrix.a = mapping.a/_scale;
        	_matrix.b = mapping.b;
        	_matrix.c = mapping.c;
        	_matrix.d = mapping.d/_scale;
        	_matrix.tx = mapping.tx/_scale - _cx;
        	_matrix.ty = mapping.ty/_scale - _cy;
       		
       		//add new bitmapData to layers
            layers.push(bitmap);
       		
       		//add new smoothing to smooths
            smooths.push(smooth);
            
    		_layerDirty = true;
    		*/
    		if (_layerDirty)
        		createLayer();
        	
            if (primitive.rotation != 0) {           
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);
	            graphics.moveTo(primitive.topleft.x, primitive.topleft.y);
	            graphics.lineTo(primitive.topright.x, primitive.topright.y);
	            graphics.lineTo(primitive.bottomright.x, primitive.bottomright.y);
	            graphics.lineTo(primitive.bottomleft.x, primitive.bottomleft.y);
	            graphics.lineTo(primitive.topleft.x, primitive.topleft.y);
	            graphics.endFill();
            } else {
	            graphics.beginBitmapFill(bitmap, mapping, false, smooth);	            
	            graphics.drawRect(primitive.minX, primitive.minY, primitive.maxX-primitive.minX, primitive.maxY-primitive.minY);
            	graphics.endFill();
            }
        }
        
        public override function renderLine(v0:ScreenVertex, v1:ScreenVertex, width:Number, color:uint, alpha:Number):void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0.x, v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineStyle();
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
        }
        
        public override function renderTriangleLine(width:Number, color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	if (_layerDirty)
        		createLayer();
        	
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(v0x = v0.x, v0y = v0.y);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.lineTo(v0x, v0y);
			graphics.lineStyle();
        }
        
        public override function renderTriangleLineFill(width:Number, color:int, alpha:Number, wirecolor:int, wirealpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
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
		//internal var sourceBitmap:BitmapData;
		//internal var filterBitmap:BitmapData;
		//internal var filter:BitmapFilter;
		//internal var zeroPoint:Point = new Point();
		
        public override function flush():void
        {
        	super.flush();
        	
        	i = 0;
            for each (layer in layers) {
            	_base.draw(layer, _cm, layer.transform.colorTransform, layer.blendMode, _base.rect);
            		/*
            	if (layer is BitmapData) {
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
            		_base.draw(layer, matrices[i], null, null, _base.rect, smooths[i]);
            		i++;
            	} else {
            		_base.draw(layer, _cm, layer);
            	}
            		*/
            }
           	
           _base.unlock();
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
        	return graphics;
        }        

        public override function clone():AbstractRenderSession
        {
        	return new BitmapRenderSession(_scale);
        }
                
	}
}