package awaybuilder.collada;

import awaybuilder.abstracts.AbstractParser;
import awaybuilder.vo.DynamicAttributeVO;
import awaybuilder.vo.SceneCameraVO;
import awaybuilder.vo.SceneGeometryVO;
import awaybuilder.vo.SceneObjectVO;
import awaybuilder.vo.SceneSectionVO;
import flash.events.Event;


class ColladaParser extends AbstractParser  {
	
	public static inline var GROUP_IDENTIFIER:String = "NODE";
	public static inline var GROUP_CAMERA:Int = 0;
	public static inline var GROUP_GEOMETRY:Int = 1;
	public static inline var GROUP_SECTION:Int = 2;
	public static inline var PREFIX_CAMERA:String = "camera";
	public static inline var PREFIX_GEOMETRY:String = "geometry";
	public static inline var PREFIX_MATERIAL:String = "material";
	private var xml:Xml;
	private var mainSections:Array<Dynamic>;
	private var geometry:Array<Dynamic>;
	private var cameras:Array<Dynamic>;
	private var allSections:Array<Dynamic>;
	

	public function new() {
		this.mainSections = [];
		this.geometry = [];
		this.cameras = [];
		this.allSections = [];
		
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
		
		super();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	override public function parse(data:Dynamic):Void {
		
		var xml:Xml = cast(data, Xml);
		this.xml = xml;
		this.extractMainSections();
		this._sections = this.mainSections;
		this.dispatchEvent(new Event());
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Protected Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	private function extractMainSections():Void {
		
		var list:XMLList = cast(this.xml[ColladaNode.LIBRARY_VISUAL_SCENES][ColladaNode.VISUAL_SCENE].node, XMLList);
		for (__i in 0...list.length) {
			var node:Xml = list[__i];

			var children:XMLList = node.children();
			var vo:SceneSectionVO = new SceneSectionVO();
			vo.id = node.@id;
			vo.name = node.@name;
			vo.values = this.extractPivot(node);
			vo.cameras = this.extractGroup(ColladaParser.GROUP_CAMERA, vo, children);
			vo.geometry = this.extractGroup(ColladaParser.GROUP_GEOMETRY, vo, children);
			vo.sections = this.extractGroup(ColladaParser.GROUP_SECTION, vo, children);
			this.mainSections.push(vo);
			this.sections.push(vo);
		}

	}

	private function extractPivot(xml:Xml):SceneObjectVO {
		
		var positions:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_POSITION, xml[ColladaNode.TRANSLATE]);
		var rotations:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_ROTATION, xml[ColladaNode.ROTATE]);
		var scales:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_SCALE, xml[ColladaNode.SCALE]);
		var pivot:SceneObjectVO = new SceneObjectVO();
		this.applyPosition(pivot, positions);
		this.applyRotation(pivot, rotations);
		this.applyScale(pivot, scales);
		return pivot;
	}

	private function extractGroup(group:Int, section:SceneSectionVO, list:XMLList):Array<Dynamic> {
		
		var a:Array<Dynamic> = new Array<Dynamic>();
		var counter:Int = 0;
		for (__i in 0...list.length) {
			var node:Xml = list[__i];

			var type:String = node.@type;
			if (type == ColladaParser.GROUP_IDENTIFIER && counter == group) {
				switch (group) {
					case ColladaParser.GROUP_CAMERA :
						a = this.extractCameras(section, node.children());
						break;
					case ColladaParser.GROUP_GEOMETRY :
						a = this.extractGeometry(section, node.children());
						break;
					case ColladaParser.GROUP_SECTION :
						a = this.extractSection(node);
						break;
					

				}
			}
			if (type == ColladaParser.GROUP_IDENTIFIER) {
				counter++;
			}
		}

		return a;
	}

	/*section : SceneSectionVO ,*/
	private function extractSection(xml:Xml):Array<Dynamic> {
		
		var a:Array<Dynamic> = new Array<Dynamic>();
		for (__i in 0...xml[ColladaNode.NODE].length) {
			var node:Xml = xml[ColladaNode.NODE][__i];

			var vo:SceneSectionVO = new SceneSectionVO();
			var children:XMLList = node.children();
			vo.id = node.@id;
			vo.name = node.@name;
			vo.values = this.extractPivot(xml);
			//vo.pivot = section.pivot ;
			vo.cameras = this.extractGroup(ColladaParser.GROUP_CAMERA, vo, children);
			vo.geometry = this.extractGroup(ColladaParser.GROUP_GEOMETRY, vo, children);
			vo.sections = this.extractGroup(ColladaParser.GROUP_SECTION, vo, children);
			a.push(vo);
			this.allSections.push(vo);
		}

		return a;
	}

	private function extractCameras(section:SceneSectionVO, list:XMLList):Array<Dynamic> {
		
		var cameras:Array<Dynamic> = new Array<Dynamic>();
		for (__i in 0...list.length) {
			var node:Xml = list[__i];

			var type:String = node.@type;
			if (type == ColladaParser.GROUP_IDENTIFIER) {
				var vo:SceneCameraVO = new SceneCameraVO();
				var values:SceneObjectVO = new SceneObjectVO();
				var children:XMLList = node.children();
				var positions:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_POSITION, children);
				var rotations:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_ROTATION, children);
				var extras:XMLList = (cast(node[ColladaNode.EXTRA][ColladaNode.TECHNIQUE][ColladaNode.DYNAMIC_ATTRIBUTES], XMLList)).children();
				this.applyPosition(values, positions);
				this.applyRotation(values, rotations);
				vo.id = node.@id;
				vo.name = node.@name;
				vo.parentSection = section;
				vo.values = values;
				if (extras.toString() != "") {
					vo = this.extractCameraExtras(vo, extras);
				}
				cameras.push(vo);
				this.cameras.push(vo);
			}
		}

		return cameras;
	}

	private function extractCameraExtras(vo:SceneCameraVO, extras:XMLList):SceneCameraVO {
		
		for (__i in 0...extras.length) {
			var node:Xml = extras[__i];

			var attribute:DynamicAttributeVO = new DynamicAttributeVO();
			var name:String = (node.name()).toString();
			var pair:Array<Dynamic> = name.split("_");
			var prefix:String = pair[0];
			var key:String = pair[1];
			var value:String = node.toString();
			attribute.key = key;
			attribute.value = value;
			switch (prefix) {
				case ColladaParser.PREFIX_CAMERA :
					vo.extras.push(attribute);
					break;
				

			}
		}

		return vo;
	}

	private function extractGeometry(section:SceneSectionVO, list:XMLList):Array<Dynamic> {
		
		var geometry:Array<Dynamic> = new Array<Dynamic>();
		for (__i in 0...list.length) {
			var node:Xml = list[__i];

			var type:String = node.@type;
			if (type == ColladaParser.GROUP_IDENTIFIER) {
				var vo:SceneGeometryVO = new SceneGeometryVO();
				var values:SceneObjectVO = new SceneObjectVO();
				var children:XMLList = node.children();
				var positions:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_POSITION, children);
				var rotations:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_ROTATION, children);
				var scales:Array<Dynamic> = this.extractValues(ColladaNode.VALUE_TYPE_SCALE, children);
				var extras:XMLList = (cast(node[ColladaNode.EXTRA][ColladaNode.TECHNIQUE][ColladaNode.DYNAMIC_ATTRIBUTES], XMLList)).children();
				this.applyPosition(values, positions);
				this.applyRotation(values, rotations);
				this.applyScale(values, scales);
				vo.id = node.@id;
				vo.name = node.@name;
				vo.values = values;
				vo.enabled = section.enabled;
				if (extras.toString() != "") {
					vo = this.extractGeometryExtras(vo, extras);
				}
				geometry.push(vo);
				this.geometry.push(vo);
			}
		}

		return geometry;
	}

	private function extractGeometryExtras(vo:SceneGeometryVO, extras:XMLList):SceneGeometryVO {
		
		for (__i in 0...extras.length) {
			var node:Xml = extras[__i];

			var attribute:DynamicAttributeVO = new DynamicAttributeVO();
			var name:String = (node.name()).toString();
			var pair:Array<Dynamic> = name.split("_");
			var prefix:String = pair[0];
			var key:String = pair[1];
			var value:String = node.toString();
			attribute.key = key;
			attribute.value = value;
			switch (prefix) {
				case ColladaParser.PREFIX_GEOMETRY :
					vo.geometryExtras.push(attribute);
					break;
				case ColladaParser.PREFIX_MATERIAL :
					vo.materialExtras.push(attribute);
					break;
				

			}
		}

		return vo;
	}

	private function extractValues(type:String, list:XMLList):Array<Dynamic> {
		
		var sList:String = list.toString();
		var positions:Array<Dynamic> = new Array<Dynamic>();
		var rotations:Array<Dynamic> = new Array<Dynamic>();
		var scales:Array<Dynamic> = new Array<Dynamic>();
		var values:Array<Dynamic>;
		if (sList != "") {
			for (__i in 0...list.length) {
				var node:Xml = list[__i];

				var sNode:String = node.toString();
				var sid:String = node.@sid;
				switch (sid) {
					case ColladaNode.TRANSLATE :
						positions = sNode.split(" ");
						break;
					case ColladaNode.ROTATE_X :
						rotations[0] = this.extractLastEntry(sNode);
						break;
					case ColladaNode.ROTATE_Y :
						rotations[1] = this.extractLastEntry(sNode);
						break;
					case ColladaNode.ROTATE_Z :
						rotations[2] = this.extractLastEntry(sNode);
						break;
					case ColladaNode.SCALE :
						scales = sNode.split(" ");
						break;
					

				}
			}

		}
		switch (type) {
			case ColladaNode.VALUE_TYPE_POSITION :
				values = positions;
				break;
			case ColladaNode.VALUE_TYPE_ROTATION :
				values = rotations;
				break;
			case ColladaNode.VALUE_TYPE_SCALE :
				values = scales;
				break;
			

		}
		return values;
	}

	private function extractLastEntry(sNode:String):Float {
		
		var values:Array<Dynamic> = sNode.split(" ");
		var last:Float = values[values.length - 1];
		return last;
	}

	private function applyPosition(target:SceneObjectVO, values:Array<Dynamic>):Void {
		
		target.x = values[0];
		target.y = values[1];
		target.z = values[2];
	}

	private function applyRotation(target:SceneObjectVO, values:Array<Dynamic>):Void {
		
		target.rotationX = values[0];
		target.rotationY = values[1];
		target.rotationZ = values[2];
	}

	private function applyScale(target:SceneObjectVO, values:Array<Dynamic>):Void {
		
		target.scaleX = values[0];
		target.scaleY = values[1];
		target.scaleZ = values[2];
	}

}

