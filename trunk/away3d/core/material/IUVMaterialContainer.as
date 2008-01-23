package away3d.core.material
{
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.mesh.Mesh;
    import away3d.core.scene.*;
    
    import flash.geom.*;
	
    /** Interface for all materials that take in account texture coordinates */
    public interface IUVMaterialContainer extends IUVMaterial
    {
    	function renderMaterial(source:Mesh):void;
    	function resetMaterial(source:Mesh):void;
    }
}
