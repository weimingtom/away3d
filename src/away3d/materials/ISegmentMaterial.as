package away3d.materials
{
    import away3d.core.draw.*;

    /** Interface for all material that are capable of drawing line segments */
    public interface ISegmentMaterial extends IMaterial
    {
        function renderSegment(seg:DrawSegment):void;
    }
}
