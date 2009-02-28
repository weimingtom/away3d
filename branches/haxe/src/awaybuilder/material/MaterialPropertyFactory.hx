package awaybuilder.material;

import awaybuilder.vo.SceneGeometryVO;
import awaybuilder.vo.DynamicAttributeVO;


class MaterialPropertyFactory  {
	
	

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
		
		var boolean:Bool;
		for (__i in 0...vo.materialExtras.length) {
			var attribute:DynamicAttributeVO = vo.materialExtras[__i];

			if (attribute != null) {
				switch (attribute.key) {
					case MaterialAttributes.ALPHA :
						Reflect.setField(vo.material, attribute.key, (attribute.value));
						break;
					case MaterialAttributes.AMBIENT :
						Reflect.setField(vo.material, attribute.key, Std.int(attribute.value));
						break;
					case MaterialAttributes.ASSET_CLASS :
						Reflect.setField(vo, attribute.key, attribute.value);
						break;
					case MaterialAttributes.ASSET_FILE :
						Reflect.setField(vo, attribute.key, attribute.value);
						break;
					case MaterialAttributes.ASSET_FILE_BACK :
						Reflect.setField(vo, attribute.key, attribute.value);
						break;
					case MaterialAttributes.COLOR :
						Reflect.setField(vo.material, attribute.key, Std.int(attribute.value));
						break;
					case MaterialAttributes.DIFFUSE :
						Reflect.setField(vo.material, attribute.key, Std.int(attribute.value));
						break;
					case MaterialAttributes.PRECISION :
						Reflect.setField(vo, attribute.key, (attribute.value));
						break;
					case MaterialAttributes.SMOOTH :
						attribute.value == "1" ? boolean = true : boolean = false;
						Reflect.setField(vo, attribute.key, boolean);
						break;
					case MaterialAttributes.SPECULAR :
						Reflect.setField(vo.material, attribute.key, Std.int(attribute.value));
						break;
					case MaterialAttributes.WIDTH :
						Reflect.setField(vo.material, attribute.key, (attribute.value));
						break;
					case MaterialAttributes.WIREALPHA :
						Reflect.setField(vo.material, attribute.key, (attribute.value));
						break;
					case MaterialAttributes.WIRECOLOR :
						Reflect.setField(vo.material, attribute.key, Std.int(attribute.value));
						break;
					

				}
			}
		}

		return vo;
	}

}

