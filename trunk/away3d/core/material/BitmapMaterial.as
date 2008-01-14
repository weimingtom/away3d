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

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        internal var _bitmap:BitmapData;
        internal var _transform:Matrix;
        internal var transformDirty:Boolean;
        
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        
        public function get width():Number
        {
            return _bitmap.width;
        }

        public function get height():Number
        {
            return _bitmap.height;
        }
        
        public function get bitmap():BitmapData
        {
        	return _bitmap;
        }
        
        public function get transform():Matrix
        {
        	return _transform;
        }
        
        public function set transform(val:Matrix):void
        {
        	_transform = val;
        	transformDirty = true;
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            this._bitmap = bitmap;
            
            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
            transform = init.getObject("transform", Matrix);
        }
        
        internal var mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle):void
        {
        	
        	//check local transform or if texturemapping is null
        	if (transformDirty || !tri.texturemapping) {
        		transformDirty = false;
        		mapping = tri.transformUV(this);
        		if (_transform) {
	        		mapping = _transform.clone();
	        		mapping.concat(tri.texturemapping);
	        		tri.texturemapping = mapping;
	        	}
        	} else {
        		mapping = tri.texturemapping;
        	}
        	
			tri.source.session.renderTriangleBitmap(_bitmap, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
            if (debug)
                tri.source.session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }
		
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
