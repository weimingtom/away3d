package away3d.materials.shaders;

import away3d.haxeutils.Error;
import flash.events.EventDispatcher;
import away3d.materials.ILayerMaterial;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import flash.events.Event;
import away3d.events.MaterialEvent;
import flash.geom.Rectangle;
import away3d.core.base.Face;
import away3d.core.light.ILightConsumer;
import away3d.core.light.DirectionalLight;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import flash.geom.Matrix;
import flash.display.BlendMode;
import away3d.core.light.LightPrimitive;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.render.AbstractRenderSession;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.math.Number3D;
import away3d.core.draw.DrawTriangle;
import away3d.core.light.AmbientLight;
import away3d.core.draw.DrawPrimitive;
import flash.display.Shape;
import flash.display.Graphics;
import away3d.core.base.Element;
import away3d.haxeutils.BlendModeUtils;


// use namespace arcane;

/**
 * Base class for shaders.
 * Not intended for direct use - use one of the shading materials in the materials package.
 */
class AbstractShader extends EventDispatcher, implements ILayerMaterial {
	public var visible(getVisible, null) : Bool;
	
	/** @private */
	public var _materialupdated:MaterialEvent;
	/** @private */
	public var _faceDictionary:Dictionary;
	/** @private */
	public var _spriteDictionary:Dictionary;
	/** @private */
	public var _sprite:Sprite;
	/** @private */
	public var _shapeDictionary:Dictionary;
	/** @private */
	public var _shape:Shape;
	/** @private */
	public var eTri0x:Float;
	/** @private */
	public var eTri0y:Float;
	/** @private */
	public var eTri1x:Float;
	/** @private */
	public var eTri1y:Float;
	/** @private */
	public var eTri2x:Float;
	/** @private */
	public var eTri2y:Float;
	/** @private */
	public var _s:Shape;
	/** @private */
	public var _graphics:Graphics;
	/** @private */
	public var _bitmapRect:Rectangle;
	/** @private */
	public var _source:Mesh;
	/** @private */
	public var _session:AbstractRenderSession;
	/** @private */
	public var _view:View3D;
	/** @private */
	public var _face:Face;
	/** @private */
	public var _faceVO:FaceVO;
	/** @private */
	public var _lights:ILightConsumer;
	/** @private */
	public var _parentFaceMaterialVO:FaceMaterialVO;
	/** @private */
	public var _n0:Number3D;
	/** @private */
	public var _n1:Number3D;
	/** @private */
	public var _n2:Number3D;
	/** @private */
	public var _dict:Dictionary;
	/** @private */
	public var ambient:AmbientLight;
	/** @private */
	public var directional:DirectionalLight;
	/** @private */
	public var _faceMaterialVO:FaceMaterialVO;
	/** @private */
	public var _normal0:Number3D;
	/** @private */
	public var _normal1:Number3D;
	/** @private */
	public var _normal2:Number3D;
	/** @private */
	public var _mapping:Matrix;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	/**
	 * Determines if the shader bitmap is smoothed (bilinearly filtered) when drawn to screen
	 */
	public var smooth:Bool;
	/**
	 * Determines if faces with the shader applied are drawn with outlines
	 */
	public var debug:Bool;
	/**
	 * Defines a blendMode value for the shader bitmap.
	 */
	public var blendMode:BlendMode;
	

	/** @private */
	public function notifyMaterialUpdate():Void {
		
		if (!hasEventListener(MaterialEvent.MATERIAL_UPDATED)) {
			return;
		}
		if (_materialupdated == null) {
			_materialupdated = new MaterialEvent(MaterialEvent.MATERIAL_UPDATED, this);
		}
		dispatchEvent(_materialupdated);
	}

