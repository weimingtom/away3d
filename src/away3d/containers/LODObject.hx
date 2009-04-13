package away3d.containers;

import away3d.cameras.Camera3D;
import flash.events.EventDispatcher;
import away3d.core.utils.Init;
import away3d.core.base.Object3D;


/**
 * 3d object container that is drawn only if its scaling to perspective falls within a given range.
 */
class LODObject extends ObjectContainer3D, implements ILODObject {
	
	/**
	 * The maximum perspective value from which the 3d object can be viewed.
	 */
	public var maxp:Float;
	/**
	 * The minimum perspective value from which the 3d object can be viewed.
	 */
	public var minp:Float;
	

	/**
	 * Creates a new <code>LODObject</code> object.
	 * 
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 * @param	...childarray				An array of children to be added on instatiation.
	 */
	public function new(?init:Dynamic=null, ?childarray:Array<Object3D>) {
		if (childarray == null) childarray = new Array<Object3D>();
		
		
		super(init);
		maxp = ini.getNumber("maxp", Math.POSITIVE_INFINITY);
		minp = ini.getNumber("minp", 0);
		for (__i in 0...childarray.length) {
			var child:Object3D = childarray[__i];

			if (child != null) {
				addChild(child);
			}
		}

	}

	/**
	 * @inheritDoc
	 * 
	 * @see	away3d.core.traverse.ProjectionTraverser
	 * @see	#maxp
	 * @see	#minp
	 */
	public function matchLOD(camera:Camera3D):Bool {
		
		var z:Float = camera.view.cameraVarsStore.viewTransformDictionary.get(this).tz;
		var persp:Float = camera.zoom / (1 + z / camera.focus);
		if (persp < minp) {
			return false;
		}
		if (persp >= maxp) {
			return false;
		}
		return true;
	}

}

