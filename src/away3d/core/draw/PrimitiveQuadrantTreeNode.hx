package away3d.core.draw;

import flash.events.EventDispatcher;
import away3d.core.base.Object3D;


/**
 * Quadrant tree node
 */
class PrimitiveQuadrantTreeNode  {
	
	private var render_center_length:Int;
	private var render_center_index:Int;
	private var halfwidth:Float;
	private var halfheight:Float;
	private var level:Int;
	private var maxlevel:Int;
	/**
	 * Array of primitives that lie in the center of the quadrant.
	 */
	public var center:Array<Dynamic>;
	/**
	 * The quadrant tree node for the top left quadrant.
	 */
	public var lefttop:PrimitiveQuadrantTreeNode;
	/**
	 * The quadrant tree node for the bottom left quadrant.
	 */
	public var leftbottom:PrimitiveQuadrantTreeNode;
	/**
	 * The quadrant tree node for the top right quadrant.
	 */
	public var righttop:PrimitiveQuadrantTreeNode;
	/**
	 * The quadrant tree node for the bottom right quadrant.
	 */
	public var rightbottom:PrimitiveQuadrantTreeNode;
	/**
	 * Determines if the bounds of the top left quadrant need re-calculating.
	 */
	public var lefttopFlag:Bool;
	/**
	 * Determines if the bounds of the bottom left quadrant need re-calculating.
	 */
	public var leftbottomFlag:Bool;
	/**
	 * Determines if the bounds of the top right quadrant need re-calculating.
	 */
	public var righttopFlag:Bool;
	/**
	 * Determines if the bounds of the bottom right quadrant need re-calculating.
	 */
	public var rightbottomFlag:Bool;
	/**
	 * Determines if the quadrant node contains only one source.
	 */
	public var onlysourceFlag:Bool;
	/**
	 * hold the 3d object referenced when <code>onlysourceFlag</code> is true.
	 */
	public var onlysource:Object3D;
	/**
	 * The x coordinate of the quadrant division.
	 */
	public var xdiv:Float;
	/**
	 * The x coordinate of the quadrant division.
	 */
	public var ydiv:Float;
	/**
	 * The quadrant parent.
	 */
	public var parent:PrimitiveQuadrantTreeNode;
	/**
	 * Placeholder function for creating new quadrant node from a cache of objects.
	 * Saves recreating objects and GC problems.
	 */
	public var create:Dynamic;
	

	private function render_other(limit:Float):Void {
		
		if (lefttopFlag) {
			lefttop.render(limit);
		}
		if (leftbottomFlag) {
			leftbottom.render(limit);
		}
		if (righttopFlag) {
			righttop.render(limit);
		}
		if (rightbottomFlag) {
			rightbottom.render(limit);
		}
	}

	/**
	 * Creates a new <code>PrimitiveQuadrantTreeNode</code> object.
	 *
	 * @param	xdiv	The x coordinate for the division between left and right child quadrants.
	 * @param	ydiv	The y coordinate for the division between top and bottom child quadrants.
	 * @param	width	The width of the quadrant node.
	 * @param	xdiv	The height of the quadrant node.
	 * @param	level	The iteration number of the quadrant node.
	 * @param	parent	The parent quadrant of the quadrant node.
	 */
	public function new(xdiv:Float, ydiv:Float, width:Float, height:Float, level:Int, ?parent:PrimitiveQuadrantTreeNode=null) {
		this.render_center_length = -1;
		this.render_center_index = -1;
		this.maxlevel = 4;
		this.center = new Array<Dynamic>();
		this.onlysourceFlag = true;
		
		
		this.level = level;
		this.xdiv = xdiv;
		this.ydiv = ydiv;
		halfwidth = width / 2;
		halfheight = height / 2;
		this.parent = parent;
	}

	/**
	 * Adds a primitive to the quadrant
	 */
	public function push(pri:DrawPrimitive):Void {
		
		if (onlysourceFlag) {
			if (onlysource != null && onlysource != pri.source) {
				onlysourceFlag = false;
			}
			onlysource = pri.source;
		}
		if (level < maxlevel) {
			if (pri.maxX <= xdiv) {
				if (pri.maxY <= ydiv) {
					if (lefttop == null) {
						lefttopFlag = true;
						lefttop = new PrimitiveQuadrantTreeNode();
					} else if (!lefttopFlag) {
						lefttopFlag = true;
						lefttop.reset(xdiv - halfwidth / 2, ydiv - halfheight / 2, halfwidth, halfheight);
					}
					lefttop.push(pri);
					return;
				} else if (pri.minY >= ydiv) {
					if (leftbottom == null) {
						leftbottomFlag = true;
						leftbottom = new PrimitiveQuadrantTreeNode();
					} else if (!leftbottomFlag) {
						leftbottomFlag = true;
						leftbottom.reset(xdiv - halfwidth / 2, ydiv + halfheight / 2, halfwidth, halfheight);
					}
					leftbottom.push(pri);
					return;
				}
			} else if (pri.minX >= xdiv) {
				if (pri.maxY <= ydiv) {
					if (righttop == null) {
						righttopFlag = true;
						righttop = new PrimitiveQuadrantTreeNode();
					} else if (!righttopFlag) {
						righttopFlag = true;
						righttop.reset(xdiv + halfwidth / 2, ydiv - halfheight / 2, halfwidth, halfheight);
					}
					righttop.push(pri);
					return;
				} else if (pri.minY >= ydiv) {
					if (rightbottom == null) {
						rightbottomFlag = true;
						rightbottom = new PrimitiveQuadrantTreeNode();
					} else if (!rightbottomFlag) {
						rightbottomFlag = true;
						rightbottom.reset(xdiv + halfwidth / 2, ydiv + halfheight / 2, halfwidth, halfheight);
					}
					rightbottom.push(pri);
					return;
				}
			}
		}
		//no quadrant, store in center array
		center.push(pri);
		pri.quadrant = this;
	}

	/**
	 * Clears the quadrant of all primitives and child nodes
	 */
	public function reset(xdiv:Float, ydiv:Float, width:Float, height:Float):Void {
		
		this.xdiv = xdiv;
		this.ydiv = ydiv;
		halfwidth = width / 2;
		halfheight = height / 2;
		lefttopFlag = false;
		leftbottomFlag = false;
		righttopFlag = false;
		rightbottomFlag = false;
		center = new Array<Dynamic>();
		onlysourceFlag = true;
		onlysource = null;
		render_center_length = -1;
		render_center_index = -1;
	}

	/**
	 * Sorts and renders the contents of the quadrant tree
	 */
	public function render(limit:Float):Void {
		
		if (render_center_length == -1) {
			render_center_length = center.length;
			if ((render_center_length > 0)) {
				if (render_center_length > 1) {
					center.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
				}
			}
			render_center_index = 0;
		}
		while (render_center_index < render_center_length) {
			var pri:DrawPrimitive = center[render_center_index];
			if (pri.screenZ < limit) {
				break;
			}
			render_other(pri.screenZ);
			pri.render();
			render_center_index++;
		}

		render_other(limit);
	}

}

