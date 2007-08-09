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

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:ScreenVertex = tri.v0;
            var v1:ScreenVertex = tri.v1;
            var v2:ScreenVertex = tri.v2;
            
            if (auto)
                if (lastsession != session.time)
                {
                    lastsession = session.time;
                    update();
                }

            session.renderTriangleBitmap(bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
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
