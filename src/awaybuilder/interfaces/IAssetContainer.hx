package awaybuilder.interfaces;

import flash.display.BitmapData;
import flash.display.DisplayObject;


interface IAssetContainer  {
	
	function addBitmapDataAsset(id:String, data:BitmapData):Void;

	function addDisplayObjectAsset(id:String, data:DisplayObject):Void;

	function addColladaAsset(id:String, data:Xml):Void;

	

}

