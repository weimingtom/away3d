package away3d.materials;

import flash.events.EventDispatcher;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import flash.events.Event;
import away3d.events.MaterialEvent;
import flash.geom.Rectangle;
import away3d.cameras.lenses.ZoomFocusLens;
import away3d.core.draw.DrawBillboard;
import away3d.core.clip.FrustumClipping;
import flash.geom.Point;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import flash.geom.Matrix;
import flash.display.BlendMode;
import away3d.core.clip.RectangleClipping;
import flash.geom.ColorTransform;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.render.AbstractRenderSession;
import away3d.core.utils.FaceMaterialVO;
import flash.display.Sprite;
import away3d.core.math.Number3D;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;
import away3d.core.math.Matrix3D;
import flash.display.Shape;
import flash.display.Graphics;
import away3d.haxeutils.BlendModeUtils;


// use namespace arcane;

/**
 * Basic bitmap material
 */
class BitmapMaterial extends EventDispatcher, implements ITriangleMaterial, implements IUVMaterial, implements ILayerMaterial, implements IBillboardMaterial {
	public var smooth(getSmooth, setSmooth) : Bool;
	public var debug(getDebug, setDebug) : Bool;
	public var repeat(getRepeat, setRepeat) : Bool;
	public var precision(getPrecision, setPrecision) : Float;
	public var width(getWidth, null) : Float;
	public var height(getHeight, null) : Float;
	public var bitmap(getBitmap, setBitmap) : BitmapData;
	public var color(getColor, setColor) : Int;
	public var alpha(getAlpha, setAlpha) : Float;
	public var colorTransform(getColorTransform, setColorTransform) : ColorTransform;
	public var blendMode(getBlendMode, setBlendMode) : BlendMode;
	public var showNormals(getShowNormals, setShowNormals) : Bool;
	public var visible(getVisible, null) : Bool;
	
	/** @private */
	public var _texturemapping:Matrix;
	/** @private */
	public var _bitmap:BitmapData;
	/** @private */
	public var _materialDirty:Bool;
	/** @private */
	public var _renderBitmap:BitmapData;
	/** @private */
	public var _bitmapDirty:Bool;
	/** @private */
	public var _colorTransform:ColorTransform;
	/** @private */
	public var _colorTransformDirty:Bool;
	/** @private */
	public var _blendMode:BlendMode;
	/** @private */
	public var _blendModeDirty:Bool;
	/** @private */
	public var _color:Int;
	/** @private */
	public var _red:Float;
	/** @private */
	public var _green:Float;
	/** @private */
	public var _blue:Float;
	/** @private */
	public var _alpha:Float;
	/** @private */
	public var _faceDictionary:Dictionary;
	/** @private */
	public var _zeroPoint:Point;
	/** @private */
	public var _faceMaterialVO:FaceMaterialVO;
	/** @private */
	public var _mapping:Matrix;
	/** @private */
	public var _s:Shape;
	/** @private */
	public var _graphics:Graphics;
	/** @private */
	public var _bitmapRect:Rectangle;
	/** @private */
	public var _sourceVO:FaceMaterialVO;
	/** @private */
	public var _session:AbstractRenderSession;
	private var _view:View3D;
	private var _near:Float;
	private var _smooth:Bool;
	private var _debug:Bool;
	private var _repeat:Bool;
	private var _precision:Float;
	private var _shapeDictionary:Dictionary;
	private var _shape:Shape;
	private var _materialupdated:MaterialEvent;
	private var focus:Float;
	private var map:Matrix;
	private var triangle:DrawTriangle;
	private var svArray:Array<Dynamic>;
	private var x:Float;
	private var y:Float;
	private var faz:Float;
	private var fbz:Float;
	private var fcz:Float;
	private var mabz:Float;
	private var mbcz:Float;
	private var mcaz:Float;
	private var mabx:Float;
	private var maby:Float;
	private var mbcx:Float;
	private var mbcy:Float;
	private var mcax:Float;
	private var mcay:Float;
	private var dabx:Float;
	private var daby:Float;
	private var dbcx:Float;
	private var dbcy:Float;
	private var dcax:Float;
	private var dcay:Float;
	private var dsab:Float;
	private var dsbc:Float;
	private var dsca:Float;
	private var dmax:Float;
	private var ax:Float;
	private var ay:Float;
	private var az:Float;
	private var bx:Float;
	private var by:Float;
	private var bz:Float;
	private var cx:Float;
	private var cy:Float;
	private var cz:Float;
	private var _showNormals:Bool;
	private var _nn:Number3D;
	private var _sv0:ScreenVertex;
	private var _sv1:ScreenVertex;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	

