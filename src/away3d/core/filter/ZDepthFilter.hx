package away3d.core.filter;

import away3d.containers.Scene3D;
import away3d.cameras.Camera3D;
import away3d.core.clip.Clipping;
import away3d.core.draw.DrawPrimitive;


/**
 * Defines a maximum z value for rendering primitives
 */
class ZDepthFilter implements IPrimitiveFilter {
	
	private var _primitives:Array<DrawPrimitive>;
	private var pri:DrawPrimitive;
	private var _maxZ:Float;
	

	function new(maxZ:Float) {
		
		
		_maxZ = maxZ;
	}

	/**
	 * @inheritDoc
	 */
	public function filter(primitives:Array<DrawPrimitive>, scene:Scene3D, camera:Camera3D, clip:Clipping):Array<DrawPrimitive> {
		
		_primitives = [];
		for (__i in 0...primitives.length) {
			pri = primitives[__i];

			if (pri != null) {
				if (pri.screenZ < _maxZ) {
					_primitives.push(pri);
				}
			}
		}

		return _primitives;
	}

	/**
	 * Used to trace the values of a filter.
	 * 
	 * @return A string representation of the filter object.
	 */
	public function toString():String {
		
		return "ZDepthFilter";
	}

}

