package away3d.core.filter;

import away3d.containers.Scene3D;
import away3d.cameras.Camera3D;
import away3d.core.clip.Clipping;
import away3d.core.draw.DrawPrimitive;

/**
 * Interface for filters that work on primitive arrays
 */
interface IPrimitiveFilter  {
	
	function filter(primitives:Array<DrawPrimitive>, scene:Scene3D, camera:Camera3D, clip:Clipping):Array<DrawPrimitive>;

	

}

