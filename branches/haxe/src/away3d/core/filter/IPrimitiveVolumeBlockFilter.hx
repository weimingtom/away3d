package away3d.core.filter;

import away3d.containers.Scene3D;
import away3d.cameras.Camera3D;
import away3d.core.clip.Clipping;
import away3d.core.draw.PrimitiveVolumeBlock;


/**
 * Interface for filters that work on primitive volume blocks
 */
interface IPrimitiveVolumeBlockFilter  {
	
	function filter(blocklist:PrimitiveVolumeBlock, scene:Scene3D, camera:Camera3D, clip:Clipping):Void;

	

}