	/** @private */
	public function clearShapeDictionary():Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_shapeDictionary)).iterator();
		for (__key in __keys) {
			_shape = _shapeDictionary[untyped __key];

			if (_shape != null) {
				_shape.graphics.clear();
			}
		}

	}

	/** @private */
	public function clearLightingShapeDictionary():Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_shapeDictionary)).iterator();
		for (__key in __keys) {
			_dict = _shapeDictionary[untyped __key];

			if (_dict != null) {
				var __keys:Iterator<Dynamic> = untyped (__keys__(_dict)).iterator();
				for (__key in __keys) {
					_shape = _dict[untyped __key];

					if (_shape != null) {
						_shape.graphics.clear();
					}
				}

			}
		}

	}

	/** @private */
	public function contains(v0x:Float, v0y:Float, v1x:Float, v1y:Float, v2x:Float, v2y:Float, x:Float, y:Float):Bool {
		
		if (v0x * (y - v1y) + v1x * (v0y - y) + x * (v1y - v0y) < -0.001) {
			return false;
		}
		if (v0x * (v2y - y) + x * (v0y - v2y) + v2x * (y - v0y) < -0.001) {
			return false;
		}
		if (x * (v2y - v1y) + v1x * (y - v2y) + v2x * (v1y - y) < -0.001) {
			return false;
		}
		return true;
	}

	/**
	 * Returns a shape object for use by environment shaders.
	 * 
	 * @param	layer	The parent layer of the triangle
	 * @return			The resolved shape object to use for drawing
	 */
	private function getShape(layer:Sprite):Shape {
		
		_session = _source.session;
		//check to see if source shape exists
		if ((_shape = _shapeDictionary[untyped _session]) == null) {
			layer.addChild(_shape = _shapeDictionary[untyped _session] = new Shape());
		}
		return _shape;
	}

	/**
	 * Renders the shader to the specified face.
	 * 
	 * @param	face	The face object being rendered.
	 */
	private function renderShader(tri:DrawTriangle):Void {
		
		throw new Error("Not implemented");
	}

	/**
	 * Returns a shape object for use by light shaders
	 * 
	 * @param	layer	The parent layer of the triangle.
	 * @param	light	The light primitive.
	 * @return			The resolved shape object to use for drawing.
	 */
	private function getLightingShape(layer:Sprite, light:LightPrimitive):Shape {
		
		_session = _source.session;
		if (_shapeDictionary[untyped _session] == null) {
			_shapeDictionary[untyped _session] = new Dictionary(true);
		}
		//check to see if source shape exists
		if ((_shape = _shapeDictionary[untyped _session][untyped light]) == null) {
			layer.addChild(_shape = _shapeDictionary[untyped _session][untyped light] = new Shape());
		}
		return _shape;
	}

	/**
	 * Creates a new <code>AbstractShader</code> object.
	 * 
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		// autogenerated
		super();
		this._faceDictionary = new Dictionary(true);
		this._spriteDictionary = new Dictionary(true);
		this._shapeDictionary = new Dictionary(true);
		this._s = new Shape();
		this._normal0 = new Number3D();
		this._normal1 = new Number3D();
		this._normal2 = new Number3D();
		this._mapping = new Matrix();
		
		
		ini = Init.parse(init);
		smooth = ini.getBoolean("smooth", false);
		debug = ini.getBoolean("debug", false);
		var blendModeString:String = ini.getString("blendMode", BlendModeUtils.NORMAL);
		blendMode = BlendModeUtils.toHaxe(blendModeString);
	}

	/**
	 * @inheritDoc
	 */
	public function updateMaterial(source:Object3D, view:View3D):Void {
		
		throw new Error("Not implemented");
	}

	/**
	 * @inheritDoc
	 */
	public function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		_source = cast(tri.source, Mesh);
		_view = tri.view;
		_faceVO = tri.faceVO;
		_face = _faceVO.face;
		_lights = tri.source.lightarray;
	}

	/**
	 * @inheritDoc
	 */
	public function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO {
		
		_source = cast(tri.source, Mesh);
		_view = tri.view;
		_faceVO = tri.faceVO;
		_face = _faceVO.face;
		_parentFaceMaterialVO = parentFaceMaterialVO;
		_faceMaterialVO = getFaceMaterialVO(_faceVO, _source, _view);
		//pass on inverse texturemapping
		_faceMaterialVO.invtexturemapping = parentFaceMaterialVO.invtexturemapping;
		//pass on resize value
		if (parentFaceMaterialVO.resized) {
			parentFaceMaterialVO.resized = false;
			_faceMaterialVO.resized = true;
		}
		//check to see if rendering can be skipped
		if (parentFaceMaterialVO.updated || _faceMaterialVO.invalidated || _faceMaterialVO.updated) {
			parentFaceMaterialVO.updated = false;
			//retrieve the bitmapRect
			_bitmapRect = _faceVO.bitmapRect;
			//reset booleans
			if (_faceMaterialVO.invalidated) {
				_faceMaterialVO.invalidated = false;
			} else {
				_faceMaterialVO.updated = true;
			}
			//store a clone
			_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap;
			//draw shader
			renderShader(tri);
		}
		return _faceMaterialVO;
	}

	/**
	 * @inheritDoc
	 */
	public function getFaceMaterialVO(faceVO:FaceVO, ?source:Object3D=null, ?view:View3D=null):FaceMaterialVO {
		
		if (((_faceMaterialVO = _faceDictionary[untyped faceVO]) != null)) {
			return _faceMaterialVO;
		}
		return _faceDictionary[untyped faceVO] = new FaceMaterialVO();
	}

	/**
	 * @inheritDoc
	 */
	public function getVisible():Bool {
		
		return true;
	}

	/**
	 * @inheritDoc
	 */
	public function addOnMaterialUpdate(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
	}

	/**
	 * @inheritDoc
	 */
	public function removeOnMaterialUpdate(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
	}

}

