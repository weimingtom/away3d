package away3d.materials;

import away3d.containers.View3D;
import away3d.core.base.Object3D;


/**
 * Interface for all objects that can serve as a material
 */
interface IMaterial  {
	var visible(getVisible, null) : Bool;
	
	function getVisible():Bool;

	function updateMaterial(source:Object3D, view:View3D):Void;

	function addOnMaterialUpdate(listener:Dynamic):Void;

	function removeOnMaterialUpdate(listener:Dynamic):Void;

	

}

