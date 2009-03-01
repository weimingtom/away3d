package away3d.core.utils;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.events.EventDispatcher;
import away3d.containers.View3D;
import away3d.core.base.Object3D;
import flash.display.Sprite;


class FaceMaterialVO  {
	
	public var source:Object3D;
	public var view:View3D;
	public var invtexturemapping:Matrix;
	public var texturemapping:Matrix;
	public var width:Int;
	public var height:Int;
	public var color:Int;
	public var bitmap:BitmapData;
	public var cleared:Bool;
	public var updated:Bool;
	public var invalidated:Bool;
	public var backface:Bool;
	public var resized:Bool;
	

	public function new(?source:Object3D=null, ?view:View3D=null) {
		this.cleared = true;
		this.updated = false;
		this.invalidated = true;
		this.backface = false;
		
		
		this.source = source;
		this.view = view;
	}

	public function clear():Void {
		
		cleared = true;
		updated = true;
	}

	public function resize(width:Float, height:Float, ?transparent:Bool=true):Void {
		
		if (this.width == width && this.height == height) {
			return;
		}
		resized = true;
		updated = true;
		this.width = Std.int(width);
		this.height = Std.int(height);
		if ((bitmap != null)) {
			bitmap.dispose();
		}
		bitmap = new BitmapData(Std.int(width), Std.int(height), transparent, 0);
		bitmap.lock();
	}

}

