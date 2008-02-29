package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.scene.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
    import flash.geom.*;
    import flash.utils.*;

    /** Bitmap texture material with adjustable transparency */
    public class AlphaBitmapMaterial extends TransformBitmapMaterial implements ITriangleMaterial, IUVMaterial
    {

        public function set bitmap(value:BitmapData):void
        {
            _bitmap = value;
            _cache = new Dictionary();
            updateCurrent();
        }
        
        private var _cache:Dictionary;
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
            if (_alpha == 1) {
                _renderBitmap = _bitmap;
                return;
            }

            if (_alpha == 0) {
                _renderBitmap = null;
                return;
            }

            _renderBitmap = _cache[_alpha];
            if (_renderBitmap == null) {
                _renderBitmap = _bitmap.clone();
                _renderBitmap.colorTransform(_renderBitmap.rect, new ColorTransform(1, 1, 1, _alpha));
                _cache[_alpha] = _renderBitmap;
            }
        }
        
        public function AlphaBitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            super(bitmap, init);
            
            if (!bitmap.transparent) {
                _bitmap = new BitmapData(bitmap.width, bitmap.height, true);
                _bitmap.draw(bitmap);
            }

            _renderBitmap = _bitmap;
            _cache = new Dictionary();
            
            init = Init.parse(init);
            
            _grades = init.getInt("grades", 32, {min:2, max:256});
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
        }
        
        public override function get visible():Boolean
        {
            return _alpha > 0;
        }
 
    }
}
