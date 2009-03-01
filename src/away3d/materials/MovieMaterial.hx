package away3d.materials;

import away3d.containers.View3D;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.events.EventDispatcher;
import flash.events.Event;
import away3d.core.base.Object3D;
import away3d.core.utils.Init;
import flash.display.DisplayObjectContainer;
import away3d.events.MouseEvent3D;


// use namespace arcane;

/**
 * Animated movie material.
 */
class MovieMaterial extends TransformBitmapMaterial, implements ITriangleMaterial, implements IUVMaterial {
	public var movie(getMovie, setMovie) : Sprite;
	public var clipRect(getClipRect, setClipRect) : Rectangle;
	public var lockW(getLockW, setLockW) : Float;
	public var lockH(getLockH, setLockH) : Float;
	
	private var _movie:Sprite;
	private var _lastsession:Int;
	private var _colTransform:ColorTransform;
	private var _bMode:BlendMode;
	private var __xx:Float;
	private var __yy:Float;
	private var __t:Matrix;
	/**
	 * Defines the transparent property of the texture bitmap created from the movie
	 * 
	 * @see movie
	 */
	public var transparent:Bool;
	/**
	 * Indicates whether the texture bitmap is updated on every frame
	 */
	public var autoUpdate:Bool;
	/**
	 * Indicates whether the material will pass mouse interaction through to the movieclip
	 */
	public var interactive:Bool;
	private var _clipRect:Rectangle;
	private var _lockW:Float;
	private var _lockH:Float;
	private var rendered:Bool;
	

	private function onMouseOver(event:MouseEvent3D):Void {
		
		if (event.material == this) {
			event.object.addOnMouseMove(onMouseMove);
			onMouseMove(event);
		}
	}

	private function onMouseOut(event:MouseEvent3D):Void {
		
		if (event.material == this) {
			event.object.removeOnMouseMove(onMouseMove);
			resetInteractiveLayer();
		}
	}

	private function onMouseMove(event:MouseEvent3D):Void {
		
		__xx = event.uv.u * _renderBitmap.width;
		__yy = (1 - event.uv.v) * _renderBitmap.height;
		if ((_transform != null)) {
			__t = _transform.clone();
			__t.invert();
			movie.x = event.screenX - __xx * __t.a - __yy * __t.c - __t.tx;
			movie.y = event.screenY - __xx * __t.b - __yy * __t.d - __t.ty;
		} else {
			movie.x = event.screenX - __xx;
			movie.y = event.screenY - __yy;
		}
	}

	private function resetInteractiveLayer():Void {
		
		movie.x = -10000;
		movie.y = -10000;
	}

	/** @private */
	private override function updateRenderBitmap():Void {
		
	}

	/**
	 * @inheritDoc
	 */
	public override function getWidth():Float {
		
		return _renderBitmap.width;
	}

	/**
	 * @inheritDoc
	 */
	public override function getHeight():Float {
		
		return _renderBitmap.height;
	}

	/**
	 * Defines the movieclip used for rendering the material
	 */
	public function getMovie():Sprite {
		
		return _movie;
	}

	public function setMovie(val:Sprite):Sprite {
		
		if (_movie == val) {
			return val;
		}
		if ((_movie != null) && (_movie.parent != null)) {
			_movie.parent.removeChild(_movie);
		}
		_movie = val;
		if (!autoUpdate) {
			update();
		}
		return val;
	}

