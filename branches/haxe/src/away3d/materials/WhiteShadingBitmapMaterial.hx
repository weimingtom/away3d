package away3d.materials;

import flash.events.EventDispatcher;
import away3d.core.utils.CacheStore;
import flash.display.BitmapData;
import away3d.containers.View3D;
import flash.utils.Dictionary;
import flash.geom.Point;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import flash.geom.Matrix;
import away3d.core.utils.Init;
import away3d.core.utils.FaceVO;
import away3d.core.render.AbstractRenderSession;
import away3d.core.utils.FaceMaterialVO;
import flash.filters.ColorMatrixFilter;
import away3d.core.draw.DrawTriangle;
import away3d.core.draw.DrawPrimitive;


// use namespace arcane;

/**
 * Bitmap material with flat white lighting
 */
class WhiteShadingBitmapMaterial extends CenterLightingMaterial, implements IUVMaterial {
	public var width(getWidth, null) : Float;
	public var height(getHeight, null) : Float;
	public var bitmap(getBitmap, setBitmap) : BitmapData;
	
	private var _bitmap:BitmapData;
	private var _texturemapping:Matrix;
	private var _faceMaterialVO:FaceMaterialVO;
	private var _faceDictionary:Dictionary;
	private var blackrender:Bool;
	private var whiterender:Bool;
	private var whitek:Float;
	private var bitmapPoint:Point;
	private var colorTransform:ColorMatrixFilter;
	private var cache:Dictionary;
	private var step:Int;
	private var mapping:Matrix;
	private var br:Float;
	/**
	 * Determines if texture bitmap is smoothed (bilinearly filtered) when drawn to screen
	 */
	public var smooth:Bool;
	/**
	 * Determines if texture bitmap will tile in uv-space
	 */
	public var repeat:Bool;
	

	private function ladder(v:Float):Float {
		
		if (v < 1 / 0xFF) {
			return 0;
		}
		if (v > 0xFF) {
			v = 0xFF;
		}
		return Math.exp(Math.round(Math.log(v) * step) / step);
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
		_faceMaterialVO = getFaceMaterialVO(tri.faceVO, tri.source, tri.view);
		if (!_faceMaterialVO.invalidated) {
			return _faceMaterialVO.texturemapping;
		}
		_texturemapping = tri.transformUV(this).clone();
		_texturemapping.invert();
		return _faceMaterialVO.texturemapping = _texturemapping;
	}

	/** @private */
	private override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Float, kag:Float, kab:Float, kdr:Float, kdg:Float, kdb:Float, ksr:Float, ksg:Float, ksb:Float):Void {
		
		br = (kar + kag + kab + kdr + kdg + kdb + ksr + ksg + ksb) / 3;
		mapping = getMapping(tri);
		v0 = tri.v0;
		v1 = tri.v1;
		v2 = tri.v2;
		if ((br < 1) && (blackrender || ((step < 16) && (!_bitmap.transparent)))) {
			session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
			session.renderTriangleColor(0x000000, 1 - br, v0, v1, v2);
		} else if ((br > 1) && (whiterender)) {
			session.renderTriangleBitmap(_bitmap, mapping, v0, v1, v2, smooth, repeat);
			session.renderTriangleColor(0xFFFFFF, (br - 1) * whitek, v0, v1, v2);
		} else {
			if (step < 64) {
				if (Math.random() < 0.01) {
					doubleStepTo(64);
				}
			}
			var brightness:Float = ladder(br);
			var bitmap:BitmapData = cache[untyped brightness];
			if (bitmap == null) {
				bitmap = new BitmapData(_bitmap.width, _bitmap.height, true, 0x00000000);
				colorTransform.matrix = [brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, brightness, 0, 0, 0, 0, 0, 1, 0];
				bitmap.applyFilter(_bitmap, bitmap.rect, bitmapPoint, colorTransform);
				cache[untyped brightness] = bitmap;
			}
			session.renderTriangleBitmap(bitmap, mapping, v0, v1, v2, smooth, repeat);
		}
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

	public function setBitmap(bitmap:BitmapData):BitmapData {
		
		return _bitmap = bitmap;
	}

	/**
	 * @inheritDoc
	 */
	public override function getVisible():Bool {
		
		return true;
	}

	/**
	 * @inheritDoc
	 */
	public function getPixel32(u:Float, v:Float):Int {
		
		return _bitmap.getPixel32(Std.int(u * _bitmap.width), Std.int((1 - v) * _bitmap.height));
	}

	/**
	 * Creates a new <code>WhiteShadingBitmapMaterial</code> object.
	 * 
	 * @param	bitmap				The bitmapData object to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(bitmap:BitmapData, ?init:Dynamic=null) {
		this._faceDictionary = new Dictionary(true);
		this.whitek = 0.2;
		this.bitmapPoint = new Point(0, 0);
		this.colorTransform = new ColorMatrixFilter();
		this.step = 1;
		
		
		_bitmap = bitmap;
		super(init);
		smooth = ini.getBoolean("smooth", false);
		repeat = ini.getBoolean("repeat", false);
		if (!CacheStore.whiteShadingCache[untyped _bitmap]) {
			CacheStore.whiteShadingCache[untyped _bitmap] = new Dictionary(true);
		}
		cache = CacheStore.whiteShadingCache[untyped _bitmap];
	}

	public function doubleStepTo(limit:Int):Void {
		
		if (step < limit) {
			step *= 2;
		}
	}

	public function getFaceMaterialVO(faceVO:FaceVO, ?source:Object3D=null, ?view:View3D=null):FaceMaterialVO {
		
		if (((_faceMaterialVO = _faceDictionary[untyped faceVO]) != null)) {
			return _faceMaterialVO;
		}
		return _faceDictionary[untyped faceVO] = new FaceMaterialVO();
	}

	/**
	 * @inheritDoc
	 */
	public function clearFaces(?source:Object3D=null, ?view:View3D=null):Void {
		
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
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(_faceDictionary)).iterator();
		for (__key in __keys) {
			_faceMaterialVO = _faceDictionary[untyped __key];

			if (_faceMaterialVO != null) {
				_faceMaterialVO.invalidated = true;
			}
		}

	}

}

