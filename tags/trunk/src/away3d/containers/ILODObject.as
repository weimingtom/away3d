package away3d.containers
{
	
    /** Interface for object that can toggle their visibily depending on view and distance to camera */
    public interface ILODObject
    {
        function matchLOD(view:View3D):Boolean;
    }
}
