package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;

    /** Bitmap texture material with adjustable transparency */
    public class AlphaBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        private var _bitmap:BitmapData;
        
        public function get bitmap():BitmapData
        {
            return _bitmap;
        }

        public function set bitmap(value:BitmapData):void
        {
            _bitmap = value;
            _cache = new Dictionary();
            updateCurrent();
        }
                   
        private var _current:BitmapData;
        private var _cache:Dictionary;

        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        private var _alpha:Number;
        private var _grades:int;
        
        public function get alpha():Number
        {
            return _alpha;
        }

        public function set alpha(value:Number):void
        {
            if (value > 1)
                value = 1;

            if (value < 0)
                value = 0;

            if (value == _alpha)
                return;

            value = Math.round(value*(_grades-1))/(_grades-1);

            _alpha = value;

            updateCurrent();
        }

        private function updateCurrent():void
        {
            if (_alpha == 1)
            {
                _current = _bitmap;
                return;
            }

            if (_alpha == 0)
            {
                _current = null;
                return;
            }

            _current = _cache[_alpha];
            if (_current == null)
            {
                _current = _bitmap.clone();
                _current.colorTransform(_current.rect, new ColorTransform(1, 1, 1, _alpha));
                _cache[_alpha] = _current;
            }
        }

        public function get width():Number
        {
            return _bitmap.width;
        }

        public function get height():Number
        {
            return _bitmap.height;
        }
        
        public function AlphaBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            _bitmap = bitmap;
            if (!bitmap.transparent)
            {
                _bitmap = new BitmapData(bitmap.width, bitmap.height, true);
                _bitmap.draw(bitmap);
            }

            _current = _bitmap;
            _cache = new Dictionary();
            
            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
            _grades = init.getInt("grades", 32, {min:2, max:256});
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var mapping:Matrix = tri.texturemapping || tri.transformUV(this);
            var v0:Vertex2D = tri.v0;
            var v1:Vertex2D = tri.v1;
            var v2:Vertex2D = tri.v2;
            var graphics:Graphics = session.graphics;

            RenderTriangle.renderBitmap(graphics, _current, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);

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
            return _alpha > 0;
        }
 
    }
}
