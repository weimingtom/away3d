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
		
		this.values = new SceneObjectVO();
		this.pivot = new ObjectContainer3D();
	}

}

