package away3d.core.light;



/**
 * Interface for containers capable of storing lighting info
 */
interface ILightConsumer  {
	var ambients(getAmbients, null) : Array<AmbientLight>;
	var directionals(getDirectionals, null) : Array<DirectionalLight>;
	var points(getPoints, null) : Array<PointLight>;
	var numLights(getNumLights, null) : Int;
	
	function getAmbients():Array<AmbientLight>;

	function getDirectionals():Array<DirectionalLight>;

	function getPoints():Array<PointLight>;

	function getNumLights():Int;

	function ambientLight(ambient:AmbientLight):Void;

	function directionalLight(directional:DirectionalLight):Void;

	function pointLight(point:PointLight):Void;

	function clear():Void;

	

}

