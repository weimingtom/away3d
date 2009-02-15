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
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		this.camera = new Camera3D();
		this.values = new SceneObjectVO();
	}

}

