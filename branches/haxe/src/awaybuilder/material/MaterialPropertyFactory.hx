package awaybuilder.material;

import awaybuilder.vo.SceneGeometryVO;
import awaybuilder.vo.DynamicAttributeVO;


class MaterialPropertyFactory  {
	
	

	public function new() {
		
		
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

