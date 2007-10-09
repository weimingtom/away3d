package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.*;
    import flash.geom.*;

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        private var _bitmap:BitmapData;
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
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            this._bitmap = bitmap;
            
            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
        }
        
        internal var mapping:Matrix;
        
        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
        	mapping = tri.texturemapping || tri.transformUV(this);
        	
			session.renderTriangleBitmap(_bitmap, mapping, tri.v0, tri.v1, tri.v2, smooth, repeat);
			
            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
        }

        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
