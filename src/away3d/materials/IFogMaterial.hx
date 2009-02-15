package away3d.materials;

import away3d.core.draw.DrawFog;


/**
 * Interface for fog filter materials
 */
interface IFogMaterial implements ITriangleMaterial  {
	var alpha(getAlpha, setAlpha) : Float;
	
	function getAlpha():Float;

	function setAlpha(val:Float):Void;

	function renderFog(fog:DrawFog):Void;

	function clone():IFogMaterial;

	

}

