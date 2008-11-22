package away3d.materials;

    import away3d.core.draw.*;

    /**
    * Interface for materials that are capable of rendering triangle faces.
    */
    interface ITriangleMaterial implements IMaterial{
    	/**
    	 * Sends data from the material coupled with data from the <code>DrawTriangle</code> primitive to the render session.
    	 */
        function renderTriangle(tri:DrawTriangle):Void;
    }
