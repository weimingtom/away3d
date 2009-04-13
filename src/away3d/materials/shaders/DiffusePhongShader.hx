package away3d.materials.shaders;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import away3d.haxeutils.HashMap;
import flash.geom.Rectangle;
import away3d.core.base.Face;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import flash.geom.Matrix;
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
 * Diffuse shader class for directional lighting.
 * 
 * @see away3d.lights.DirectionalLight3D
 */
class DiffusePhongShader extends AbstractShader  {
	
	private var eTriVal:Float;
	private var _diffuseTransform:Matrix3D;
	private var _szx:Float;
	private var _szy:Float;
	private var _szz:Float;
	private var _normal0z:Float;
	private var _normal1z:Float;
	private var _normal2z:Float;
	private var eTriConst:Float;
	

	/**
	 * @inheritDoc
	 */
	private function clearFaces(source:Object3D, view:View3D):Void {
		
		notifyMaterialUpdate();
		for (_faceMaterialVO in _faceDictionary.iterator()) {
			if (_faceMaterialVO != null) {
				if (source == _faceMaterialVO.source) {
					if (!_faceMaterialVO.cleared) {
						_faceMaterialVO.clear();
					}
					_faceMaterialVO.invalidated = true;
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
				_diffuseTransform = directional.diffuseTransform.get(_source);
				_szx = _diffuseTransform.szx;
				_szy = _diffuseTransform.szy;
				_szz = _diffuseTransform.szz;
				_normal0z = _n0.x * _szx + _n0.y * _szy + _n0.z * _szz;
				_normal1z = _n1.x * _szx + _n1.y * _szy + _n1.z * _szz;
				_normal2z = _n2.x * _szx + _n2.y * _szy + _n2.z * _szz;
				//check to see if the uv triangle lies inside the bitmap area
				if (_normal0z > 0 || _normal1z > 0 || _normal2z > 0) {
					eTri0x = eTriConst * Math.acos(_normal0z);
					//store a clone
					if (_faceMaterialVO.cleared && !_parentFaceMaterialVO.updated) {
						_faceMaterialVO.bitmap = _parentFaceMaterialVO.bitmap.clone();
						_faceMaterialVO.bitmap.lock();
					}
					_faceMaterialVO.cleared = false;
					_faceMaterialVO.updated = true;
					//calulate mapping
					_mapping.a = eTriConst * Math.acos(_normal1z) - eTri0x;
					_mapping.b = 127;
					_mapping.c = eTriConst * Math.acos(_normal2z) - eTri0x;
					_mapping.d = 255;
					_mapping.tx = eTri0x;
					_mapping.ty = 0;
					_mapping.invert();
					_mapping.concat(_faceMaterialVO.invtexturemapping);
					//draw into faceBitmap
					_graphics = _s.graphics;
					_graphics.clear();
					_graphics.beginBitmapFill(directional.diffuseBitmap, _mapping, false, smooth);
					_graphics.drawRect(0, 0, _bitmapRect.width, _bitmapRect.height);
					_graphics.endFill();
					_faceMaterialVO.bitmap.draw(_s, null, null, blendMode);
					//_faceMaterialVO.bitmap.draw(directional.diffuseBitmap, _mapping, null, blendMode, _faceMaterialVO.bitmap.rect, smooth);
					
				}
			}
		}

	}

	/**
	 * Creates a new <code>DiffusePhongShader</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this.eTriVal = 512 / Math.PI;
		this.eTriConst = 512 / Math.PI;
		
		
		super(init);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		for (__i in 0...source.lightarray.directionals.length) {
			directional = source.lightarray.directionals[__i];

			if (directional != null) {
				if (!directional.diffuseTransform.contains(source) || untyped view.scene.updatedObjects.indexOf(source) != -1) {
					directional.setDiffuseTransform(source);
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
				if (_lights.numLights > 1) {
					_shape = getLightingShape(layer, directional);
					_shape.blendMode = blendMode;
					_graphics = _shape.graphics;
				} else {
					_graphics = layer.graphics;
				}
				_diffuseTransform = directional.diffuseTransform.get(_source);
				_n0 = _source.geometry.getVertexNormal(_face.v0);
				_n1 = _source.geometry.getVertexNormal(_face.v1);
				_n2 = _source.geometry.getVertexNormal(_face.v2);
				_szx = _diffuseTransform.szx;
				_szy = _diffuseTransform.szy;
				_szz = _diffuseTransform.szz;
				_normal0z = _n0.x * _szx + _n0.y * _szy + _n0.z * _szz;
				_normal1z = _n1.x * _szx + _n1.y * _szy + _n1.z * _szz;
				_normal2z = _n2.x * _szx + _n2.y * _szy + _n2.z * _szz;
				eTri0x = eTriConst * Math.acos(_normal0z);
				_mapping.a = eTriConst * Math.acos(_normal1z) - eTri0x;
				_mapping.b = 127;
				_mapping.c = eTriConst * Math.acos(_normal2z) - eTri0x;
				_mapping.d = 255;
				_mapping.tx = eTri0x;
				_mapping.ty = 0;
				_mapping.invert();
				_source.session.renderTriangleBitmap(directional.ambientDiffuseBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, false, _graphics);
			}
		}

		if (debug) {
			_source.session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
	}

}

