package away3d.core.mesh
{
    import away3d.core.*;
    import away3d.core.material.*;
    import away3d.core.math.*;
    import away3d.core.mesh.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public interface IFrame
    {
        function adjust(oldk:Number = 0, newk:Number = 1):void;
    }
}
