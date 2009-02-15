package away3d.core.filter;

import away3d.containers.Scene3D;
import away3d.cameras.Camera3D;
import away3d.core.clip.Clipping;
import away3d.core.render.QuadrantRenderer;


/**
 * Interface for filters that work on primitive quadrant trees
 */
interface IPrimitiveQuadrantFilter  {
	
	function filter(pritree:QuadrantRenderer, scene:Scene3D, camera:Camera3D, clip:Clipping):Void;

	

}

