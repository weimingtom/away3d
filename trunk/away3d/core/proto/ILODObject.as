package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.proto.*;
    import away3d.core.math.*;

    public interface ILODObject
    {
        function matchLOD(view:View3D, transform:Matrix3D):Boolean;
    }
}
