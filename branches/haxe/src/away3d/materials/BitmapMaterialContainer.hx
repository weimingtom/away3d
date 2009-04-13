package away3d.materials;

import away3d.haxeutils.Error;
import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import away3d.haxeutils.HashMap;
import away3d.events.MaterialEvent;
import flash.geom.Rectangle;
import flash.geom.Point;
import away3d.core.base.Object3D;
import flash.geom.Matrix;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;


// use namespace arcane;

/**
 * Container for caching multiple bitmapmaterial objects.
 * Renders each material by caching a bitmapData surface object for each face.
 * For continually updating materials, use <code>CompositeMaterial</code>.
 * 
 * @see away3d.materials.CompositeMaterial
 */
class BitmapMaterialContainer extends BitmapMaterial, implements ITriangleMaterial, implements ILayerMaterial {
	
	private var _width:Float;
	private var _height:Float;
	private var _fMaterialVO:FaceMaterialVO;
	private var _containerDictionary:HashMap<DrawTriangle, FaceMaterialVO>;
	private var _cacheDictionary:HashMap<FaceVO, BitmapData>;
	private var _containerVO:FaceMaterialVO;
	private var _faceWidth:Int;
	private var _faceHeight:Int;
	private var _forceRender:Bool;
	private var _faceVO:FaceVO;
	private var _material:ILayerMaterial;
	/**
	 * An array of bitmapmaterial objects to be overlayed sequentially.
	 */
	private var materials:Array<ILayerMaterial>;
	/**
	 * Defines whether the caching bitmapData objects are transparent
	 */
	public var transparent:Bool;
	

	private function onMaterialUpdate(event:MaterialEvent):Void {
		
		_materialDirty = true;
	}

	/**
	 * @inheritDoc
	 */
	private override function updateRenderBitmap():Void {
		
		_bitmapDirty = false;
		invalidateFaces();
		_materialDirty = true;
	}

