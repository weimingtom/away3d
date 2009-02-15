package away3d.primitives;

import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import away3d.core.base.Segment;
import away3d.materials.ISegmentMaterial;
import away3d.materials.WireframeMaterial;
import away3d.core.base.Mesh;
import away3d.core.utils.Init;
import away3d.core.base.Vertex;
import away3d.core.base.Element;


// use namespace arcane;

/**
 * Abstract base class for wire primitives
 */
class AbstractWirePrimitive extends Mesh  {
	
	/** @private */
	public var _v:Vertex;
	/** @private */
	public var _vStore:Array<Dynamic>;
	/** @private */
	public var _vActive:Array<Dynamic>;
	/** @private */
	public var _segment:Segment;
	/** @private */
	public var _segmentStore:Array<Dynamic>;
	/** @private */
	public var _segmentActive:Array<Dynamic>;
	/** @private */
	public var _primitiveDirty:Bool;
	private var _index:Int;
	

	/** @private */
	public function createVertex(?x:Float=0, ?y:Float=0, ?z:Float=0):Vertex {
		
		if ((_vStore.length > 0)) {
			_vActive.push(_v = _vStore.pop());
			_v._x = x;
			_v._y = y;
			_v._z = z;
		} else {
			_vActive.push(_v = new Vertex());
		}
		return _v;
	}

	/** @private */
	public function createSegment(v0:Vertex, v1:Vertex, ?material:ISegmentMaterial=null):Segment {
		
		if ((_segmentStore.length > 0)) {
			_segmentActive.push(_segment = _segmentStore.pop());
			_segment.v0 = v0;
			_segment.v1 = v1;
			_segment.material = material;
		} else {
			_segmentActive.push(_segment = new Segment());
		}
		return _segment;
	}

	private override function getDefaultMaterial():IMaterial {
		
		return (ini.getSegmentMaterial("material") != null) ? ini.getSegmentMaterial("material") : new WireframeMaterial();
	}

	/**
	 * Creates a new <code>AbstractPrimitive</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties
	 */
	public function new(?init:Dynamic=null) {
		this._vStore = new Array<Dynamic>();
		this._vActive = new Array<Dynamic>();
		this._segmentStore = new Array<Dynamic>();
		this._segmentActive = new Array<Dynamic>();
		
		
		super(init);
	}

	public override function updateObject():Void {
		
		if (_primitiveDirty) {
			buildPrimitive();
		}
		super.updateObject();
	}

	/**
	 * Builds the vertex, face and uv objects that make up the 3d primitive.
	 */
	public function buildPrimitive():Void {
		
		_primitiveDirty = false;
		//remove all elements from the mesh
		_index = segments.length;
		while ((_index-- > 0)) {
			removeSegment(segments[_index]);
		}

		//clear vertex objects
		_vStore = _vStore.concat(_vActive);
		_vActive = new Array<Dynamic>();
		//clear segment objects
		_segmentStore = _segmentStore.concat(_segmentActive);
		_segmentActive = new Array<Dynamic>();
	}

}

