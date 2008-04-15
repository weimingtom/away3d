package away3d.materials
{
    import away3d.containers.View3D;
    import away3d.core.base.*;	
    /** Interface for all materials that require updating every render loop*/
    public interface IUpdatingMaterial
    {
        function updateMaterial(source:Object3D, view:View3D):void;
    }
}
