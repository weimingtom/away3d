package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;
    import flash.geom.*;

    import mx.core.BitmapAsset;

    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var bitmap:BitmapData;
        public var smooth:Boolean = false;
        public var debug:Boolean = false;
        
        protected var _transform:Matrix = new Matrix();
        protected var _normal:Number3D = new Number3D(0,0,0);
        protected var _repeat:Boolean = false;
        protected var _scalex:Boolean = false;
        protected var _scaley:Boolean = false;
        
        public function get width():Number
        {
            return bitmap.width;
        }

        public function get height():Number
        {
            return bitmap.height;
        }
        
        public function get transform():Matrix
        {
            return _transform;
        }
        
        public function get normal():Number3D
        {
            return _normal;
        }
        
        public function get repeat():Boolean
        {
            return _repeat;
        }
        
        public function get scalex():Boolean
        {
            return _scalex;
        }
        
        public function get scaley():Boolean
        {
            return _scaley;
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            this.bitmap = bitmap;
			
            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            _transform = init.getObject("transform", new Matrix());
            _normal = init.getNumber3D("normal");
			_repeat = init.getBoolean("repeat", false);
            _scalex = init.getBoolean("scalex", false);
			_scaley = init.getBoolean("scaley", false);
			
			//var b:BitmapData = bitmap;
            //if (!_repeat) {
            //	b = new BitmapData(bitmap.width+2, bitmap.height+2, true, 0x000000);
            //	b.copyPixels(bitmap, new Rectangle(0,0,bitmap.width, bitmap.height), new Point(1,1));
            //}
            //this.bitmap = b;
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var graphics:Graphics = session.graphics;

            RenderTriangle.renderBitmap(graphics, bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);

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
