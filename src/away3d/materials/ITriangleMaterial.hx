package away3d.materials;

import away3d.core.draw.DrawTriangle;


/**
 * Interface for materials that are capable of rendering triangle faces.
 */
interface ITriangleMaterial implements IMaterial  {
	
	function renderTriangle(tri:DrawTriangle):Void;

	

}

