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
        public var bitmap:BitmapData;
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        
        public function get width():Number
        {
            return bitmap.width;
        }

        public function get height():Number
        {
            return bitmap.height;
        }
        
        public function BitmapMaterial(bitmap:BitmapData, init:Object = null)
        {
            this.bitmap = bitmap;
            
            init = Init.parse(init);

            smooth = init.getBoolean("smooth", false);
            debug = init.getBoolean("debug", false);
            repeat = init.getBoolean("repeat", false);
        }
		
		internal var mapping:Matrix;
        internal var v0:ScreenVertex;
        internal var v1:ScreenVertex;
        internal var v2:ScreenVertex;
        
        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            mapping = tri.texturemapping || tri.transformUV(this);
           	v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;

            session.renderTriangleBitmap(bitmap, mapping.a, mapping.b, mapping.c, mapping.d, mapping.tx, mapping.ty, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y, smooth, repeat);

            if (debug)
                session.renderTriangleLine(2, 0x0000FF, 1, v0.x, v0.y, v1.x, v1.y, v2.x, v2.y);
        }

        public function get visible():Boolean
        {
            return true;
        }
 
    }
}
