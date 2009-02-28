package awaybuilder.geometry;

import awaybuilder.vo.SceneGeometryVO;
import awaybuilder.vo.DynamicAttributeVO;
import flash.events.EventDispatcher;


class GeometryPropertyFactory  {
	
	public var precision:Int;
	

	public function new() {
		
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
		
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(vo:SceneGeometryVO):SceneGeometryVO {
		
		for (__i in 0...vo.geometryExtras.length) {
			var attribute:DynamicAttributeVO = vo.geometryExtras[__i];

			if (attribute != null) {
				var boolean:Bool;
				switch (attribute.key) {
					case GeometryAttributes.ASSET_CLASS :
						vo.assetClass = attribute.value;
						break;
					case GeometryAttributes.ASSET_FILE :
						vo.assetFile = attribute.value;
						break;
					case GeometryAttributes.ASSET_FILE_BACK :
						vo.assetFileBack = attribute.value;
						break;
					case GeometryAttributes.BOTHSIDES :
						attribute.value == "1" ? boolean = true : boolean = false;
						Reflect.setField(vo.mesh, attribute.key, boolean);
						break;
					case GeometryAttributes.DEPTH :
						Reflect.setField(vo.mesh, attribute.key, this.precision * (attribute.value));
						break;
					case GeometryAttributes.ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.enabled = boolean;
						break;
					case GeometryAttributes.HEIGHT :
						Reflect.setField(vo.mesh, attribute.key, this.precision * (attribute.value));
						break;
					case GeometryAttributes.MOUSE_DOWN_ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.mouseDownEnabled = boolean;
						break;
					case GeometryAttributes.MOUSE_MOVE_ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.mouseMoveEnabled = boolean;
						break;
					case GeometryAttributes.MOUSE_OUT_ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.mouseOutEnabled = boolean;
						break;
					case GeometryAttributes.MOUSE_OVER_ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.mouseOverEnabled = boolean;
						break;
					case GeometryAttributes.MOUSE_UP_ENABLED :
						attribute.value == "1" ? boolean = true : boolean = false;
						vo.mouseUpEnabled = boolean;
						break;
					case GeometryAttributes.OWN_CANVAS :
						attribute.value == "1" ? boolean = true : boolean = false;
						Reflect.setField(vo.mesh, attribute.key, boolean);
						break;
					case GeometryAttributes.RADIUS :
						Reflect.setField(vo.mesh, attribute.key, this.precision * (attribute.value));
						break;
					case GeometryAttributes.SEGMENTS_W :
						Reflect.setField(vo.mesh, attribute.key, Std.int(attribute.value));
						break;
					case GeometryAttributes.SEGMENTS_H :
						Reflect.setField(vo.mesh, attribute.key, Std.int(attribute.value));
						break;
					case GeometryAttributes.SEGMENTS_R :
						Reflect.setField(vo.mesh, attribute.key, Std.int(attribute.value));
						break;
					case GeometryAttributes.SEGMENTS_T :
						Reflect.setField(vo.mesh, attribute.key, Std.int(attribute.value));
						break;
					case GeometryAttributes.TARGET_CAMERA :
						vo.targetCamera = attribute.value;
						break;
					case GeometryAttributes.TUBE :
						Reflect.setField(vo.mesh, attribute.key, this.precision * (attribute.value));
						break;
					case GeometryAttributes.USE_HAND_CURSOR :
						attribute.value == "1" ? boolean = true : boolean = false;
						Reflect.setField(vo.mesh, attribute.key, boolean);
						break;
					case GeometryAttributes.WIDTH :
						Reflect.setField(vo.mesh, attribute.key, this.precision * (attribute.value));
						break;
					case GeometryAttributes.Y_UP :
						attribute.value == "1" ? boolean = true : boolean = false;
						Reflect.setField(vo.mesh, attribute.key, boolean);
						break;
					

				}
			}
		}

		return vo;
	}

}

