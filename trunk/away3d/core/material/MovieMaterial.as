package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.BitmapData;
    import flash.display.Sprite;
    import flash.geom.Matrix;

    /** Material that can render a Sprite on object */
    public class MovieMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var movie:Sprite;
        public var bitmap:BitmapData;
        private var lastsession:int;
        public var transparent:Boolean;
        public var smooth:Boolean;
        public var repeat:Boolean;
        public var debug:Boolean;
        public var auto:Boolean;
        
        public function get width():Number
        {
            return movie.width;
        }

        public function get height():Number
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
            this.movie = movie;

            init = Init.parse(init);

            transparent = init.getBoolean("transparent", false);
            smooth = init.getBoolean("smooth", false);
            repeat = init.getBoolean("repeat", false);
            debug = init.getBoolean("debug", false);
            auto = init.getBoolean("auto", true);

            this.bitmap = new BitmapData(movie.width, movie.height, transparent);
        }
        
        internal var mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            if (auto)
                if (lastsession != session.time)
                {
                    lastsession = session.time;
                    update();
                }
			
			mapping = tri.texturemapping || tri.transformUV(this);
			
            session.renderTriangleBitmap(bitmap, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }

        public function update():void
        {
            bitmap.fillRect(bitmap.rect, 0);
            bitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), movie.transform.colorTransform);
        }

        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
