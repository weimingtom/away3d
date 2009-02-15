package away3d.core.utils;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.filters.BlurFilter;
import flash.utils.Dictionary;


/**
 * Provides static pre-blurred bitmap images for depth of field-effect
 * when used together with billboarded sprites, such as Billboards.
 */
class DofCache  {
	
	private var bitmaps:Array<Dynamic>;
	private var levels:Float;
	private var maxBitmap:BitmapData;
	private var minBitmap:BitmapData;
	static public var focus:Float;
	static public var aperture:Float = 22;
	static public var maxblur:Float = 150;
	static public var doflevels:Float = 16;
	static public var usedof:Bool = false;
	static private var caches:Dictionary = new Dictionary();
	

	static public function resetDof(enabled:Bool):Void {
		
		usedof = enabled;
		var __keys:Iterator<Dynamic> = untyped (__keys__(caches)).iterator();
		for (__key in __keys) {
			var cache:DofCache = caches[cast __key];

			if (!enabled) {
				cache = new DofCache();
			} else {
				cache = new DofCache();
			}
		}

	}

	static public function getDofCache(bitmap:BitmapData):DofCache {
		
		if (caches[cast bitmap] == null) {
			if (!usedof) {
				caches[cast bitmap] = new DofCache();
			} else {
				caches[cast bitmap] = new DofCache();
			}
		}
		return caches[cast bitmap];
	}

	public function new(levels:Float, texture:BitmapData) {
		
		
		this.levels = levels;
		var mat:Matrix = new Matrix();
		var pnt:Point = new Point();
		bitmaps = new Array<Dynamic>();
		var j:Float = 0;
		while (j < levels) {
			var tfilter:BlurFilter = new BlurFilter();
			mat.identity();
			var t:Int = Std.int((texture.width * (1 + j / (levels / 2))));
			mat.translate(-texture.width / 2, -texture.height / 2);
			mat.translate(t / 2, t / 2);
			var tbmp:BitmapData = new BitmapData();
			tbmp.draw(texture, mat);
			tbmp.applyFilter(tbmp, tbmp.rect, pnt, tfilter);
			bitmaps[j] = tbmp;
			
			// update loop variables
			j++;
		}

		minBitmap = bitmaps[0];
		maxBitmap = bitmaps[bitmaps.length - 1];
	}

	public function getBitmap(depth:Float):BitmapData {
		
		var t:Float = focus - depth;
		if (focus - depth < 0) {
			t = -t;
		}
		t = t / aperture;
		t = Math.floor(t);
		if (t > (levels - 1)) {
			return maxBitmap;
		}
		if (t < 0) {
			return minBitmap;
		}
		return bitmaps[t];
	}

}

