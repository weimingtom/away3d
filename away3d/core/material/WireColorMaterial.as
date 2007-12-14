package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

    import flash.display.Graphics;
    import flash.display.*;

    /** Material for solid color drawing with face's border outlining */
    public class WireColorMaterial implements ITriangleMaterial
    {
        public var color:int;
        public var alpha:Number;

        public var width:Number;
        public var wirecolor:int;
        public var wirealpha:Number;

        public function WireColorMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            init = Init.parse(init);
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
            wirecolor = init.getColor("wirecolor", 0x000000);
            width = init.getNumber("width", 1, {min:0});
            wirealpha = init.getNumber("wirealpha", 1, {min:0, max:1});
        }
		
		internal var graphics:Graphics;
		
        public function renderTriangle(tri:DrawTriangle):void
        {
			tri.source.session.renderTriangleLineFill(color, alpha, wirecolor, wirealpha, width, tri.v0, tri.v1, tri.v2);
        }
		
		public function shadeTriangle(tri:DrawTriangle):void
        {
        	//tri.bitmapMaterial = getBitmapReflection(tri, source);
        }
        
        public function get visible():Boolean
        {
            return (alpha > 0) || (wirealpha > 0);
        }
 
    }
}
