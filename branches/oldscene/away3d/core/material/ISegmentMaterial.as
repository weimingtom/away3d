package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;

    /** Interface for all material that are capable of drawing line segments */
    public interface ISegmentMaterial extends IMaterial
    {
        function renderSegment(seg:DrawSegment, session:RenderSession):void;
    }
}
