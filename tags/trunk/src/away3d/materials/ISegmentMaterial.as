package away3d.materials
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.base.*
    import away3d.core.draw.*;
    import away3d.core.render.*;

    /** Interface for all material that are capable of drawing line segments */
    public interface ISegmentMaterial extends IMaterial
    {
        function renderSegment(seg:DrawSegment):void;
    }
}