	/**
	 * @inheritDoc
	 */
	private override function getMapping(tri:DrawTriangle):Matrix {
		
		_faceVO = tri.faceVO;
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO, tri.source, tri.view);
		if (tri.generated || _faceMaterialVO.invalidated || _faceMaterialVO.updated) {
			_faceMaterialVO.updated = true;
			_faceMaterialVO.cleared = false;
			//check to see if face drawtriangle needs updating
			if (_faceMaterialVO.invalidated) {
				_faceMaterialVO.invalidated = false;
				//update face bitmapRect
				_faceVO.bitmapRect = new Rectangle(Std.int(_width * _faceVO.minU), Std.int(_height * (1 - _faceVO.maxV)), Std.int(_width * (_faceVO.maxU - _faceVO.minU) + 2), Std.int(_height * (_faceVO.maxV - _faceVO.minV) + 2));
				_faceWidth = Std.int(_faceVO.bitmapRect.width);
				_faceHeight = Std.int(_faceVO.bitmapRect.height);
				//update texturemapping
				_faceMaterialVO.invtexturemapping = tri.transformUV(this).clone();
				_faceMaterialVO.texturemapping = _faceMaterialVO.invtexturemapping.clone();
				_faceMaterialVO.texturemapping.invert();
				//resize bitmapData for container
				_faceMaterialVO.resize(_faceWidth, _faceHeight, transparent);
			}
			_fMaterialVO = _faceMaterialVO;
			//call renderFace on each material
			for (__i in 0...materials.length) {
				_material = materials[__i];

				if (_material != null) {
					_fMaterialVO = _material.renderBitmapLayer(tri, _bitmapRect, _fMaterialVO);
				}
			}

			_renderBitmap = _cacheDictionary.put(_faceVO, _fMaterialVO.bitmap);
			_fMaterialVO.updated = false;
			return _faceMaterialVO.texturemapping;
		}
		_renderBitmap = _cacheDictionary.get(_faceVO);
		//check to see if tri texturemapping need updating
		if (_faceMaterialVO.invalidated) {
			_faceMaterialVO.invalidated = false;
			//update texturemapping
			_faceMaterialVO.invtexturemapping = tri.transformUV(this).clone();
			_faceMaterialVO.texturemapping = _faceMaterialVO.invtexturemapping.clone();
			_faceMaterialVO.texturemapping.invert();
		}
		return _faceMaterialVO.texturemapping;
	}

	/**
	 * Creates a new <code>BitmapMaterialContainer</code> object.
	 * 
	 * @param	width				The containing width of the texture, applied to all child materials.
	 * @param	height				The containing height of the texture, applied to all child materials.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(width:Int, height:Int, ?init:Dynamic=null) {
		this._containerDictionary = new HashMap<DrawTriangle, FaceMaterialVO>();
		this._cacheDictionary = new HashMap<FaceVO, BitmapData>();
		
		
		super(new BitmapData(width, height, true, 0x00FFFFFF), init);
		materials = untyped ini.getArray("materials");
		_width = width;
		_height = height;
		_bitmapRect = new Rectangle(0, 0, _width, _height);
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.addOnMaterialUpdate(onMaterialUpdate);
			}
		}

		transparent = ini.getBoolean("transparent", true);
	}

	public function addMaterial(material:ILayerMaterial):Void {
		
		material.addOnMaterialUpdate(onMaterialUpdate);
		materials.push(material);
		_materialDirty = true;
	}

	public function removeMaterial(material:ILayerMaterial):Void {
		
		var index:Int = untyped materials.indexOf(material);
		if (index == -1) {
			return;
		}
		material.removeOnMaterialUpdate(onMaterialUpdate);
		materials.splice(index, 1);
		_materialDirty = true;
	}

	public function clearMaterials():Void {
		
		var i:Int = materials.length;
		while ((i-- > 0)) {
			removeMaterial(materials[i]);
		}

	}

	/**
	 * Creates a new <code>BitmapMaterialContainer</code> object.
	 * 
	 * @param	width				The containing width of the texture, applied to all child materials.
	 * @param	height				The containing height of the texture, applied to all child materials.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_material.updateMaterial(source, view);
			}
		}

		if (_colorTransformDirty) {
			updateColorTransform();
		}
		if (_bitmapDirty) {
			updateRenderBitmap();
		}
		if (_materialDirty || _blendModeDirty) {
			clearFaces();
		}
		_blendModeDirty = false;
	}

	/**
	 * @private
	 */
	public override function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		throw new Error("Not implemented");
	}

	/**
	 * @inheritDoc
	 */
	public override function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO {
		
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO);
		//get width and height values
		_faceWidth = Std.int(tri.faceVO.bitmapRect.width);
		_faceHeight = Std.int(tri.faceVO.bitmapRect.height);
		//check to see if bitmapContainer exists
		if ((_containerVO = _containerDictionary.get(tri)) == null) {
			_containerVO = _containerDictionary.put(tri, new FaceMaterialVO());
		}
		//resize container
		if (parentFaceMaterialVO.resized) {
			parentFaceMaterialVO.resized = false;
			_containerVO.resize(_faceWidth, _faceHeight, transparent);
		}
		//call renderFace on each material
		for (__i in 0...materials.length) {
			_material = materials[__i];

			if (_material != null) {
				_containerVO = _material.renderBitmapLayer(tri, containerRect, _containerVO);
			}
		}

		//check to see if face update can be skipped
		if (parentFaceMaterialVO.updated || _containerVO.updated) {
			parentFaceMaterialVO.updated = false;
			_containerVO.updated = false;
			//reset booleans
			_faceMaterialVO.invalidated = false;
			_faceMaterialVO.cleared = false;
			_faceMaterialVO.updated = true;
			//store a clone
			_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
			_faceMaterialVO.bitmap.lock();
			_sourceVO = _faceMaterialVO;
			//draw into faceBitmap
			if (_blendMode == BlendMode.NORMAL && _colorTransform == null) {
				_faceMaterialVO.bitmap.copyPixels(_containerVO.bitmap, _containerVO.bitmap.rect, _zeroPoint, null, null, true);
			} else {
				_faceMaterialVO.bitmap.draw(_containerVO.bitmap, null, _colorTransform, _blendMode);
			}
		}
		return _faceMaterialVO;
	}

}

