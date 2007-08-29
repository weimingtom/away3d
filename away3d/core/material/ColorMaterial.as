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
    public class ColorMaterial implements ITriangleMaterial
    {
        public var color:uint;
        public var alpha:Number;

        public function ColorMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            init = Init.parse(init);
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            session.renderTriangleColor(color, alpha, tri);
        }

        public function get visible():Boolean
        {
            return (alpha > 0);
        }
    }
}
