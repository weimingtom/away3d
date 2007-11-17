package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;

    /** Interface for object that can toggle their visibily depending on view and distance to camera */
    public interface ILODObject
    {
        function matchLOD(view:View3D):Boolean;
    }
}
