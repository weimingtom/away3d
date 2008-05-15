package away3d.containers
{
	
    /**
    * Interface for objects that can toggle their visibily depending on view and distance to camera
    */
    public interface ILODObject
    {      
    	/**
    	 * Used in <code>ProjectionTraverser</code> to determine whether 3d object is visible.
    	 * 
    	 * @see	away3d.core.traverse.ProjectionTraverser
    	 * @see	away3d.containers.LODObject#maxp
    	 * @see	away3d.containers.LODObject#minp
    	 */
        function matchLOD(view:View3D):Boolean;
    }
}
