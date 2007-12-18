package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Matrix;

    /** Material that can render a Sprite on object */
    public class MovieMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var movie:Sprite;
        private var _bitmap:BitmapData;
        private var lastsession:int;
        public var transparent:Boolean;
        public var smooth:Boolean;
        public var repeat:Boolean;
        public var debug:Boolean;
        public var auto:Boolean;
        public var interactive:Boolean;
        
        protected var session:RenderSession;
        
        public function get width():Number
        {
            return movie.width;
        }

        public function get height():Number
        {
            return movie.height;
        }
        
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
        public function get scale():Number2D
        {
            return new Number2D(0, 0);
        }
        
        public function get normal():Number3D
        {
            return new Number3D(0, 0, 0);
        }

        public function MovieMaterial(movie:Sprite, init:Object = null)
        {
            this.movie = movie;

            init = Init.parse(init);

            transparent = init.getBoolean("transparent", true);
            smooth = init.getBoolean("smooth", false);
            repeat = init.getBoolean("repeat", false);
            debug = init.getBoolean("debug", false);
            auto = init.getBoolean("auto", true);
            interactive = init.getBoolean("interactive", false);

            this._bitmap = new BitmapData(movie.width, movie.height, transparent);
        }
        
        public function renderTriangle(tri:DrawTriangle):void
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
                	
                }
                	
            }
			
            session.renderTriangleBitmap(_bitmap, tri.texturemapping || tri.transformUV(this), tri.v0, tri.v1, tri.v2, smooth, repeat);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
		
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function update():void
        {
            _bitmap.fillRect(_bitmap.rect, 0);
            _bitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), movie.transform.colorTransform);
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
			movie.x = event.screenX - event.uv.u*movie.width;
			movie.y = event.screenY - (1 - event.uv.v)*movie.height;
		}
						
        public function get visible():Boolean
        {
            return true;
        }
 		
 		public function resetInteractiveLayer():void
 		{
 			movie.x = -10000;
 			movie.y = -10000;
 		}
 		
    }
}