	/** @private */
	public function notifyMaterialUpdate():Void {
		
		_materialDirty = false;
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
	public function renderSource(source:Object3D, containerRect:Rectangle, mapping:Matrix):Void {
		//check to see if sourceDictionary exists
		
		if ((_sourceVO = _faceDictionary[untyped source]) == null) {
			_sourceVO = _faceDictionary[untyped source] = new FaceMaterialVO();
		}
		_sourceVO.resize(containerRect.width, containerRect.height);
		//check to see if rendering can be skipped
		if (_sourceVO.invalidated || _sourceVO.updated) {
			mapping.scale(containerRect.width / width, containerRect.height / height);
			//reset booleans
			_sourceVO.invalidated = false;
			_sourceVO.cleared = false;
			_sourceVO.updated = false;
			//draw the bitmap
			if (mapping.a == 1 && mapping.d == 1 && mapping.b == 0 && mapping.c == 0 && mapping.tx == 0 && mapping.ty == 0) {
				_sourceVO.bitmap.copyPixels(_bitmap, containerRect, _zeroPoint);
			} else {
				_graphics = _s.graphics;
				_graphics.clear();
				_graphics.beginBitmapFill(_bitmap, mapping, repeat, smooth);
				_graphics.drawRect(0, 0, containerRect.width, containerRect.height);
				_graphics.endFill();
				_sourceVO.bitmap.draw(_s, null, _colorTransform, _blendMode, _sourceVO.bitmap.rect);
			}
		}
	}

	private function createVertexArray():Void {
		
		var index:Float = 100;
		while ((index-- > 0)) {
			svArray.push(new ScreenVertex());
		}

	}

	private function renderRec(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex, index:Int):Void {
		
		ax = a.x;
		ay = a.y;
		az = a.z;
		bx = b.x;
		by = b.y;
		bz = b.z;
		cx = c.x;
		cy = c.y;
		cz = c.z;
		if (!(Std.is(_view.screenClipping, FrustumClipping)) && !_view.screenClipping.rect(Math.min(ax, Math.min(bx, cx)), Math.min(ay, Math.min(by, cy)), Math.max(ax, Math.max(bx, cx)), Math.max(ay, Math.max(by, cy)))) {
			return;
		}
		if ((Std.is(_view.screenClipping, RectangleClipping)) && (az < _near || bz < _near || cz < _near)) {
			return;
		}
		if (index >= 100 || (focus == Math.POSITIVE_INFINITY) || (Math.max(Math.max(ax, bx), cx) - Math.min(Math.min(ax, bx), cx) < 10) || (Math.max(Math.max(ay, by), cy) - Math.min(Math.min(ay, by), cy) < 10)) {
			_session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
			if (debug) {
				_session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
			}
			return;
		}
		faz = focus + az;
		fbz = focus + bz;
		fcz = focus + cz;
		mabz = 2 / (faz + fbz);
		mbcz = 2 / (fbz + fcz);
		mcaz = 2 / (fcz + faz);
		dabx = ax + bx - (mabx = (ax * faz + bx * fbz) * mabz);
		daby = ay + by - (maby = (ay * faz + by * fbz) * mabz);
		dbcx = bx + cx - (mbcx = (bx * fbz + cx * fcz) * mbcz);
		dbcy = by + cy - (mbcy = (by * fbz + cy * fcz) * mbcz);
		dcax = cx + ax - (mcax = (cx * fcz + ax * faz) * mcaz);
		dcay = cy + ay - (mcay = (cy * fcz + ay * faz) * mcaz);
		dsab = (dabx * dabx + daby * daby);
		dsbc = (dbcx * dbcx + dbcy * dbcy);
		dsca = (dcax * dcax + dcay * dcay);
		if ((dsab <= precision) && (dsca <= precision) && (dsbc <= precision)) {
			_session.renderTriangleBitmap(_renderBitmap, map, a, b, c, smooth, repeat, _graphics);
			if (debug) {
				_session.renderTriangleLine(1, 0x00FF00, 1, a, b, c);
			}
			return;
		}
		var map_a:Float = map.a;
		var map_b:Float = map.b;
		var map_c:Float = map.c;
		var map_d:Float = map.d;
		var map_tx:Float = map.tx;
		var map_ty:Float = map.ty;
		var sv1:ScreenVertex;
		var sv2:ScreenVertex;
		var sv3:ScreenVertex = svArray[index++];
		sv3.x = mbcx / 2;
		sv3.y = mbcy / 2;
		sv3.z = (bz + cz) / 2;
		if ((dsab > precision) && (dsca > precision) && (dsbc > precision)) {
			sv1 = svArray[index++];
			sv1.x = mabx / 2;
			sv1.y = maby / 2;
			sv1.z = (az + bz) / 2;
			sv2 = svArray[index++];
			sv2.x = mcax / 2;
			sv2.y = mcay / 2;
			sv2.z = (cz + az) / 2;
			map.a = map_a *= 2;
			map.b = map_b *= 2;
			map.c = map_c *= 2;
			map.d = map_d *= 2;
			map.tx = map_tx *= 2;
			map.ty = map_ty *= 2;
			renderRec(a, sv1, sv2, index);
			map.a = map_a;
			map.b = map_b;
			map.c = map_c;
			map.d = map_d;
			map.tx = map_tx - 1;
			map.ty = map_ty;
			renderRec(sv1, b, sv3, index);
			map.a = map_a;
			map.b = map_b;
			map.c = map_c;
			map.d = map_d;
			map.tx = map_tx;
			map.ty = map_ty - 1;
			renderRec(sv2, sv3, c, index);
			map.a = -map_a;
			map.b = -map_b;
			map.c = -map_c;
			map.d = -map_d;
			map.tx = 1 - map_tx;
			map.ty = 1 - map_ty;
			renderRec(sv3, sv2, sv1, index);
			return;
		}
		dmax = Math.max(dsab, Math.max(dsca, dsbc));
		if (dsab == dmax) {
			sv1 = svArray[index++];
			sv1.x = mabx / 2;
			sv1.y = maby / 2;
			sv1.z = (az + bz) / 2;
			map.a = map_a *= 2;
			map.c = map_c *= 2;
			map.tx = map_tx *= 2;
			renderRec(a, sv1, c, index);
			map.a = map_a + map_b;
			map.b = map_b;
			map.c = map_c + map_d;
			map.d = map_d;
			map.tx = map_tx + map_ty - 1;
			map.ty = map_ty;
			renderRec(sv1, b, c, index);
			return;
		}
		if (dsca == dmax) {
			sv2 = svArray[index++];
			sv2.x = mcax / 2;
			sv2.y = mcay / 2;
			sv2.z = (cz + az) / 2;
			map.b = map_b *= 2;
			map.d = map_d *= 2;
			map.ty = map_ty *= 2;
			renderRec(a, b, sv2, index);
			map.a = map_a;
			map.b = map_b + map_a;
			map.c = map_c;
			map.d = map_d + map_c;
			map.tx = map_tx;
			map.ty = map_ty + map_tx - 1;
			renderRec(sv2, b, c, index);
			return;
		}
		map.a = map_a - map_b;
		map.b = map_b * 2;
		map.c = map_c - map_d;
		map.d = map_d * 2;
		map.tx = map_tx - map_ty;
		map.ty = map_ty * 2;
		renderRec(a, b, sv3, index);
		map.a = map_a * 2;
		map.b = map_b - map_a;
		map.c = map_c * 2;
		map.d = map_d - map_c;
		map.tx = map_tx * 2;
		map.ty = map_ty - map_tx;
		renderRec(a, sv3, c, index);
	}

	/**
	 * Updates the colortransform object applied to the texture from the <code>color</code> and <code>alpha</code> properties.
	 * 
	 * @see color
	 * @see alpha
	 */
	private function updateColorTransform():Void {
		
		_colorTransformDirty = false;
		_bitmapDirty = true;
		_materialDirty = true;
		if (_alpha == 1 && _color == 0xFFFFFF) {
			_renderBitmap = _bitmap;
			if (_colorTransform == null || (_colorTransform.redOffset == 0 && _colorTransform.greenOffset == 0 && _colorTransform.blueOffset == 0)) {
				_colorTransform = null;
				return;
			}
		} else if (_colorTransform == null) {
			_colorTransform = new ColorTransform();
		}
		_colorTransform.redMultiplier = _red;
		_colorTransform.greenMultiplier = _green;
		_colorTransform.blueMultiplier = _blue;
		_colorTransform.alphaMultiplier = _alpha;
		if (_alpha == 0) {
			_renderBitmap = null;
			return;
		}
	}

	/**
	 * Updates the texture bitmapData with the colortransform determined from the <code>color</code> and <code>alpha</code> properties.
	 * 
	 * @see color
	 * @see alpha
	 * @see setColorTransform()
	 */
	private function updateRenderBitmap():Void {
		
		_bitmapDirty = false;
		if ((_colorTransform != null)) {
			if (!_bitmap.transparent && _alpha != 1) {
				_renderBitmap = new BitmapData(_bitmap.width, _bitmap.height, true);
				_renderBitmap.draw(_bitmap);
			} else {
				_renderBitmap = _bitmap.clone();
			}
			_renderBitmap.colorTransform(_renderBitmap.rect, _colorTransform);
		} else {
			_renderBitmap = _bitmap.clone();
		}
		invalidateFaces();
	}

	/**
	 * Calculates the mapping matrix required to draw the triangle texture to screen.
	 * 
	 * @param	tri		The data object holding all information about the triangle to be drawn.
	 * @return			The required matrix object.
	 */
	private function getMapping(tri:DrawTriangle):Matrix {
		
		if (tri.generated) {
			_texturemapping = tri.transformUV(this).clone();
			_texturemapping.invert();
			return _texturemapping;
		}
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO);
		if (!_faceMaterialVO.invalidated) {
			return _faceMaterialVO.texturemapping;
		}
		_faceMaterialVO.invalidated = false;
		_texturemapping = tri.transformUV(this).clone();
		_texturemapping.invert();
		return _faceMaterialVO.texturemapping = _texturemapping;
	}

