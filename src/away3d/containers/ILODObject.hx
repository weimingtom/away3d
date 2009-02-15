package away3d.containers;

import away3d.cameras.Camera3D;


/**
 * Interface for objects that can toggle their visibily depending on view and distance to camera
 */
interface ILODObject  {
	
	function matchLOD(camera:Camera3D):Bool;

	

}

