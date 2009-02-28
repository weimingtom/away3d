package away3d.materials.shaders;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import flash.geom.Rectangle;
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
import flash.display.Graphics;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Specular shader class for directional lighting.
 * 
 * @see away3d.lights.DirectionalLight3D
 */
class SpecularPhongShader extends AbstractShader  {
	public var shininess(getShininess, setShininess) : Float;
	public var specular(getSpecular, setSpecular) : Float;
	
	private var _shininess:Float;
	private var _specular:Float;
	private var _specMin:Float;
	private var _specColor:ColorTransform;
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
	private var _sxx:Float;
	private var _sxy:Float;
	private var _sxz:Float;
	private var _syx:Float;
	private var _syy:Float;
	private var _syz:Float;
	private var _szx:Float;
	private var _szy:Float;
	private var _szz:Float;
	

	/**
	 * @inheritDoc
	 */
	private function clearFaces(source:Object3D, view:View3D):Void {
		
		notifyMaterialUpdate();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				if (source == _faceMaterialVO.source && view == _faceMaterialVO.view) {
					if (!_faceMaterialVO.cleared) {
						_faceMaterialVO.clear();
					}
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	private override function renderShader(tri:DrawTriangle):Void {
		
		_faceVO = tri.faceVO;
		_n0 = _source.geometry.getVertexNormal(_face.v0);
		_n1 = _source.geometry.getVertexNormal(_face.v1);
		_n2 = _source.geometry.getVertexNormal(_face.v2);
		for (__i in 0..._source.lightarray.directionals.length) {
			directional = _source.lightarray.directionals[__i];

			if (directional != null) {
				_specularTransform = directional.specularTransform[untyped _source][untyped _view];
				_nFace = _face.normal;
				_szx = _specularTransform.szx;
				_szy = _specularTransform.szy;
				_szz = _specularTransform.szz;
				specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess / 20);
				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess / 20);
				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess / 20);
				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess / 20);
				if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {
					if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
						_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
						_faceMaterialVO.bitmap.lock();
					}
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					_sxx = _specularTransform.sxx;
					_sxy = _specularTransform.sxy;
					_sxz = _specularTransform.sxz;
					_syx = _specularTransform.syx;
					_syy = _specularTransform.syy;
					_syz = _specularTransform.syz;
					eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;
					eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;
					eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;
					eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;
					eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;
					eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;
					coeff1 = 255 * Math.acos(specVal1) / Math.sqrt(eTri0x * eTri0x + eTri0y * eTri0y);
					coeff2 = 255 * Math.acos(specVal2) / Math.sqrt(eTri1x * eTri1x + eTri1y * eTri1y);
					coeff3 = 255 * Math.acos(specVal3) / Math.sqrt(eTri2x * eTri2x + eTri2y * eTri2y);
					eTri0x *= coeff1;
					eTri0y *= coeff1;
					eTri1x *= coeff2;
					eTri1y *= coeff2;
					eTri2x *= coeff3;
					eTri2y *= coeff3;
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
					_mapping.a = (eTri1x - eTri0x);
					_mapping.b = (eTri1y - eTri0y);
					_mapping.c = (eTri2x - eTri0x);
					_mapping.d = (eTri2y - eTri0y);
					_mapping.tx = eTri0x + 255;
					_mapping.ty = eTri0y + 255;
					_mapping.invert();
					_mapping.concat(_faceMaterialVO.invtexturemapping);
					//draw into faceBitmap
					_graphics = _s.graphics;
					_graphics.clear();
					_graphics.beginBitmapFill(directional.specularBitmap, _mapping, false, smooth);
					_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);
					_graphics.endFill();
					_faceMaterialVO.bitmap.draw(_s, null, _specColor, blendMode);
					//_faceMaterialVO.bitmap.draw(directional.specularBitmap, _mapping, _specColor, blendMode, _faceMaterialVO.bitmap.rect, smooth);
					
				}
			}
		}

	}

	/**
	 * The exponential dropoff value used for specular highlights.
	 */
	public function getShininess():Float {
		
		return _shininess;
	}

	public function setShininess(val:Float):Float {
		
		_shininess = val;
		_specMin = Math.pow(0.8, _shininess / 20);
		return val;
	}

	/**
	 * Coefficient for specular light level.
	 */
	public function getSpecular():Float {
		
		return _specular;
	}

	public function setSpecular(val:Float):Float {
		
		_specular = val;
		_specColor = new ColorTransform(_specular, _specular, _specular, 1, 0, 0, 0, 0);
		return val;
	}

	/**
	 * Creates a new <code>SpecularPhongShader</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		
		
		super(init);
		shininess = ini.getNumber("shininess", 20);
		specular = ini.getNumber("specular", 1);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		for (__i in 0...source.lightarray.directionals.length) {
			directional = source.lightarray.directionals[__i];

			if (directional != null) {
				if (!directional.specularTransform[untyped source]) {
					directional.specularTransform[untyped source] = new Dictionary(true);
				}
				if (!directional.specularTransform[untyped source][untyped view] || view.scene.updatedObjects[untyped source] || view.updated) {
					directional.setSpecularTransform(source, view);
					clearFaces(source, view);
					clearLightingShapeDictionary();
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		super.renderLayer(tri, layer, level);
		for (__i in 0..._lights.directionals.length) {
			directional = _lights.directionals[__i];

			if (directional != null) {
				_specularTransform = directional.specularTransform[untyped _source][untyped _view];
				_n0 = _source.geometry.getVertexNormal(_face.v0);
				_n1 = _source.geometry.getVertexNormal(_face.v1);
				_n2 = _source.geometry.getVertexNormal(_face.v2);
				_nFace = _face.normal;
				_szx = _specularTransform.szx;
				_szy = _specularTransform.szy;
				_szz = _specularTransform.szz;
				specVal1 = Math.pow(_n0.x * _szx + _n0.y * _szy + _n0.z * _szz, _shininess / 20);
				specVal2 = Math.pow(_n1.x * _szx + _n1.y * _szy + _n1.z * _szz, _shininess / 20);
				specVal3 = Math.pow(_n2.x * _szx + _n2.y * _szy + _n2.z * _szz, _shininess / 20);
				specValFace = Math.pow(_nFaceTransZ = _nFace.x * _szx + _nFace.y * _szy + _nFace.z * _szz, _shininess / 20);
				if (_nFaceTransZ > 0 && (specValFace > _specMin || specVal1 > _specMin || specVal2 > _specMin || specVal3 > _specMin || _nFace.dot(_n0) < 0.8 || _nFace.dot(_n1) < 0.8 || _nFace.dot(_n2) < 0.8)) {
					_shape = getLightingShape(layer, directional);
					_shape.blendMode = blendMode;
					_shape.transform.colorTransform = _specColor;
					_graphics = _shape.graphics;
					_sxx = _specularTransform.sxx;
					_sxy = _specularTransform.sxy;
					_sxz = _specularTransform.sxz;
					_syx = _specularTransform.syx;
					_syy = _specularTransform.syy;
					_syz = _specularTransform.syz;
					eTri0x = _n0.x * _sxx + _n0.y * _sxy + _n0.z * _sxz;
					eTri0y = _n0.x * _syx + _n0.y * _syy + _n0.z * _syz;
					eTri1x = _n1.x * _sxx + _n1.y * _sxy + _n1.z * _sxz;
					eTri1y = _n1.x * _syx + _n1.y * _syy + _n1.z * _syz;
					eTri2x = _n2.x * _sxx + _n2.y * _sxy + _n2.z * _sxz;
					eTri2y = _n2.x * _syx + _n2.y * _syy + _n2.z * _syz;
					coeff1 = 255 * Math.acos(specVal1) / Math.sqrt(eTri0x * eTri0x + eTri0y * eTri0y);
					coeff2 = 255 * Math.acos(specVal2) / Math.sqrt(eTri1x * eTri1x + eTri1y * eTri1y);
					coeff3 = 255 * Math.acos(specVal3) / Math.sqrt(eTri2x * eTri2x + eTri2y * eTri2y);
					eTri0x *= coeff1;
					eTri0y *= coeff1;
					eTri1x *= coeff2;
					eTri1y *= coeff2;
					eTri2x *= coeff3;
					eTri2y *= coeff3;
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
					_mapping.a = (eTri1x - eTri0x);
					_mapping.b = (eTri1y - eTri0y);
					_mapping.c = (eTri2x - eTri0x);
					_mapping.d = (eTri2y - eTri0y);
					_mapping.tx = eTri0x + 255;
					_mapping.ty = eTri0y + 255;
					_mapping.invert();
					_source.session.renderTriangleBitmap(directional.specularBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
				} else {
					_source.session.renderTriangleColor(0x000000, 1, tri.v0, tri.v1, tri.v2, _graphics);
				}
			}
		}

		if (debug) {
			_source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}

}

