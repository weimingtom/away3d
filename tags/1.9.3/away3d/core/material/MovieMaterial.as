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
    public class MovieMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var movie:Sprite;
        private var lastsession:int;
        public var transparent:Boolean;
        public var auto:Boolean;
        public var interactive:Boolean;
        
        public override function get width():Number
        {
            return movie.width;
        }

        public override function get height():Number
        {
            return movie.height;
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
        	super(_bitmap, init);
        	
            this.movie = movie;

            init = Init.parse(init);

            transparent = init.getBoolean("transparent", true);
            auto = init.getBoolean("auto", true);
            interactive = init.getBoolean("interactive", false);

            _bitmap = _renderBitmap = new BitmapData(movie.width, movie.height, transparent, (transparent)? 0x00FFFFFF : 0xFF000000);
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
                	
                }
                	
            }
			
            super.renderTriangle(tri);
        }
        
        public function update():void
        {
            if(transparent ) _renderBitmap.fillRect(_renderBitmap.rect, 0x00FFFFFF);
            _renderBitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), movie.transform.colorTransform);
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
 		
 		public function resetInteractiveLayer():void
 		{
 			movie.x = -10000;
 			movie.y = -10000;
 		}
 		
    }
}
