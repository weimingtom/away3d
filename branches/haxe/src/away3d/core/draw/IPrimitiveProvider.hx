package away3d.core.draw;

import away3d.core.base.Object3D;
import away3d.core.math.Matrix3D;


/**
 * Interface for objects that provide drawing primitives to the rendering process
 */
interface IPrimitiveProvider  {
	
	function primitives(source:Object3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void;

	

}

