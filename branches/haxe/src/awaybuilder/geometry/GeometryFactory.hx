package awaybuilder.geometry;

import away3d.core.base.Mesh;
import away3d.materials.ITriangleMaterial;
import away3d.primitives.Cone;
import away3d.primitives.Cube;
import away3d.primitives.Cylinder;
import away3d.primitives.Plane;
import away3d.primitives.Sphere;
import away3d.primitives.Torus;
import away3d.primitives.data.CubeMaterialsData;
import awaybuilder.vo.DynamicAttributeVO;
import awaybuilder.vo.SceneGeometryVO;
import flash.events.EventDispatcher;


class GeometryFactory  {
	public var precision(getPrecision, setPrecision) : Int;
	
	public var coordinateSystem:String;
	private var propertyFactory:GeometryPropertyFactory;
	private var _precision:Int;
	

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
		
		this.propertyFactory = new GeometryPropertyFactory();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function build(attribute:DynamicAttributeVO, vo:SceneGeometryVO):SceneGeometryVO {
		
		var s:Int = this.precision;
		switch (attribute.value) {
			case GeometryType.COLLADA :
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.CONE :
				var cone:Cone = new Cone();
				cone.height = s;
				cone.radius = s;
				cone.material = cast(vo.material, ITriangleMaterial);
				vo.mesh = cone;
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.CUBE :
				var cube:Cube = new Cube();
				var materialsData:CubeMaterialsData = new CubeMaterialsData();
				materialsData.back = cast(vo.material, ITriangleMaterial);
				materialsData.bottom = cast(vo.material, ITriangleMaterial);
				materialsData.front = cast(vo.material, ITriangleMaterial);
				materialsData.left = cast(vo.material, ITriangleMaterial);
				materialsData.right = cast(vo.material, ITriangleMaterial);
				materialsData.top = cast(vo.material, ITriangleMaterial);
				cube.depth = s;
				cube.height = s;
				cube.width = s;
				cube.cubeMaterials = materialsData;
				vo.mesh = cube;
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.CYLINDER :
				var cylinder:Cylinder = new Cylinder();
				cylinder.height = s;
				cylinder.radius = s;
				cylinder.material = cast(vo.material, ITriangleMaterial);
				vo.mesh = cylinder;
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.PLANE :
				var plane:Plane = new Plane();
				plane.width = s;
				plane.height = s;
				plane.material = cast(vo.material, ITriangleMaterial);
				if ((vo.assetFileBack != null)) {
					plane.back = cast(vo.materialBack, ITriangleMaterial);
				}
				vo.mesh = plane;
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.SPHERE :
				var sphere:Sphere = new Sphere();
				sphere.radius = s;
				sphere.material = cast(vo.material, ITriangleMaterial);
				vo.mesh = sphere;
				vo = this.propertyFactory.build(vo);
				break;
			case GeometryType.TORUS :
				var torus:Torus = new Torus();
				torus.radius = s;
				torus.tube = s;
				torus.material = cast(vo.material, ITriangleMaterial);
				vo.mesh = torus;
				vo = this.propertyFactory.build(vo);
				break;
			default :
				vo = this.buildDefault(vo);
			

		}
		vo.geometryType = attribute.value;
		return vo;
	}

	public function buildDefault(vo:SceneGeometryVO):SceneGeometryVO {
		
		var s:Int = this.precision;
		var plane:Plane = new Plane();
		plane.width = s;
		plane.height = s;
		plane.bothsides = true;
		plane.material = cast(vo.material, ITriangleMaterial);
		vo.mesh = plane;
		return vo;
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Getters and Setters
	//
	////////////////////////////////////////////////////////////////////////////////
	public function setPrecision(value:Int):Int {
		
		this._precision = value;
		this.propertyFactory.precision = value;
		return value;
	}

	public function getPrecision():Int {
		
		return this._precision;
	}

}