	/**
	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen.
	 */
	public function getSmooth():Bool {
		
		return _smooth;
	}

	public function setSmooth(val:Bool):Bool {
		
		if (_smooth == val) {
			return val;
		}
		_smooth = val;
		_materialDirty = true;
		return val;
	}

	/**
	 * Toggles debug mode: textured triangles are drawn with white outlines, precision correction triangles are drawn with blue outlines.
	 */
	public function getDebug():Bool {
		
		return _debug;
	}

	public function setDebug(val:Bool):Bool {
		
		if (_debug == val) {
			return val;
		}
		_debug = val;
		_materialDirty = true;
		return val;
	}

	/**
	 * Determines if texture bitmap will tile in uv-space
	 */
	public function getRepeat():Bool {
		
		return _repeat;
	}

	public function setRepeat(val:Bool):Bool {
		
		if (_repeat == val) {
			return val;
		}
		_repeat = val;
		_materialDirty = true;
		return val;
	}

	/**
	 * Corrects distortion caused by the affine transformation (non-perpective) of textures.
	 * The number refers to the pixel correction value - ie. a value of 2 means a distorion correction to within 2 pixels of the correct perspective distortion.
	 * 0 performs no precision.
	 */
	public function getPrecision():Float {
		
		return _precision;
	}

