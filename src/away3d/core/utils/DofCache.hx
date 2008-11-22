package away3d.core.utils;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.filters.BlurFilter;
	import flash.utils.Dictionary;
	
	/**
	 * Provides static pre-blurred bitmap images for depth of field-effect
	 * when used together with billboarded sprites, such as particles.
	 */
	class DofCache
	 {
		
		var bitmaps:Array<Dynamic>;
		var levels:Float;
		var maxBitmap:BitmapData;
		var minBitmap:BitmapData;

		public static var focus:Float;

        inline public static var aperture:Int = 22;
        inline public static var maxblur:Int = 150;
        inline public static var doflevels:Int = 16;
    	inline public static var usedof:Bool = false;
		static var caches:Dictionary = new Dictionary();
		
		public static function resetDof(enabled:Bool):Void
		{
			usedof = enabled;
			for (cache in caches)
			{				
				if(!enabled)
				{
					cache = new DofCache(1,cache.bitmaps[0]);											
				}
				else
				{
					cache = new DofCache(doflevels,cache.bitmaps[0]);						
				}
			}
		}
		
		public static function getDofCache(bitmap:BitmapData):DofCache
		{
			if(caches[bitmap] == null)
			{
				if(!usedof)
				{
					caches[bitmap] = new DofCache(1, bitmap);
				}
				else
				{
					caches[bitmap] = new DofCache(doflevels, bitmap);					
				}
			}	
			
			return caches[bitmap];
		}
		
		public function new(levels:Float, texture:BitmapData)
		{			
			this.levels = levels;
			
			var mat:Matrix = new Matrix();
			var pnt:Point = new Point(0,0);
			bitmaps = new Array(levels);
			for(j in 0...levels)
			{
				var tfilter:BlurFilter = new BlurFilter(2+maxblur*j/levels, 2+maxblur*j/levels, 4);
				mat.identity();
				var t:Int =(texture.width*(1+j/(levels/2)));
				mat.translate(-texture.width/2, -texture.height/2);
				mat.translate(t/2,t/2);
				var tbmp:BitmapData = new BitmapData(t,t,true,0);
				tbmp.draw(texture, mat);
				tbmp.applyFilter(tbmp, tbmp.rect,pnt,tfilter);
				bitmaps[j] = tbmp;
			}					
			minBitmap = bitmaps[0];
			maxBitmap = bitmaps[bitmaps.length-1];
		}
		
		public function getBitmap(depth:Float):BitmapData
		{
			var t:Int = focus-depth;
			if(focus-depth<0) t = -t;
			t = t / aperture;
			t = Math.floor(t);
			if(t > (levels-1)) return maxBitmap;
			if(t < 0) return minBitmap;
			return bitmaps[t];
		}
	}
