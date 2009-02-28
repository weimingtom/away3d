package awaybuilder.vo;

import away3d.containers.ObjectContainer3D;
import away3d.cameras.Camera3D;


class SceneCameraVO  {
	
	public var id:String;
	public var name:String;
	public var camera:Camera3D;
	public var values:SceneObjectVO;
	public var extras:Array<Dynamic>;
	public var transitionTime:Float;
	public var transitionType:String;
	public var parentSection:SceneSectionVO;
	public var positionContainer:ObjectContainer3D;
	

	public function new() {
		this.id = "";
		this.name = "";
		this.extras = [];
		this.transitionTime = 2;
		this.transitionType = "Cubic.easeInOut";
		
		
		this.camera = new Camera3D();
		this.values = new SceneObjectVO();
	}

}

