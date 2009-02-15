package away3d.core.block;

import away3d.core.base.Object3D;
import away3d.core.math.Matrix3D;


/**
 * Interface for objects that provide blocker instances for occlusion culling in the renderer.
 */
interface IBlockerProvider  {
	
	function blockers(source:Object3D, viewTransform:Matrix3D, consumer:IBlockerConsumer):Void;

	

}