	public function setPrecision(val:Float):Float {
		
		_precision = val * val * 1.4;
		_materialDirty = true;
		return val;
	}

	/**
	 * @inheritDoc
	 */
	public function getWidth():Float {
		
		return _bitmap.width;
	}

	/**
	 * @inheritDoc
	 */
	public function getHeight():Float {
		
		return _bitmap.height;
	}

	/**
	 * @inheritDoc
	 */
	public function getBitmap():BitmapData {
		
		return _bitmap;
	}

	public function setBitmap(val:BitmapData):BitmapData {
		
		_bitmap = val;
		_bitmapDirty = true;
		return val;
	}

	/**
	 * @inheritDoc
	 */
	public function getPixel32(u:Float, v:Float):Int {
		
		if (repeat) {
			x = u % 1;
			y = (1 - v % 1);
		} else {
			x = u;
			y = (1 - v);
		}
		return _bitmap.getPixel32(Std.int(x * _bitmap.width), Std.int(y * _bitmap.height));
	}

	/**
	 * Defines a colored tint for the texture bitmap.
	 */
	public function getColor():Int {
		
		return _color;
	}

	public function setColor(val:Int):Int {
		
		if (_color == val) {
			return val;
		}
		_color = val;
		_red = ((_color & 0xFF0000) >> 16) / 255;
		_green = ((_color & 0x00FF00) >> 8) / 255;
		_blue = (_color & 0x0000FF) / 255;
		_colorTransformDirty = true;
		return val;
	}

	/**
	 * Defines an alpha value for the texture bitmap.
	 */
	public function getAlpha():Float {
		
		return _alpha;
	}

