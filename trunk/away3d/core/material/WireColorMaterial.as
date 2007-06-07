package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.*;

    /** Material for solid color drawing with face's border outlining */
    public class WireColorMaterial implements ITriangleMaterial, ISegmentMaterial
    {
        public var lineWidth:Number;
        public var lineColor:int;
        public var lineAlpha:Number;

        public var fillColor:int;
        public var fillAlpha:Number;

        public function WireColorMaterial(color:int = -1, wirecolor:int = 0x000000, alpha:Number = 1.0, wirealpha:Number = 1.0, wirewidth:Number = 1)
        {
            if (color == -1)
                color = int(0xFFFFFF * Math.random());

            fillColor = color;
            lineColor = wirecolor;
            fillAlpha = alpha;
            lineAlpha = wirealpha;
            lineWidth = wirewidth;
        }

        public function renderSegment(seg:DrawSegment, session:RenderSession):void
        {
            if (lineAlpha > 0)
            {                                                  
                var graphics:Graphics = session.graphics;
                graphics.lineStyle(lineWidth, lineColor, lineAlpha/*, false, LineScaleMode.NORMAL, CapsStyle.SQUARE*/);
                graphics.moveTo(seg.v0.x, seg.v0.y);
                graphics.lineTo(seg.v1.x, seg.v1.y);
                graphics.moveTo(seg.v0.x, seg.v0.y); // ????? bug?
            }
        }

        public function renderTriangle(tri:DrawTriangle, session:RenderSession):void
        {
            var graphics:Graphics = session.graphics;

            if (lineAlpha > 0)
                graphics.lineStyle(lineWidth, lineColor, lineAlpha);
            else
                graphics.lineStyle();
    
            if (fillAlpha > 0)
                graphics.beginFill(fillColor, fillAlpha);
    
            graphics.moveTo(tri.v0.x, tri.v0.y);
            graphics.lineTo(tri.v1.x, tri.v1.y);
            graphics.lineTo(tri.v2.x, tri.v2.y);
    
            if (lineAlpha > 0)
                graphics.lineTo(tri.v0.x, tri.v0.y);
    
            if (fillAlpha > 0)
                graphics.endFill();
        }

        public function get visible():Boolean
        {
            return (fillAlpha > 0) || (lineAlpha > 0);
        }
 
    }
}
