package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;
    import flash.geom.*;

    public class TransformBitmapMaterial extends BitmapMaterial
    {
        protected var _transform:Matrix;
        protected var _normal:Number3D;
        protected var _scalex:Boolean;
        protected var _scaley:Boolean;
        
        public function get transform():Matrix
        {
            return _transform;
        }
        
        public function get normal():Number3D
        {
            return _normal;
        }
        
        public function get scalex():Boolean
        {
            return _scalex;
        }
        
        public function get scaley():Boolean
        {
            return _scaley;
        }
        
        public function TransformBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);
            
            init = Init.parse(init);

            _transform = init.getObject("transform", new Matrix());
            _normal = init.getNumber3D("normal");
            _scalex = init.getBoolean("scalex", false);
            _scaley = init.getBoolean("scaley", false);
            
            //var b:BitmapData = bitmap;
            //if (!_repeat) {
            //  b = new BitmapData(bitmap.width+2, bitmap.height+2, true, 0x000000);
            //  b.copyPixels(bitmap, new Rectangle(0,0,bitmap.width, bitmap.height), new Point(1,1));
            //}
            //this.bitmap = b;
        }

        public function getMaterialTransform(w:Number, h:Number):Matrix
        {
            var t:Matrix = _transform.clone();
            t.invert();
            if (_normal.modulo > 0) {
                t.scale(1 / width, 1 / height);
            } else {
                t.scale(_scalex ? 1 / width : 1 / w, _scaley ? 1 / height : 1 / h);
            }
            return t;
        }

    }
}
