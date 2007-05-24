package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.geom.Matrix;
    import flash.geom.Point;

    public class MovieMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var movie:MovieClip;
        public var bitmap:BitmapData;
        private var lastsession:int;
        public var transparent:Boolean;
        public var debug:Boolean;
        public var smooth:Boolean;
        
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

        public function MovieMaterial(movie:MovieClip, init:Object = null)
        {
            this.movie = movie;

            init = Init.parse(init);

            transparent = init.getBoolean("transparent", false);
            debug = init.getBoolean("debug", false);
            smooth = init.getBoolean("smooth", false);

            this.bitmap = new BitmapData(movie.width, movie.height, transparent);
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var graphics:Graphics = session.graphics;
            
            if (lastsession != session.time)
            {
                lastsession = session.time;
                bitmap.fillRect(bitmap.rect, 0);
                bitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), movie.transform.colorTransform);
            }

            RenderTriangle.renderBitmap(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, false);

            if (debug)
            {
                graphics.lineStyle(2, 0x0000FF);
                graphics.moveTo(tri.v0.x, tri.v0.y);
                graphics.lineTo(tri.v1.x, tri.v1.y);
                graphics.lineTo(tri.v2.x, tri.v2.y);
                graphics.lineTo(tri.v0.x, tri.v0.y);
            }
        }

        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
