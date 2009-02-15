package away3d.core.light;

import away3d.core.base.Object3D;


/**
 * Interface for objects that provide lighting to the scene
 */
interface ILightProvider  {
	var debug(getDebug, null) : Bool;
	var debugPrimitive(getDebugPrimitive, null) : Object3D;
	
	function light(consumer:ILightConsumer):Void;

	function getDebug():Bool;

	function getDebugPrimitive():Object3D;

	

}

