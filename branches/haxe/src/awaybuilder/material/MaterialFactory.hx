package awaybuilder.material;

import away3d.materials.ColorMaterial;
import away3d.materials.ShadingColorMaterial;
import away3d.materials.WireColorMaterial;
import away3d.materials.WireframeMaterial;
import awaybuilder.vo.DynamicAttributeVO;
import awaybuilder.vo.SceneGeometryVO;
import flash.events.EventDispatcher;


class MaterialFactory  {
	
	private var propertyFactory:MaterialPropertyFactory;
	

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
		
		this.propertyFactory = new MaterialPropertyFactory();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(attribute:DynamicAttributeVO, vo:SceneGeometryVO):SceneGeometryVO {
		
		switch (attribute.value) {
			case MaterialType.COLOR_MATERIAL :
				vo.material = new ColorMaterial();
				break;
			case MaterialType.SHADING_COLOR_MATERIAL :
				vo.material = new ShadingColorMaterial();
				break;
			case MaterialType.WIRE_COLOR_MATERIAL :
				vo.material = new WireColorMaterial();
				break;
			case MaterialType.WIREFRAME_MATERIAL :
				vo.material = new WireframeMaterial();
				break;
			default :
				vo = this.buildDefault(vo);
			

		}
		vo = this.propertyFactory.build(vo);
		vo.materialType = attribute.value;
		return vo;
	}

	public function buildDefault(vo:SceneGeometryVO):SceneGeometryVO {
		
		var wireColorMaterial:WireColorMaterial = new WireColorMaterial();
		wireColorMaterial.color = 0x00FF00;
		vo.material = wireColorMaterial;
		vo.materialType = MaterialType.WIRE_COLOR_MATERIAL;
		return vo;
	}

}

