package away3d.core.draw
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.scene.*;
    import away3d.core.mesh.*;
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

        public override function render():void
        {
            if (s01material != null)
                s01material.renderSegment(DrawSegment.create(object, s01material, projection, v0, v1));
            if (s12material != null)
                s12material.renderSegment(DrawSegment.create(object, s12material, projection, v1, v2));
            if (s20material != null)
                s20material.renderSegment(DrawSegment.create(object, s20material, projection, v2, v0));

            material.renderTriangle(this);
        }
    }
}