	public function setAlpha(value:Float):Float {
		
		if (value > 1) {
			value = 1;
		}
		if (value < 0) {
			value = 0;
		}
		if (_alpha == value) {
			return value;
		}
		_alpha = value;
		_colorTransformDirty = true;
		return value;
	}

	/**
	 * Defines a colortransform for the texture bitmap.
	 */
	public function getColorTransform():ColorTransform {
		
		return _colorTransform;
	}

	public function setColorTransform(value:ColorTransform):ColorTransform {
		
		_colorTransform = value;
		if ((_colorTransform != null)) {
			_red = _colorTransform.redMultiplier;
			_green = _colorTransform.greenMultiplier;
			_blue = _colorTransform.blueMultiplier;
			_alpha = _colorTransform.alphaMultiplier;
			_color = ((Std.int(_red * 255) << 16) + (Std.int(_green * 255) << 8) + Std.int(_blue * 255));
		}
		_colorTransformDirty = true;
		return value;
	}

	/**
	 * Defines a blendMode value for the texture bitmap.
	 * Applies to materials rendered as children of <code>BitmapMaterialContainer</code> or  <code>CompositeMaterial</code>.
	 * 
	 * @see away3d.materials.BitmapMaterialContainer
	 * @see away3d.materials.CompositeMaterial
	 */
	public function getBlendMode():BlendMode {
		
		return _blendMode;
	}

	public function setBlendMode(val:BlendMode):BlendMode {
		
		if (_blendMode == val) {
			return val;
		}
		_blendMode = val;
		_blendModeDirty = true;
		return val;
	}

	/**
	 * Displays the normals per face in pink lines.
	 */
	public function getShowNormals():Bool {
		
		return _showNormals;
	}

	public function setShowNormals(val:Bool):Bool {
		
		if (_showNormals == val) {
			return val;
		}
		_showNormals = val;
		_materialDirty = true;
		return val;
	}

	/**
	 * Creates a new <code>BitmapMaterial</code> object.
	 * 
	 * @param	bitmap				The bitmapData object to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		// autogenerated
		super();
		this._color = 0xFFFFFF;
		this._red = 1;
		this._green = 1;
		this._blue = 1;
		this._alpha = 1;
		this._faceDictionary = new Dictionary(true);
		this._zeroPoint = new Point(0, 0);
		this._s = new Shape();
		this._shapeDictionary = new Dictionary(true);
		this.map = new Matrix();
		this.triangle = new DrawTriangle();
		this.svArray = new Array<Dynamic>();
		
		
		_bitmap = bitmap;
		ini = Init.parse(init);
		smooth = ini.getBoolean("smooth", false);
		debug = ini.getBoolean("debug", false);
		repeat = ini.getBoolean("repeat", false);
		precision = ini.getNumber("precision", 0);
		var blendModeString:String = ini.getString("blendMode", BlendModeUtils.NORMAL);
		_blendMode = BlendModeUtils.toHaxe(blendModeString);
		alpha = ini.getNumber("alpha", _alpha, {min:0, max:1});
		color = ini.getColor("color", _color);
		colorTransform = ini.getObject("colorTransform", ColorTransform);
		showNormals = ini.getBoolean("showNormals", false);
		_colorTransformDirty = true;
		createVertexArray();
	}

	/**
	 * @inheritDoc
	 */
	public function updateMaterial(source:Object3D, view:View3D):Void {
		
		_graphics = null;
		clearShapeDictionary();
		if (_colorTransformDirty) {
			updateColorTransform();
		}
		if (_bitmapDirty) {
			updateRenderBitmap();
		}
		if (_materialDirty || _blendModeDirty) {
			clearFaces(source, view);
		}
		_blendModeDirty = false;
	}

	public function getFaceMaterialVO(faceVO:FaceVO, ?source:Object3D=null, ?view:View3D=null):FaceMaterialVO {
		//check to see if faceMaterialVO exists
		
		if (((_faceMaterialVO = _faceDictionary[untyped faceVO]) != null)) {
			return _faceMaterialVO;
		}
		return _faceDictionary[untyped faceVO] = new FaceMaterialVO();
	}

