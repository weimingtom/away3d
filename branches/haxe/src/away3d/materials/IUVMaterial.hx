package away3d.materials;

import flash.display.BitmapData;
import away3d.containers.View3D;
import away3d.core.base.Object3D;
import away3d.core.utils.FaceVO;
import away3d.core.utils.FaceMaterialVO;


/**
 * Interface for materials that use uv texture coordinates
 */
interface IUVMaterial implements IMaterial  {
	var width(getWidth, null) : Float;
	var height(getHeight, null) : Float;
	var bitmap(getBitmap, null) : BitmapData;
	
	function getWidth():Float;

	function getHeight():Float;

	function getBitmap():BitmapData;

	function getPixel32(u:Float, v:Float):Int;

	function getFaceMaterialVO(faceVO:FaceVO, ?source:Object3D=null, ?view:View3D=null):FaceMaterialVO;

	function clearFaces(?source:Object3D=null, ?view:View3D=null):Void;

	function invalidateFaces(?source:Object3D=null, ?view:View3D=null):Void;

	

}

