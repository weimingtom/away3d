package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;

    import flash.display.Graphics;

    public interface ISegmentMaterial extends IMaterial
    {
        function renderSegment(seg:DrawSegment, graphics:Graphics, clip:Clipping):void;
    }
}
