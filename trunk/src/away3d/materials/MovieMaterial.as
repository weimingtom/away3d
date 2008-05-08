package away3d.materials
{
    import away3d.core.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.geom.ColorTransform;
    import flash.geom.Matrix;

    /** Material that can render a Sprite on object */
    public class MovieMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var movie:Sprite;
        private var lastsession:int;
        public var transparent:Boolean;
        public var auto:Boolean;
        public var interactive:Boolean;
        
        public override function get width():Number
        {
            return _renderBitmap.width;
        }

        public override function get height():Number
        {
            return _renderBitmap.height;
        }
        
        public function get scale():Number2D
        {
            return new Number2D(0, 0);
        }
        
        public function get normal():Number3D
        {
            return new Number3D(0, 0, 0);
        }
		
		internal override function updateRenderBitmap():void
        {
        	
        }
        
        public function MovieMaterial(movie:Sprite, init:Object = null)
        {
            this.movie = movie;

            init = Init.parse(init);

            transparent = init.getBoolean("transparent", true);
            auto = init.getBoolean("auto", true);
            interactive = init.getBoolean("interactive", false);

            _bitmap = new BitmapData(movie.width, movie.height, transparent, 0);
            
        	super(_bitmap, init);
        }
        
        public override function renderTriangle(tri:DrawTriangle):void
        {
        	session = tri.source.session;
        	
            if (lastsession != session.time)
            {
                lastsession = session.time;
                if (auto)
                	update();
                if (interactive) {
                	//check to see if interactiveLayer is initialised
	                if (!session.view.interactiveLayer.contains(movie)) {
                		session.view.interactiveLayer.addChild(movie);
                		resetInteractiveLayer();
                		tri.source.addOnMouseOver(onMouseOver);
                		tri.source.addOnMouseOut(onMouseOut);
	                }
                	
                } else if (session.view.interactiveLayer.contains(movie)) {
                	session.view.interactiveLayer.removeChild(movie);
                	tri.source.removeOnMouseOver(onMouseOver);
                	tri.source.removeOnMouseOut(onMouseOut);
                }
                	
            }
			
            super.renderTriangle(tri);
        }
        
        internal var colTransform:ColorTransform;
        internal var bMode:String;
        
        public function update():void
        {
            if (transparent) _renderBitmap.fillRect(_renderBitmap.rect, 0);
            
            if (_alpha != 1 || _color != 0xFFFFFF)
            	colTransform = _colorTransform;
            else
            	colTransform = movie.transform.colorTransform;
            	
            if (_blendMode != BlendMode.NORMAL)
            	bMode = _blendMode;
            else
            	bMode = movie.blendMode;
            
            _renderBitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), colTransform, bMode, _renderBitmap.rect);
        }
		
		public function onMouseOver(event:MouseEvent3D):void
		{
			if (event.material == this) {
				event.object.addOnMouseMove(onMouseMove);
				onMouseMove(event);
			}
		}
		
		public function onMouseOut(event:MouseEvent3D):void
		{
			if (event.material == this) {
				event.object.removeOnMouseMove(onMouseMove);
				resetInteractiveLayer();
			}
			
		}
		
		public function onMouseMove(event:MouseEvent3D):void
		{
			x = event.uv.u*_renderBitmap.width;
			y = (1 - event.uv.v)*_renderBitmap.height;
			t = _transform.clone();
			t.invert();
			movie.x = event.screenX - x*t.a - y*t.c - t.tx;
			movie.y = event.screenY - x*t.b - y*t.d - t.ty;
		}
 		
 		public function resetInteractiveLayer():void
 		{
 			movie.x = -10000;
 			movie.y = -10000;
 		}
 		
    }
}
