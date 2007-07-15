package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.*;

    /** Material for solid color drawing with face's border outlining */
    public class WireframeMaterial implements ITriangleMaterial, ISegmentMaterial
    {
        public var color:int;
        public var alpha:Number;
        public var width:Number;

        public function WireframeMaterial(color:* = null, init:Object = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            init = Init.parse(init);
            alpha = init.getNumber("alpha", 1, {min:0, max:1});
            width = init.getNumber("width", 1, {min:0});
        }

        public function renderSegment(seg:DrawSegment, session:RenderSession):void
        {
            if (alpha <= 0)
                return;

            var graphics:Graphics = session.graphics;
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(seg.v0.x, seg.v0.y);
            graphics.lineTo(seg.v1.x, seg.v1.y);
            graphics.moveTo(seg.v0.x, seg.v0.y); // ????? bug?
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            if (alpha <= 0)
                return;

            var graphics:Graphics = session.graphics;
            graphics.lineStyle(width, color, alpha);
            graphics.moveTo(tri.v0.x, tri.v0.y);
            graphics.lineTo(tri.v1.x, tri.v1.y);
            graphics.lineTo(tri.v2.x, tri.v2.y);
            graphics.lineTo(tri.v0.x, tri.v0.y);
        }

        public function get visible():Boolean
        {
            return (alpha > 0);
        }
 
    }
}
