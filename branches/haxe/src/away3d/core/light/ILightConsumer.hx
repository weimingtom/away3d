package away3d.core.light;



/**
 * Interface for containers capable of storing lighting info
 */
interface ILightConsumer  {
	var ambients(getAmbients, null) : Array<Dynamic>;
	var directionals(getDirectionals, null) : Array<Dynamic>;
	var points(getPoints, null) : Array<Dynamic>;
	var numLights(getNumLights, null) : Int;
	
	function getAmbients():Array<Dynamic>;

	function getDirectionals():Array<Dynamic>;

	function getPoints():Array<Dynamic>;

	function getNumLights():Int;

	function ambientLight(ambient:AmbientLight):Void;

	function directionalLight(directional:DirectionalLight):Void;

	function pointLight(point:PointLight):Void;

	function clear():Void;

	

}