	/**
	 * Creates a new <code>BitmapMaterial</code> object.
	 * 
	 * @param	movie				The sprite object to be used as the material's texture.
	 * @param	init	[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(movie:Sprite, ?init:Dynamic=null) {
		
		
		ini = Init.parse(init);
		transparent = ini.getBoolean("transparent", true);
		autoUpdate = ini.getBoolean("autoUpdate", true);
		interactive = ini.getBoolean("interactive", false);
		_movie = movie;
		_lockW = ini.getNumber("lockW", movie.width);
		_lockH = ini.getNumber("lockH", movie.height);
		_bitmap = new BitmapData(Std.int(Math.max(1, _lockW)), Std.int(Math.max(1, _lockH)), transparent, (transparent) ? 0x00ffffff : 0);
		super(_bitmap, ini);
	}

	/**
	 * @inheritDoc
	 */
	public override function updateMaterial(source:Object3D, view:View3D):Void {
		
		super.updateMaterial(source, view);
		if (autoUpdate) {
			update();
		}
		_session = source.session;
		if (interactive) {
			if (!view._interactiveLayer.contains(movie)) {
				view._interactiveLayer.addChild(movie);
				resetInteractiveLayer();
				source.addOnMouseOver(onMouseOver);
				source.addOnMouseOut(onMouseOut);
			}
		} else if (view._interactiveLayer.contains(movie)) {
			view._interactiveLayer.removeChild(movie);
			source.removeOnMouseOver(onMouseOver);
			source.removeOnMouseOut(onMouseOut);
		}
	}

	/**
	 * Updates the texture bitmap with the current frame of the movieclip object
	 * 
	 * @see movie
	 */
	public function update():Void {
		
		if (_renderBitmap != null) {
			notifyMaterialUpdate();
			var rectsource:Rectangle = (_clipRect == null || !rendered) ? _renderBitmap.rect : _clipRect;
			if (transparent) {
				_renderBitmap.fillRect(rectsource, 0x00FFFFFF);
			}
			if (_alpha != 1 || _color != 0xFFFFFF) {
				_colTransform = _colorTransform;
			} else {
				_colTransform = movie.transform.colorTransform;
			}
			if (_blendMode != BlendMode.NORMAL) {
				_bMode = _blendMode;
			} else {
				_bMode = movie.blendMode;
			}
			_renderBitmap.draw(movie, new Matrix(movie.scaleX, 0, 0, movie.scaleY), _colTransform, _bMode, rectsource);
			if (!rendered) {
				rendered = true;
			}
		}
	}

	/**
	 * A Rectangle object that defines the area of the source to draw. If null, no clipping occurs and the entire source object is drawn. Default is null.
	 * 
	 * @param clipRect	 A Rectangle object that defines the area of the source to draw. If null, no clipping occurs and the entire source object is drawn.
	 */
	public function setClipRect(rect:Rectangle):Rectangle {
		
		_clipRect = rect;
		return rect;
	}

	public function getClipRect():Rectangle {
		
		return _clipRect;
	}

	/**
	 *A Number to lock the height of the draw region other than the source movieclip source. Default is the movieclip height.
	 * 
	 * @param width	 A Number to lock the height of the draw region other than the source movieclip source.
	 */
	public function setLockW(width:Float):Float {
		
		_lockW = (!Math.isNaN(width) && width > 1) ? width : _lockW;
		if (_renderBitmap != null) {
			_bitmap.dispose();
			_renderBitmap.dispose();
			_bitmap = new BitmapData(Std.int(Math.max(1, _lockW)), Std.int(Math.max(1, _lockH)), transparent, (transparent) ? 0x00ffffff : 0);
			_renderBitmap = _bitmap.clone();
			update();
		}
		return width;
	}

	public function getLockW():Float {
		
		return _lockW;
	}

	/**
	 *A Number to lock the height of the draw region other than the source movieclip source. Default is the movieclip height.
	 * 
	 * @param height	 A Number to lock the height of the draw region other than the source movieclip source.
	 */
	public function setLockH(height:Float):Float {
		
		_lockH = (!Math.isNaN(height) && height > 1) ? height : _lockH;
		if (_renderBitmap != null) {
			_bitmap.dispose();
			_renderBitmap.dispose();
			_bitmap = new BitmapData(Std.int(Math.max(1, _lockW)), Std.int(Math.max(1, _lockH)), transparent, (transparent) ? 0x00ffffff : 0);
			_renderBitmap = _bitmap.clone();
			update();
		}
		return height;
	}

	public function getLockH():Float {
		
		return _lockH;
	}

}

