package away3d.blockers;

import away3d.core.utils.Init;
import away3d.core.project.ProjectorType;
import away3d.core.base.Object3D;
import away3d.core.base.Vertex;


/**
 * Convex hull blocking all drawing primitives underneath.
 */
class ConvexBlock extends Object3D  {
	
	/**
	 * Toggles debug mode: blocker is visualised in the scene.
	 */
	public var debug:Bool;
	/**
	 * Verticies to use for calculating the convex hull.
	 */
	public var vertices:Array<Vertex>;
	

	/**
	 * Creates a new <code>ConvexBlock</code> object.
	 * 
	 * @param	verticies				An Array of vertices to use for calculating the convex hull.
	 * @param	init		[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(vertices:Array<Vertex>, ?init:Dynamic=null) {
		this.vertices = [];
		
		
		super(init);
		this.vertices = vertices;
		debug = ini.getBoolean("debug", false);
		projectorType = ProjectorType.CONVEX_BLOCK;
	}

}

