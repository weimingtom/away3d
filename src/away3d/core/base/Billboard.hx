package away3d.core.base;

import away3d.haxeutils.Error;
import flash.events.Event;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import away3d.events.SegmentEvent;
import away3d.core.utils.Debug;
import away3d.materials.IBillboardMaterial;
import away3d.events.BillboardEvent;


/**
 * Dispatched when the material of the billboard changes.
 * 
 * @eventType away3d.events.FaceEvent
 */
// [Event(name="materialchanged", type="away3d.events.BillboardEvent")]

// use namespace arcane;

/**
 * A graphics element used to represent objects that always face the camera
 * 
 * @see away3d.core.base.Mesh
 */
class Billboard extends Element  {
	public var vertex(getVertex, setVertex) : Vertex;
	public var x(getX, setX) : Float;
	public var y(getY, setY) : Float;
	public var z(getZ, setZ) : Float;
	public var material(getMaterial, setMaterial) : IBillboardMaterial;
	public var width(getWidth, setWidth) : Float;
	public var height(getHeight, setHeight) : Float;
	public var scaling(getScaling, setScaling) : Float;
	public var rotation(getRotation, setRotation) : Float;
	
	/** @private */
	public var _vertex:Vertex;
	/** @private */
	public var _material:IBillboardMaterial;
	private var _materialchanged:BillboardEvent;
	private var _width:Float;
	private var _height:Float;
	private var _scaling:Float;
	private var _rotation:Float;
	

	/** @private */
	public function notifyMaterialChange():Void {
		
		if (!hasEventListener(BillboardEvent.MATERIAL_CHANGED)) {
			return;
		}
		if (_materialchanged == null) {
			_materialchanged = new BillboardEvent(BillboardEvent.MATERIAL_CHANGED, this);
		}
		dispatchEvent(_materialchanged);
	}

	private function onVertexValueChange(event:Event):Void {
		
		notifyVertexValueChange();
	}

	/**
	 * Returns an array of vertex objects that are used by the segment.
	 */
	public override function getVertices():Array<Vertex> {
		
		return [_vertex];
	}

	/**
	 * Defines the vertex of the billboard.
	 */
	public function getVertex():Vertex {
		
		return _vertex;
	}

	public function setVertex(value:Vertex):Vertex {
		
		if (value == _vertex) {
			return value;
		}
		if (_vertex != null) {
			_vertex.removeOnChange(onVertexValueChange);
		}
		_vertex = value;
		if (_vertex != null) {
			_vertex.addOnChange(onVertexValueChange);
		}
		notifyVertexChange();
		return value;
	}

	/**
	 * Defines the x coordinate of the billboard relative to the local coordinates of the parent <code>Mesh</code>.
	 */
	public function getX():Float {
		
		return _vertex.x;
	}

	public function setX(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(x)");
		}
		if (_vertex.x == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("x == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("x == -Infinity");
		}
		_vertex.x = value;
		return value;
	}

	/**
	 * Defines the y coordinate of the billboard relative to the local coordinates of the parent <code>Mesh</code>.
	 */
	public function getY():Float {
		
		return _vertex.y;
	}

	public function setY(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(y)");
		}
		if (_vertex.y == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("y == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("y == -Infinity");
		}
		_vertex.y = value;
		return value;
	}

	/**
	 * Defines the z coordinate of the billboard relative to the local coordinates of the parent <code>Mesh</code>.
	 */
	public function getZ():Float {
		
		return _vertex.z;
	}

	public function setZ(value:Float):Float {
		
		if (Math.isNaN(value)) {
			throw new Error("isNaN(z)");
		}
		if (_vertex.z == value) {
			return value;
		}
		if (value == Math.POSITIVE_INFINITY) {
			Debug.warning("z == Infinity");
		}
		if (value == -Math.POSITIVE_INFINITY) {
			Debug.warning("z == -Infinity");
		}
		_vertex.z = value;
		return value;
	}

	/**
	 * Defines the material of the billboard.
	 */
	public function getMaterial():IBillboardMaterial {
		
		return _material;
	}

	public function setMaterial(value:IBillboardMaterial):IBillboardMaterial {
		
		if (_material == value) {
			return value;
		}
		_material = value;
		notifyMaterialChange();
		return value;
	}

	/**
	 * Defines the width of the billboard.
	 */
	public function getWidth():Float {
		
		return _width;
	}

	public function setWidth(value:Float):Float {
		
		if (_width == value) {
			return value;
		}
		_width = value;
		notifyMaterialChange();
		return value;
	}

	/**
	 * Defines the height of the billboard.
	 */
	public function getHeight():Float {
		
		return _width;
	}

	public function setHeight(value:Float):Float {
		
		if (_height == value) {
			return value;
		}
		_height = value;
		notifyMaterialChange();
		return value;
	}

	/**
	 * Defines the scaling of the billboard when an <code>IUVMaterial</code> is used.
	 */
	public function getScaling():Float {
		
		return _scaling;
	}

	public function setScaling(value:Float):Float {
		
		if (_scaling == value) {
			return value;
		}
		_scaling = value;
		notifyMaterialChange();
		return value;
	}

	/**
	 * Defines the rotation of the billboard.
	 */
	public function getRotation():Float {
		
		return _rotation;
	}

	public function setRotation(value:Float):Float {
		
		if (_rotation == value) {
			return value;
		}
		_rotation = value;
		notifyMaterialChange();
		return value;
	}

	/**
	 * Returns the squared bounding radius of the billboard.
	 */
	public override function getRadius2():Float {
		
		return 0;
	}

	/**
	 * Returns the maximum x value of the segment
	 * 
	 * @see		away3d.core.base.Vertex#x
	 */
	public override function getMaxX():Float {
		
		return _vertex._x;
	}

	/**
	 * Returns the minimum x value of the face
	 * 
	 * @see		away3d.core.base.Vertex#x
	 */
	public override function getMinX():Float {
		
		return _vertex._x;
	}

	/**
	 * Returns the maximum y value of the segment
	 * 
	 * @see		away3d.core.base.Vertex#y
	 */
	public override function getMaxY():Float {
		
		return _vertex._y;
	}

	/**
	 * Returns the minimum y value of the face
	 * 
	 * @see		away3d.core.base.Vertex#y
	 */
	public override function getMinY():Float {
		
		return _vertex._y;
	}

	/**
	 * Returns the maximum z value of the segment
	 * 
	 * @see		away3d.core.base.Vertex#z
	 */
	public override function getMaxZ():Float {
		
		return _vertex._z;
	}

	/**
	 * Returns the minimum y value of the face
	 * 
	 * @see		away3d.core.base.Vertex#y
	 */
	public override function getMinZ():Float {
		
		return _vertex._z;
	}

	/**
	 * Creates a new <code>Billboard</code> object.
	 *
	 * @param	vertex					The vertex object of the billboard
	 * @param	material	[optional]	The material used by the billboard to render
	 */
	public function new(vertex:Vertex, ?material:IBillboardMaterial=null, ?width:Float=10, ?height:Float=10) {
		// autogenerated
		super();
		this._scaling = 1;
		this._rotation = 0;
		
		
		this.vertex = vertex;
		this.material = material;
		this.width = width;
		this.height = height;
		vertexDirty = true;
	}

	/**
	 * Default method for adding a materialchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMaterialChange(listener:Dynamic):Void {
		
		addEventListener(SegmentEvent.MATERIAL_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a materialchanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMaterialChange(listener:Dynamic):Void {
		
		removeEventListener(SegmentEvent.MATERIAL_CHANGED, listener, false);
	}

}

