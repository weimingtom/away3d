package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.math.*;

    public interface ILODObject
    {
        function matchLOD(camera:Camera3D, view:Matrix3D):Boolean;
    }
}
