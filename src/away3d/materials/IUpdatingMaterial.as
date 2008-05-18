package away3d.materials
{
    import away3d.containers.View3D;
    import away3d.core.base.*;	
    
    /**
    * Interface for materials that require updating every render loop
    */
    public interface IUpdatingMaterial
    {
    	/**
    	 * Called once per render loop when material is visible.
    	 */
        function updateMaterial(source:Object3D, view:View3D):void;
    }
}
