package awaybuilder.vo;

import away3d.containers.ObjectContainer3D;


class SceneSectionVO  {
	
	public var id:String;
	public var name:String;
	public var values:SceneObjectVO;
	public var pivot:ObjectContainer3D;
	public var cameras:Array<Dynamic>;
	public var geometry:Array<Dynamic>;
	public var sections:Array<Dynamic>;
	public var enabled:Bool;
	

	public function new() {
		this.id = "";
		this.name = "";
		this.cameras = [];
		this.geometry = [];
		this.sections = [];
		this.enabled = true;
		
		
		this.values = new SceneObjectVO();
		this.pivot = new ObjectContainer3D();
	}

}

