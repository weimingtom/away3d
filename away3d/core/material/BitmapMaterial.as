package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.*;
    import flash.geom.*;

    /** Basic bitmap texture material */
    public class BitmapMaterial implements ITriangleMaterial, IUVMaterial
    {
        public var bitmap:BitmapData;
        public var smooth:Boolean;
        public var debug:Boolean;
        public var repeat:Boolean;
        
        public var bounce:Number;
		public var friction:Number;
		public var traction:Number;
		
		internal var mapping:Matrix, v0:Vertex2D, v1:Vertex2D, v2:Vertex2D, graphics:Graphics;
		
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

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            mapping = tri.texturemapping || tri.transformUV(this);
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            graphics = session.graphics;

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
