package away3d.core.base
{
    import away3d.core.*;
    import away3d.materials.*;
    import away3d.core.math.*;
    
    import flash.geom.Matrix;
    import flash.events.Event;
	
    /**
    * Interface for objects that can animate the vertex values in a mesh
    */
    public interface IAnimation
    {
		
		/**
		 * Updates the positions of vertex objects in the mesh to the current frame values
		 * 
		 * @param	mesh	The mesh on which the animation object acts
		 * 
		 * @see away3d.core.base.Frame
		 */
        function update(mesh:BaseMesh):void;
    }
}
