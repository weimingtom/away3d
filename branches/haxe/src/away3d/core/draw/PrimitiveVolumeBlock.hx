package away3d.core.draw;

import away3d.haxeutils.Error;
import flash.events.EventDispatcher;
import away3d.core.base.Object3D;


/** Volume block containing drawing primitives */
class PrimitiveVolumeBlock  {
	
	public var source:Object3D;
	public var list:Array<Dynamic>;
	public var minZ:Float;
	public var maxZ:Float;
	public var minX:Float;
	public var maxX:Float;
	public var minY:Float;
	public var maxY:Float;
	

	public function new(source:Object3D) {
		this.minZ =  Math.POSITIVE_INFINITY;
		this.maxZ = -Math.POSITIVE_INFINITY;
		this.minX =  Math.POSITIVE_INFINITY;
		this.maxX = -Math.POSITIVE_INFINITY;
		this.minY =  Math.POSITIVE_INFINITY;
		this.maxY = -Math.POSITIVE_INFINITY;
		
		
		this.source = source;
		this.list = [];
	}

	public function push(pri:DrawPrimitive):Void {
		
		if (minZ > pri.minZ) {
			minZ = pri.minZ;
		}
		if (maxZ < pri.maxZ) {
			maxZ = pri.maxZ;
		}
		if (minX > pri.minX) {
			minX = pri.minX;
		}
		if (maxX < pri.maxX) {
			maxX = pri.maxX;
		}
		if (minY > pri.minY) {
			minY = pri.minY;
		}
		if (maxY < pri.maxY) {
			maxY = pri.maxY;
		}
		list.push(pri);
	}

	public function remove(pri:DrawPrimitive):Void {
		
		var index:Int = untyped list.indexOf(pri);
		if (index == -1) {
			throw new Error("Can't remove");
		}
		list.splice(index, 1);
	}

	public function toString():String {
		
		return "VolumeBlock " + list.length;
	}

}

