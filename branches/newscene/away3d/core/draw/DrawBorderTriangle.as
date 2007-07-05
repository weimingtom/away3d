package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.geom.*;
    import away3d.core.render.*;

    import flash.display.Graphics;
    import flash.display.BitmapData;
    import flash.geom.Matrix;

    /** Triangle drawing primitive with custom borders */
    public class DrawBorderTriangle extends DrawTriangle
    {
        public var s01material:ISegmentMaterial;
        public var s12material:ISegmentMaterial;
        public var s20material:ISegmentMaterial;

        public override function render(session:RenderSession):void
        {
            if (s01material != null)
                s01material.renderSegment(DrawSegment.create(source, s01material, projection, v0, v1), session);
            if (s12material != null)
                s12material.renderSegment(DrawSegment.create(source, s12material, projection, v1, v2), session);
            if (s20material != null)
                s20material.renderSegment(DrawSegment.create(source, s20material, projection, v2, v0), session);

            material.renderTriangle(this, session);
        }
    }
}
