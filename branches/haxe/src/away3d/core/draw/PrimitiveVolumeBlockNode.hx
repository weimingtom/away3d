package away3d.core.draw;

import away3d.haxeutils.Error;
import flash.events.EventDispatcher;
import away3d.core.base.Object3D;


/**
 * Volume block tree node
 */
class PrimitiveVolumeBlockNode  {
	
	/**
	 * Reference to the 3d object represented by the volume block node.
	 */
	public var source:Object3D;
	/**
	 * The list of drawing primitives inside the volume block.
	 */
	public var list:Array<Dynamic>;
	/**
	 * Returns the minimum z value of the drawing primitives contained in the volume block node.
	 */
	public var minZ:Float;
	/**
	 * Returns the maximum z value of the drawing primitives contained in the volume block node.
	 */
	public var maxZ:Float;
	/**
	 * Returns the minimum x value of the drawing primitives contained in the volume block node.
	 */
	public var minX:Float;
	/**
	 * Returns the maximum x value of the drawing primitives contained in the volume block node.
	 */
	public var maxX:Float;
	/**
	 * Returns the minimum y value of the drawing primitives contained in the volume block node.
	 */
	public var minY:Float;
	/**
	 * Returns the maximum y value of the drawing primitives contained in the volume block node.
	 */
	public var maxY:Float;
	

	/**
	 * Creates a new <code>PrimitiveQuadrantTreeNode</code> object.
	 * 
	 * @param	source	A reference to the 3d object represented by the volume block node.
	 */
	public function new(source:Object3D) {
		this.minZ = Math.POSITIVE_INFINITY;
		this.maxZ = -Math.POSITIVE_INFINITY;
		this.minX = Math.POSITIVE_INFINITY;
		this.maxX = -Math.POSITIVE_INFINITY;
		this.minY = Math.POSITIVE_INFINITY;
		this.maxY = -Math.POSITIVE_INFINITY;
		
		
		this.source = source;
		this.list = [];
	}

	/**
	 * Adds a primitive to the volume block
	 */
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

	/**
	 * Removes a primitive from the volume block
	 */
	public function remove(pri:DrawPrimitive):Void {
		
		var index:Int = list.indexOf(pri);
		if (index == -1) {
			throw new Error();
		}
		list.splice(index, 1);
	}

}

