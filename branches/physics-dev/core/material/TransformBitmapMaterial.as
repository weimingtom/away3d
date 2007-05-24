package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;
    import flash.geom.*;

    public class TransformBitmapMaterial extends PreciseBitmapMaterial
    {
    	private var u:Number3D;
    	private var v:Number3D;
    	
        protected var _transform:Matrix;
        protected var _normal:Number3D;
        protected var _scalex:Boolean;
        protected var _scaley:Boolean;
        protected var _isNormalized:Boolean;
        
        public function get transform():Matrix
        {
            return _transform;
        }
        
        public function get normal():Number3D
        {
            return _normal;
        }
        
        public function get isNormalized():Boolean
        {
            return _isNormalized;
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
            
            _isNormalized = _normal.modulo > 0;
            
            //correct texture error for normals aligned to axis
            if (_normal.x < 0.001) _normal.x = 0.001;
            if (_normal.y < 0.001) _normal.y = 0.001;
            if (_normal.z < 0.001) _normal.z = 0.001;
            _normal.normalize();
            Debug.trace("_normal");
            Debug.trace(_normal);
            u = Number3D.cross(_normal, new Number3D(0,1,0));
            if (!u.modulo) u = new Number3D(1,0,0);
        	v = Number3D.cross(u, _normal);
        	u = Number3D.cross(v, _normal);
        	u.normalize();
        	v.normalize();
        	
            //Debug.trace(u);
            //v = Number3D.cross(_normal as Number3D, new Number3D(1,0,0));
            //if (v.modulo) v.normalize();
            //else v = new Number3D(0,1,0);
            Debug.trace(v);
            //var b:BitmapData = bitmap;
            //if (!_repeat) {
            //  b = new BitmapData(bitmap.width+2, bitmap.height+2, true, 0x000000);
            //  b.copyPixels(bitmap, new Rectangle(0,0,bitmap.width, bitmap.height), new Point(1,1));
            //}
            //this.bitmap = b;
        }

        public function getTransform(w:Number, h:Number):Matrix
        {
            var t:Matrix = _transform.clone();
            t.invert();
            t.scale(_scalex ? 1 / width : 1 / w, _scaley ? 1 / height : 1 / h);
            //t.b = 0.5
            //t.c = 0.5;
            return t;
        }
        
        public function setUVPoint(uv:Point, p:Number3D):void
        {
        	uv.x = Number3D.dot(p, u);
            uv.y = Number3D.dot(p, v);
            
        }
    }
}
