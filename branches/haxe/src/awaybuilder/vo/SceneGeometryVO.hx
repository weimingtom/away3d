package awaybuilder.vo;

import away3d.core.base.Object3D;
import away3d.materials.IMaterial;


class SceneGeometryVO  {
	public var assetClass(getAssetClass, setAssetClass) : String;
	public var assetFile(getAssetFile, setAssetFile) : String;
	public var assetFileBack(getAssetFileBack, setAssetFileBack) : String;
	
	public var id:String;
	public var name:String;
	public var values:SceneObjectVO;
	public var geometryExtras:Array<Dynamic>;
	public var materialExtras:Array<Dynamic>;
	public var material:IMaterial;
	public var materialBack:IMaterial;
	public var smooth:Bool;
	public var precision:Float;
	public var mesh:Object3D;
	public var enabled:Bool;
	public var mouseDownEnabled:Bool;
	public var mouseMoveEnabled:Bool;
	public var mouseOutEnabled:Bool;
	public var mouseOverEnabled:Bool;
	public var mouseUpEnabled:Bool;
	public var geometryType:String;
	public var materialType:String;
	public var materialData:Dynamic;
	public var targetCamera:String;
	private var _assetClass:String;
	private var _assetFile:String;
	private var _assetFileBack:String;
	

	public function new() {
		this.geometryExtras = [];
		this.materialExtras = [];
		this.precision = 0;
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
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Getters and Setters
	//
	////////////////////////////////////////////////////////////////////////////////
	public function setAssetClass(value:String):String {
		
		this._assetClass = value;
		this._assetFile = null;
		return value;
	}

	public function getAssetClass():String {
		
		return this._assetClass;
	}

	public function setAssetFile(value:String):String {
		
		this._assetFile = value;
		this._assetClass = null;
		return value;
	}

	public function getAssetFile():String {
		
		return this._assetFile;
	}

	public function setAssetFileBack(value:String):String {
		
		this._assetFileBack = value;
		this._assetClass = null;
		return value;
	}

	public function getAssetFileBack():String {
		
		return this._assetFileBack;
	}

}

