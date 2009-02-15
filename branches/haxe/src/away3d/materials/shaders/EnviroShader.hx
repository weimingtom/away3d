package away3d.materials.shaders;

import flash.filters.ColorMatrixFilter;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.math.Number3D;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.math.Matrix3D;
import flash.display.Shape;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Shader class for environment lighting.
 */
class EnviroShader extends AbstractShader  {
	public var height(getHeight, null) : Float;
	public var width(getWidth, null) : Float;
	public var bitmap(getBitmap, null) : BitmapData;
	public var reflectiveness(getReflectiveness, setReflectiveness) : Float;
	
	/** @private */
	public var _bitmap:BitmapData;
	/** @private */
	public var _reflectiveness:Float;
	/** @private */
	public var _colorTransform:ColorTransform;
	private var _width:Int;
	private var _height:Int;
	private var _halfWidth:Int;
	private var _halfHeight:Int;
	private var _enviroTransform:Matrix3D;
	private var _specularTransform:Matrix3D;
	private var _nFace:Number3D;
	private var _nFaceTransZ:Float;
	private var specVal1:Float;
	private var specVal2:Float;
	private var specVal3:Float;
	private var specValFace:Float;
	private var coeff1:Float;
	private var coeff2:Float;
	private var coeff3:Float;
	private var _sxd:Float;
	private var _sxx:Float;
	private var _sxy:Float;
	private var _sxz:Float;
	private var _syd:Float;
	private var _syx:Float;
	private var _syy:Float;
	private var _syz:Float;
	/**
	 * Setting for possible mapping methods.
	 */
	public var mode:String;
	

	/**
	 * Calculates the mapping matrix required to draw the triangle texture to screen.
	 * 
	 * @param	source	The source object of the material.
	 * @param	face	The face object of the material.
	 * @return			The required matrix object.
	 */
	private function getMapping(source:Mesh, face:Face):Matrix {
		
		_n0 = source.geometry.getVertexNormal(face.v0);
		_n1 = source.geometry.getVertexNormal(face.v1);
		_n2 = source.geometry.getVertexNormal(face.v2);
		eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;
		eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;
		eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;
		eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;
		eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;
		eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;
		//catch mapping where points are the same (flat surface)
		if (eTri1x == eTri0x && eTri1y == eTri0y) {
			eTri1x += 0.1;
			eTri1y += 0.1;
		}
		if (eTri2x == eTri1x && eTri2y == eTri1y) {
			eTri2x += 0.1;
			eTri2y += 0.1;
		}
		if (eTri0x == eTri2x && eTri0y == eTri2y) {
			eTri0x += 0.1;
			eTri0y += 0.1;
		}
		//calulate mapping
		_mapping.a = _halfWidth * (eTri1x - eTri0x);
		_mapping.b = _halfHeight * (eTri1y - eTri0y);
		_mapping.c = _halfWidth * (eTri2x - eTri0x);
		_mapping.d = _halfHeight * (eTri2y - eTri0y);
		_mapping.tx = _halfWidth * eTri0x + _halfWidth;
		_mapping.ty = _halfHeight * eTri0y + _halfHeight;
		_mapping.invert();
		return _mapping;
	}

	/**
	 * @inheritDoc
	 */
	private function clearFaces(source:Object3D, view:View3D):Void {
		
		notifyMaterialUpdate();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[cast __key];

			if (source == _faceMaterialVO.source && view == _faceMaterialVO.view) {
				if (!_faceMaterialVO.cleared) {
					_faceMaterialVO.clear();
				}
				_faceMaterialVO.invalidated = true;
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	private override function renderShader(tri:DrawTriangle):Void {
		//store a clone
		
		if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
			_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
			_faceMaterialVO.bitmap.lock();
		}
		_faceMaterialVO.cleared = false;
		_faceMaterialVO.updated = true;
		_faceVO = tri.faceVO;
		_mapping = getMapping(cast(tri.source, Mesh), _face);
		_mapping.concat(_faceMaterialVO.invtexturemapping);
		//draw into faceBitmap
		_faceMaterialVO.bitmap.draw(_bitmap, _mapping, null, blendMode, _faceMaterialVO.bitmap.rect, smooth);
	}

	/**
	 * Returns the width of the bitmapData being used as the shader environment map.
	 */
	public function getHeight():Float {
		
		return _bitmap.height;
	}

	/**
	 * Returns the height of the bitmapData being used as the shader environment map.
	 */
	public function getWidth():Float {
		
		return _bitmap.width;
	}

	/**
	 * Returns the bitmapData object being used as the shader environment map.
	 */
	public function getBitmap():BitmapData {
		
		return _bitmap;
	}

	/**
	 * Coefficient for the reflectiveness of the environment map.
	 */
	public function getReflectiveness():Float {
		
		return _reflectiveness;
	}

	public function setReflectiveness(val:Float):Float {
		
		_reflectiveness = val;
		_colorTransform = new ColorTransform();
		return val;
	}

	/**
	 * Creates a new <code>EnviroShader</code> object.
	 * 
	 * @param	bitmap			The bitmapData object to be used as the material's environment map.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		
		
		super(init);
		// ensure  that alpha is discarded
		_bitmap = new BitmapData();
		_bitmap.draw(bitmap);
		mode = ini.getString("mode", "linear");
		reflectiveness = ini.getNumber("reflectiveness", 0.5, {min:0, max:1});
		_width = _bitmap.width;
		_height = _bitmap.height;
		_halfWidth = Std.int(_width / 2);
		_halfHeight = Std.int(_height / 2);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		clearShapeDictionary();
		_enviroTransform = view.cameraVarsStore.viewTransformDictionary[cast source];
		_sxx = _enviroTransform.sxx;
		_sxy = _enviroTransform.sxy;
		_sxz = _enviroTransform.sxz;
		_sxd = Math.sqrt(_sxx * _sxx + _sxy * _sxy + _sxz * _sxz);
		_sxx /= _sxd;
		_sxy /= _sxd;
		_sxz /= _sxd;
		_syx = _enviroTransform.syx;
		_syy = _enviroTransform.syy;
		_syz = _enviroTransform.syz;
		_syd = Math.sqrt(_syx * _syx + _syy * _syy + _syz * _syz);
		_syx /= _syd;
		_syy /= _syd;
		_syz /= _syd;
		if (view.scene.updatedObjects[cast source] || view.updated) {
			clearFaces(source, view);
		}
	}

	/**
	 * @inheritDoc
	 */
	public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		super.renderLayer(tri, layer, level);
		_shape = getShape(layer);
		_shape.blendMode = blendMode;
		_shape.transform.colorTransform = _colorTransform;
		_source.session.renderTriangleBitmap(_bitmap, getMapping(_source, _face), tri.v0, tri.v1, tri.v2, smooth, false, _shape.graphics);
		if (debug) {
			_source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}

}