	/**
	 * @inheritDoc
	 */
	public function clearFaces(?source:Object3D=null, ?view:View3D=null):Void {
		
		notifyMaterialUpdate();
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				if (!_faceMaterialVO.cleared) {
					_faceMaterialVO.clear();
				}
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function invalidateFaces(?source:Object3D=null, ?view:View3D=null):Void {
		
		_materialDirty = true;
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				_faceMaterialVO.invalidated = true;
			}
		}

	}

	/**
	 * @inheritDoc
	 */
	public function renderLayer(tri:DrawTriangle, layer:Sprite, level:Int):Void {
		
		if (blendMode == BlendMode.NORMAL) {
			_graphics = layer.graphics;
		} else {
			_session = tri.source.session;
			//check to see if source shape exists
			if ((_shape = _shapeDictionary[untyped _session]) == null) {
				layer.addChild(_shape = _shapeDictionary[untyped _session] = new Shape());
			}
			_shape.blendMode = _blendMode;
			_graphics = _shape.graphics;
		}
		renderTriangle(tri);
	}

	/**
	 * @inheritDoc
	 */
	public function renderTriangle(tri:DrawTriangle):Void {
		
		_mapping = getMapping(tri);
		_session = tri.source.session;
		_view = tri.view;
		_near = _view.screenClipping.minZ;
		if (_graphics == null && _session.newLayer != null) {
			_graphics = _session.newLayer.graphics;
		}
		if ((precision > 0)) {
			if (Std.is(_view.camera.lens, ZoomFocusLens)) {
				focus = tri.view.camera.focus;
			} else {
				focus = 0;
			}
			map.a = _mapping.a;
			map.b = _mapping.b;
			map.c = _mapping.c;
			map.d = _mapping.d;
			map.tx = _mapping.tx;
			map.ty = _mapping.ty;
			renderRec(tri.v0, tri.v1, tri.v2, 0);
		} else {
			_session.renderTriangleBitmap(_renderBitmap, _mapping, tri.v0, tri.v1, tri.v2, smooth, repeat, _graphics);
		}
		if (debug) {
			_session.renderTriangleLine(0, 0x0000FF, 1, tri.v0, tri.v1, tri.v2);
		}
		if (showNormals) {
			if (_nn == null) {
				_nn = new Number3D();
				_sv0 = new ScreenVertex();
				_sv1 = new ScreenVertex();
			}
			var t:Matrix3D = tri.view.cameraVarsStore.viewTransformDictionary[untyped tri.source];
			_nn.rotate(tri.faceVO.face.normal, t);
			_sv0.x = (tri.v0.x + tri.v1.x + tri.v2.x) / 3;
			_sv0.y = (tri.v0.y + tri.v1.y + tri.v2.y) / 3;
			_sv0.z = (tri.v0.z + tri.v1.z + tri.v2.z) / 3;
			_sv1.x = (_sv0.x - (30 * _nn.x));
			_sv1.y = (_sv0.y - (30 * _nn.y));
			_sv1.z = (_sv0.z - (30 * _nn.z));
			_session.renderLine(_sv0, _sv1, 0, 0xFF00FF, 1);
		}
	}

	/**
	 * @inheritDoc
	 */
	public function renderBillboard(bill:DrawBillboard):Void {
		
		bill.source.session.renderBillboardBitmap(_renderBitmap, bill, smooth);
	}

	/**
	 * @inheritDoc
	 */
	public function renderBitmapLayer(tri:DrawTriangle, containerRect:Rectangle, parentFaceMaterialVO:FaceMaterialVO):FaceMaterialVO {
		//draw the bitmap once
		
		renderSource(tri.source, containerRect, new Matrix());
		//get the correct faceMaterialVO
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO);
		//pass on resize value
		if (parentFaceMaterialVO.resized) {
			parentFaceMaterialVO.resized = false;
			_faceMaterialVO.resized = true;
		}
		//pass on invtexturemapping value
		_faceMaterialVO.invtexturemapping = parentFaceMaterialVO.invtexturemapping;
		//check to see if face update can be skipped
		if (parentFaceMaterialVO.updated || _faceMaterialVO.invalidated || _faceMaterialVO.updated) {
			parentFaceMaterialVO.updated = false;
			//reset booleans
			_faceMaterialVO.invalidated = false;
			_faceMaterialVO.cleared = false;
			_faceMaterialVO.updated = true;
			//store a clone
			_faceMaterialVO.bitmap = parentFaceMaterialVO.bitmap.clone();
			//draw into faceBitmap
			_faceMaterialVO.bitmap.copyPixels(_sourceVO.bitmap, tri.faceVO.bitmapRect, _zeroPoint, null, null, true);
		}
		return _faceMaterialVO;
	}

	/**
	 * @inheritDoc
	 */
	public function getVisible():Bool {
		
		return _alpha > 0;
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

