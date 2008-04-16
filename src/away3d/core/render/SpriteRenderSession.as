package away3d.core.render
{
	import away3d.containers.*;
	import away3d.core.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
    
	public class SpriteRenderSession extends AbstractRenderSession
	{
        private var _container:Sprite;
	    
		public function SpriteRenderSession():void
		{
		}
		
        public override function set view(val:View3D):void
        {	
        	super.view = val;
        	
        	if (!_containers[_view])
        		_containers[_view] = new Sprite();
        	
        	_container = _containers[_view];
        	graphics = _container.graphics;
        }
        
		public override function get container():DisplayObject
		{
			return _container;
		}
	    
	    private var newCanvas:Sprite;
	       
        public override function addDisplayObject(child:DisplayObject):void
        {
            //add to container
            _container.addChild(child);
            child.visible = true;
            
            //add child to children
            children[child] = child;
            
            _layerDirty = true;
        }
        
        private function createLayer():void
        {
            //create new canvas for remaining triangles
            if (doStore.length) {
            	newCanvas = doStore.pop();
            } else {
            	newCanvas = new Sprite();
            }
            //update graphics reference
            graphics = newCanvas.graphics;
            //store new canvas
            doActive.push(newCanvas);
            //add new canvas to base canvas
            _container.addChild(newCanvas);
       		
			_layerDirty = false;
        }
        
        
        internal var i:int;
        internal var cont:Sprite;
        
        /** Clear rendering area */
        public override function clear():void
        {
        	super.clear();
        	
        	//clear base canvas
            _container.graphics.clear();
            
            //clear child canvases
            i = doActive.length;
            while (i--) {
            	cont = doActive[i];
            	cont.graphics.clear();
            	doStore.push(doActive.pop());
            }
            
            //remove all children
            i = _container.numChildren;
			while (i--)
				_container.removeChild(_container.getChildAt(i));
			
            children = new Dictionary(true);
            
 			graphics = _container.graphics;	
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
				layerGraphics.lineStyle();
	            layerGraphics.moveTo(v0x, v0y);
	            layerGraphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            layerGraphics.lineTo(v1x, v1y);
	            layerGraphics.lineTo(v2x, v2y);
	            layerGraphics.endFill();
	  		} else {
	  			graphics.lineStyle();
	            graphics.moveTo(v0x, v0y);       
	            graphics.beginBitmapFill(bitmap, m, repeat, smooth && (v0x*(d2 - b2) - v1x*d2 + v2x*b2 > 400));
	            graphics.lineTo(v1x, v1y);
	            graphics.lineTo(v2x, v2y);
	            graphics.endFill();
	  		}
        }
        
        public override function renderBitmap(bitmap:BitmapData, v0:ScreenVertex, smooth:Boolean = false):void
        {
        	if (_layerDirty)
        		createLayer();
        	
        	m.identity();
        	m.tx = v0.x-bitmap.width/2; m.ty = v0.y-bitmap.height/2;
            graphics.lineStyle();
            graphics.beginBitmapFill(bitmap, m, false,smooth);
            graphics.drawRect(v0.x-bitmap.width/2, v0.y-bitmap.height/2, bitmap.width, bitmap.height);
            graphics.endFill();
        }
        
        /**
         * Renders bitmap with precalculated matrix to screen.
         */
        public override function renderScaledBitmap(primitive:DrawScaledBitmap, bitmap:BitmapData, mapping:Matrix, smooth:Boolean = false):void
        {
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
        }
        
        public override function renderTriangleColor(color:int, alpha:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {  
        	if (_layerDirty)
        		createLayer();
        	     	
            graphics.lineStyle();
            graphics.moveTo(v0.x, v0.y); // Always move before begin will to prevent bugs
            graphics.beginFill(color, alpha);
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
            graphics.endFill();
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
        }
        
        public override function renderTriangleLineFill(color:int, alpha:Number, wirecolor:int, wirealpha:Number, width:Number, v0:ScreenVertex, v1:ScreenVertex, v2:ScreenVertex):void
        {
        	if (_layerDirty)
        		createLayer();
        	
            if (wirealpha > 0)
                graphics.lineStyle(width, wirecolor, wirealpha);
            else
                graphics.lineStyle();
    
            graphics.moveTo(v0.x, v0.y);

            if (alpha > 0)
                graphics.beginFill(color, alpha);
    
            graphics.lineTo(v1.x, v1.y);
            graphics.lineTo(v2.x, v2.y);
    
            if (wirealpha > 0)
                graphics.lineTo(v0.x, v0.y);
    
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
        
        public override function flush():void
        {
        	super.flush();
       		// NOP
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
        	return new SpriteRenderSession();
        }
	}
}