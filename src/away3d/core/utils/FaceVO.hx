package away3d.core.utils;

	import away3d.containers.*;
	import away3d.core.base.*;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.Dictionary;
	
	class FaceVO
	 {
		
		public var source:Object3D;
		public var view:View3D;
		public var mapping:Matrix;
		public var invtexturemapping:Matrix;
		public var texturemapping:Matrix;
		
		public var width:Int;
		public var height:Int;
		public var color:UInt;
		
		public var bitmap:BitmapData;
		
		public var cleared:Bool ;
		public var updated:Bool ;
		public var invalidated:Bool ;
		public var backface:Bool ;
		public var resized:Bool;
		
		public function new(?source:Object3D = null, ?view:View3D = null)
		{
			
			cleared = true;
			updated = false;
			invalidated = true;
			backface = false;
			this.source = source;
			this.view = view;
		}
		
		public function clear():Void
		{
	        cleared = true;
	        updated = true;
		}
		
		public function resize(width:Float, height:Float, ?transparent:Bool = true):Void
		{
			if (this.width == width && this.height == height)
				return;
			
			resized = true;
			updated = true;
			
			this.width = width;
			this.height = height;
			this.color = color;
			
			if (bitmap)
				bitmap.dispose();
			
			bitmap = new BitmapData(width, height, transparent, 0);
			bitmap.lock();
		}
	}
