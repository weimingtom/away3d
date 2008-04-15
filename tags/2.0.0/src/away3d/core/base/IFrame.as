package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    import away3d.core.base.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public interface IFrame
    {
        function adjust(oldk:Number = 0, newk:Number = 1):void;
    }
}
