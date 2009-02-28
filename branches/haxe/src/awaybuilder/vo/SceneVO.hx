package awaybuilder.vo;

import flash.display.Sprite;
import away3d.containers.View3D;


class SceneVO  {
	
	public var id:String;
	public var name:String;
	public var container:Sprite;
	public var cameras:Array<Dynamic>;
	public var geometry:Array<Dynamic>;
	public var sections:Array<Dynamic>;
	public var view:View3D;
	public var cameraOrigin:SceneObjectVO;
	public var cameraTarget:SceneObjectVO;
	public var zoom:Float;
	public var focus:Float;
	public var materials:Array<Dynamic>;
	

	public function new() {
		
		
		this.cameras = new Array();
		this.geometry = new Array();
		this.sections = new Array();
		this.materials = new Array();
	}

}

