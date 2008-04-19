package away3d.materials
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;

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

        public function renderSegment(seg:DrawSegment):void
        {
            if (alpha <= 0)
                return;
			
			seg.source.session.renderLine(seg.v0, seg.v1, width, color, alpha);
        }

        public function renderTriangle(tri:DrawTriangle):void
        {
            if (alpha <= 0)
                return;

            tri.source.session.renderTriangleLine(width, color, alpha, tri.v0, tri.v1, tri.v2);
        }
        
        public function get visible():Boolean
        {
            return (alpha > 0);
        }
 
    }
}
