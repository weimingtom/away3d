package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;

    public interface IAnimation
    {
        function update(mesh:BaseMesh):void;
    }
}
