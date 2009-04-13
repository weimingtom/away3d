package away3d.animators.data;

import away3d.core.base.Vertex;

/**
 * Holds information about a key frame in an animation: vertices and frame name.
 */
class AnimationKeyFrameData  {
	
	public var vertices(getVertices, null):Array<Vertex>;
	public var prefix(getPrefix, setPrefix):String;
	
	private var _vertices:Array<Vertex>;
	private var _prefix:String;
	

	/**
	 * Creates a new <code>AnimationKeyFrameData</code> object.
	 * 
	 * @param	vertices	An array of mesh vertices.
	 * @param	prefix		The prefix of the key frame name.
	 */
	public function new(vertices:Array<Vertex>, prefix:String) {
		_vertices = vertices;
		_prefix = prefix;
	}


	/**
	 * Returns the array of vertices
	 */
	private function getVertices():Array<Vertex> {
		return _vertices;
	}

	/**
	 * Returns the prefix of the key frame
	 */
	private function getPrefix():String {
		return _prefix;
	}
	
	/**
	 * Sets a new prefix
	 */
	private function setPrefix(prefix:String):String {
		_prefix = prefix;
		return prefix;
	}

}

