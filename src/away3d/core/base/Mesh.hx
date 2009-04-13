package away3d.core.base;

import away3d.haxeutils.HashMap;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import flash.events.EventDispatcher;
import away3d.animators.data.AnimationSequence;
import away3d.materials.ITriangleMaterial;
import away3d.containers.View3D;
import away3d.materials.ISegmentMaterial;
import flash.events.Event;
import away3d.materials.WireframeMaterial;
import away3d.events.MaterialEvent;
import away3d.materials.ColorMaterial;
import away3d.core.utils.Init;
import away3d.events.GeometryEvent;
import away3d.core.project.ProjectorType;
import flash.display.Sprite;
import away3d.materials.IBillboardMaterial;
import away3d.materials.IUVMaterial;
import away3d.core.math.Number3D;
import away3d.materials.WireColorMaterial;
import away3d.core.math.Matrix3D;
import away3d.events.FaceEvent;


/**
 * Dispatched when a sequence of animations completes.
 * 
 * @eventType away3d.events.AnimationEvent
 */
// [Event(name="sequenceDone", type="away3d.events.AnimationEvent")]

/**
 * Dispatched when a single animation in a sequence completes.
 * 
 * @eventType away3d.events.AnimationEvent
 */
// [Event(name="cycle", type="away3d.events.AnimationEvent")]

// use namespace arcane;

/**
 * 3d object containing face and segment elements 
 */
class Mesh extends Object3D  {
	public var vertices(getVertices, null) : Array<Vertex>;
	public var faces(getFaces, null) : Array<Face>;
	public var segments(getSegments, null) : Array<Segment>;
	public var billboards(getBillboards, null) : Array<Billboard>;
	public var elements(getElements, null) : Array<Element>;
	public var geometry(getGeometry, setGeometry) : Geometry;
	public var material(getMaterial, setMaterial) : IMaterial;
	public var back(getBack, setBack) : ITriangleMaterial;
	public var faceMaterial(getFaceMaterial, setFaceMaterial) : ITriangleMaterial;
	public var segmentMaterial(getSegmentMaterial, setSegmentMaterial) : ISegmentMaterial;
	public var billboardMaterial(getBillboardMaterial, setBillboardMaterial) : IBillboardMaterial;
	public var activePrefix(getActivePrefix, null) : String;
	public var frame(getFrame, setFrame) : Int;
	public var hasCycleEvent(getHasCycleEvent, null) : Bool;
	public var hasSequenceEvent(getHasSequenceEvent, null) : Bool;
	public var fps(null, setFps) : Int;
	public var loop(null, setLoop) : Bool;
	public var smooth(null, setSmooth) : Bool;
	public var isRunning(getIsRunning, null) : Bool;
	public var transitionValue(getTransitionValue, setTransitionValue) : Float;
	
	private var _geometry:Geometry;
	private var _material:IMaterial;
	private var _uvMaterial:IUVMaterial;
	private var _faceMaterial:ITriangleMaterial;
	private var _back:ITriangleMaterial;
	private var _segmentMaterial:ISegmentMaterial;
	private var _billboardMaterial:IBillboardMaterial;
	private var _scenevertnormalsDirty:Bool;
	private var _face:Face;
	//TODO: create effective dispose mechanism for meshs
	/*
	 private function clear():void
	 {
	 for each (var face:Face in _faces.concat([]))
	 removeFace(face);
	 }
	 */
	/**
	 * String defining the source of the mesh.
	 * 
	 * If the mesh has been created internally, the string is used to display the package name of the creating object.
	 * Used to display information in the stats panel
	 * 
	 * @see away3d.core.stats.Stats
	 */
	public var url:String;
	/**
	 * String defining the type of class used to generate the mesh.
	 * Used to display information in the stats panel
	 * 
	 * @see away3d.core.stats.Stats
	 */
	public var type:String;
	/**
	 * Defines a segment material to be used for outlining the 3d object.
	 */
	public var outline:ISegmentMaterial;
	/**
	 * Indicates whether both the front and reverse sides of a face should be rendered.
	 */
	public var bothsides:Bool;
	/**
	 * Placeholder for md2 frame indexes
	 */
	public var indexes:Array<Int>;
	

	private function onMaterialUpdate(event:MaterialEvent):Void {
		
		_sessionDirty = true;
		//cancel session update for moviematerials
		//if (event.material is MovieMaterial && _scene)
		//	delete _scene.updatedSessions[_session];
		
	}

	private function onFaceMappingChange(event:FaceEvent):Void {
		
		_sessionDirty = true;
		if (event.face.material != null) {
			_uvMaterial = cast(event.face.material, IUVMaterial);
		} else {
			_uvMaterial = cast(_faceMaterial, IUVMaterial);
		}
		if ((_uvMaterial != null)) {
			_uvMaterial.getFaceMaterialVO(event.face.faceVO, this).invalidated = true;
		}
	}

	private function onDimensionsChange(event:GeometryEvent):Void {
		
		_sessionDirty = true;
		notifyDimensionsChange();
	}

	private function removeMaterial(mat:IMaterial):Void {
		
		if (mat == null) {
			return;
		}
		//remove update listener
		mat.removeOnMaterialUpdate(onMaterialUpdate);
	}

	private function addMaterial(mat:IMaterial):Void {
		
		if (mat == null) {
			return;
		}
		//add update listener
		mat.addOnMaterialUpdate(onMaterialUpdate);
	}

	private function getDefaultMaterial():IMaterial {
		
		return (ini.getMaterial("material") != null) ? ini.getMaterial("material") : new WireColorMaterial();
	}

	private override function updateDimensions():Void {
		//update bounding radius
		
		var vertices:Array<Vertex> = geometry.vertices.concat([]);
		if ((vertices.length > 0)) {
			if (_scaleX < 0) {
				_boundingScale = -_scaleX;
			} else {
				_boundingScale = _scaleX;
			}
			if (_scaleY < 0 && _boundingScale < -_scaleY) {
				_boundingScale = -_scaleY;
			} else if (_boundingScale < _scaleY) {
				_boundingScale = _scaleY;
			}
			if (_scaleZ < 0 && _boundingScale < -_scaleZ) {
				_boundingScale = -_scaleZ;
			} else if (_boundingScale < _scaleZ) {
				_boundingScale = _scaleZ;
			}
			var mradius:Float = 0;
			var vradius:Float;
			var num:Number3D = new Number3D();
			for (__i in 0...vertices.length) {
				var vertex:Vertex = vertices[__i];

				if (vertex != null) {
					num.sub(vertex.position, _pivotPoint);
					vradius = num.modulo2;
					if (mradius < vradius) {
						mradius = vradius;
					}
				}
			}

			if ((mradius > 0)) {
				_boundingRadius = Math.sqrt(mradius);
			} else {
				_boundingRadius = 0;
			}
			//update max/min X
			untyped vertices.sortOn("x", Array.DESCENDING | Array.NUMERIC);
			_maxX = vertices[0].x;
			_minX = vertices[vertices.length - 1].x;
			//update max/min Y
			untyped vertices.sortOn("y", Array.DESCENDING | Array.NUMERIC);
			_maxY = vertices[0].y;
			_minY = vertices[vertices.length - 1].y;
			//update max/min Z
			untyped vertices.sortOn("z", Array.DESCENDING | Array.NUMERIC);
			_maxZ = vertices[0].z;
			_minZ = vertices[vertices.length - 1].z;
		}
		super.updateDimensions();
	}

	/**
	 * Returns an array of the vertices contained in the mesh object.
	 */
	public function getVertices():Array<Vertex> {
		
		return _geometry.vertices;
	}

	/**
	 * Returns an array of the faces contained in the mesh object.
	 */
	public function getFaces():Array<Face> {
		
		return _geometry.faces;
	}

	/**
	 * Returns an array of the segments contained in the mesh object.
	 */
	public function getSegments():Array<Segment> {
		
		return _geometry.segments;
	}

	/**
	 * Returns an array of the billboards contained in the mesh object.
	 */
	public function getBillboards():Array<Billboard> {
		
		return _geometry.billboards;
	}

	/**
	 * Returns an array of all elements contained in the mesh object.
	 */
	public function getElements():Array<Element> {
		
		return _geometry.elements;
	}

	/**
	 * Defines the geometry object used for the mesh.
	 */
	public function getGeometry():Geometry {
		
		return _geometry;
	}

	public function setGeometry(val:Geometry):Geometry {
		
		if (_geometry == val) {
			return val;
		}
		if (_geometry != null) {
			_geometry.removeOnMaterialUpdate(onMaterialUpdate);
			_geometry.removeOnMappingChange(onFaceMappingChange);
			_geometry.removeOnDimensionsChange(onDimensionsChange);
		}
		_geometry = val;
		if (_geometry != null) {
			_geometry.addOnMaterialUpdate(onMaterialUpdate);
			_geometry.addOnMappingChange(onFaceMappingChange);
			_geometry.addOnDimensionsChange(onDimensionsChange);
		}
		return val;
	}

	/**
	 * Defines the material used to render the faces, segments or billboards in the geometry object.
	 * Individual material settings on faces, segments and billboards will override this setting.
	 * 
	 * @see away3d.core.base.Face#material
	 */
	public function getMaterial():IMaterial {
		
		return _material;
	}

	public function setMaterial(val:IMaterial):IMaterial {
		
		if (_material == val && _material != null) {
			return val;
		}
		removeMaterial(_material);
		//set material value
		addMaterial(_material = val);
		if (Std.is(_material, ITriangleMaterial)) {
			_faceMaterial = cast(_material, ITriangleMaterial);
		} else {
			faceMaterial = new WireColorMaterial();
		}
		if (Std.is(_material, ISegmentMaterial)) {
			_segmentMaterial = cast(_material, ISegmentMaterial);
		} else {
			segmentMaterial = new WireframeMaterial();
		}
		if (Std.is(_material, IBillboardMaterial)) {
			_billboardMaterial = cast(_material, IBillboardMaterial);
		} else {
			billboardMaterial = new ColorMaterial();
		}
		_sessionDirty = true;
		return val;
	}

	/**
	 * Defines a triangle material to be used for the backface of all faces in the 3d object.
	 */
	public function getBack():ITriangleMaterial {
		
		return _back;
	}

	public function setBack(val:ITriangleMaterial):ITriangleMaterial {
		
		if (_back == val) {
			return val;
		}
		removeMaterial(_back);
		//set back value
		addMaterial(_back = val);
		return val;
	}

	public function getFaceMaterial():ITriangleMaterial {
		
		return _faceMaterial;
	}

	public function setFaceMaterial(val:ITriangleMaterial):ITriangleMaterial {
		
		if (_faceMaterial == val) {
			return val;
		}
		removeMaterial(_faceMaterial);
		//set material value
		addMaterial(_faceMaterial = val);
		return val;
	}

	public function getSegmentMaterial():ISegmentMaterial {
		
		return _segmentMaterial;
	}

	public function setSegmentMaterial(val:ISegmentMaterial):ISegmentMaterial {
		
		if (_segmentMaterial == val) {
			return val;
		}
		removeMaterial(_segmentMaterial);
		//set material value
		addMaterial(_segmentMaterial = val);
		return val;
	}

	public function getBillboardMaterial():IBillboardMaterial {
		
		return _billboardMaterial;
	}

	public function setBillboardMaterial(val:IBillboardMaterial):IBillboardMaterial {
		
		if (_billboardMaterial == val) {
			return val;
		}
		removeMaterial(_billboardMaterial);
		//set material value
		addMaterial(_billboardMaterial = val);
		return val;
	}

	/**
	 * return the prefix of the animation actually started.
	 * 
	 */
	public function getActivePrefix():String {
		
		return geometry.activePrefix;
	}

	/**
	 * Indicates the current frame of animation
	 */
	public function getFrame():Int {
		
		return geometry.frame;
	}

	public function setFrame(value:Int):Int {
		
		geometry.frame = value;
		return value;
	}

	/**
	 * Indicates whether the animation has a cycle event listener
	 */
	public function getHasCycleEvent():Bool {
		
		return geometry.hasCycleEvent;
	}

	/**
	 * Indicates whether the animation has a sequencedone event listener
	 */
	public function getHasSequenceEvent():Bool {
		
		return geometry.hasSequenceEvent;
	}

	/**
	 * Determines the frames per second at which the animation will run.
	 */
	public function setFps(fps:Int):Int {
		
		geometry.fps = fps;
		return fps;
	}

	/**
	 * Determines whether the animation will loop.
	 */
	public function setLoop(loop:Bool):Bool {
		
		geometry.loop = loop;
		return loop;
	}

	/**
	 * Determines whether the animation will smooth motion (interpolate) between frames.
	 */
	public function setSmooth(smooth:Bool):Bool {
		
		geometry.smooth = smooth;
		return smooth;
	}

	/**
	 * Indicates whether the animation is currently running.
	 */
	public function getIsRunning():Bool {
		
		return geometry.isRunning;
	}

	/**
	 * Determines howmany frames a transition between the actual and the next animationSequence should interpolate together.
	 * must be higher or equal to 1. Default = 10;
	 */
	public function setTransitionValue(val:Float):Float {
		
		geometry.transitionValue = val;
		return val;
	}

	public function getTransitionValue():Float {
		
		return geometry.transitionValue;
	}

	/**
	 * Creates a new <code>BaseMesh</code> object.
	 *
	 * @param	init			[optional]	An initialisation object for specifying default instance properties.
	 */
	public function new(?init:Dynamic=null) {
		this._scenevertnormalsDirty = true;
		this.type = "mesh";
		
		
		super(init);
		geometry = new Geometry();
		outline = ini.getSegmentMaterial("outline");
		material = ini.getMaterial("material");
		if (ini.hasField("faceMaterial")) {
			faceMaterial = cast(ini.getMaterial("faceMaterial"), ITriangleMaterial);
		}
		if (faceMaterial == null)  {
			faceMaterial = _faceMaterial;
		};
		if (ini.hasField("segmentMaterial")) {
			segmentMaterial = cast(ini.getMaterial("segmentMaterial"), ISegmentMaterial);
		}
		if (segmentMaterial == null)  {
			segmentMaterial = _segmentMaterial;
		};
		if (ini.hasField("billboardMaterial")) {
			billboardMaterial = cast(ini.getMaterial("billboardMaterial"), IBillboardMaterial);
		}
		if (billboardMaterial == null)  {
			billboardMaterial = _billboardMaterial;
		};
		if (ini.hasField("back")) {
			back = cast(ini.getMaterial("back"), ITriangleMaterial);
		}
		bothsides = ini.getBoolean("bothsides", false);
		projectorType = ProjectorType.MESH;
	}

	/**
	 * Adds a face object to the mesh object.
	 * 
	 * @param	face	The face object to be added.
	 */
	public function addFace(face:Face):Void {
		
		_geometry.addFace(face);
	}

	/**
	 * Removes a face object from the mesh object.
	 * 
	 * @param	face	The face object to be removed.
	 */
	public function removeFace(face:Face):Void {
		
		_geometry.removeFace(face);
	}

	/**
	 * Adds a segment object to the mesh object.
	 * 
	 * @param	segment	The segment object to be added.
	 */
	public function addSegment(segment:Segment):Void {
		
		_geometry.addSegment(segment);
	}

	/**
	 * Removes a segment object from the mesh object.
	 * 
	 * @param	segment	The segment object to be removed.
	 */
	public function removeSegment(segment:Segment):Void {
		
		_geometry.removeSegment(segment);
	}

	/**
	 * Adds a billboard object to the mesh object.
	 * 
	 * @param	billboard	The billboard object to be added.
	 */
	public function addBillboard(billboard:Billboard):Void {
		
		_geometry.addBillboard(billboard);
	}

	/**
	 * Removes a billboard object from the mesh object.
	 * 
	 * @param	billboard	The billboard object to be removed.
	 */
	public function removeBillboard(billboard:Billboard):Void {
		
		_geometry.removeBillboard(billboard);
	}

	/**
	 * Inverts the geometry of all face objects.
	 * 
	 * @see away3d.code.base.Face#invert()
	 */
	public function invertFaces():Void {
		
		_geometry.invertFaces();
	}

	/**
	 * Divides all faces objects of a Mesh into 4 equal sized face objects.
	 * Used to segment a geometry in order to reduce affine persepective distortion.
	 * 
	 * @see away3d.primitives.SkyBox
	 */
	public function quarterFaces():Void {
		
		_geometry.quarterFaces();
	}

	/**
	 * Divides a face object into 4 equal sized face objects.
	 * 
	 * @param	face	The face to split in 4 equal faces.
	 */
	public function quarterFace(face:Face):Void {
		
		_geometry.quarterFace(face);
	}

	/**
	 * Divides all faces objects of a Mesh into 3 face objects.
	 * 
	 */
	public function triFaces():Void {
		
		_geometry.triFaces();
	}

	/**
	 * Divides a face object into 3 face objects.
	 * 
	 * @param	face	The face to split 3 faces.
	 */
	public function triFace(face:Face):Void {
		
		_geometry.triFace(face);
	}

	/**
	 * Divides all faces objects of a Mesh into 2 face objects.
	 * 
	 * @param	side	The side of the faces to split in two. 0 , 1 or 2. (clockwize).
	 */
	public function splitFaces(?side:Int=0):Void {
		
		_geometry.splitFaces(side);
	}

	/**
	 * Divides a face object into 2 face objects.
	 * 
	 * @param	face	The face to split in 2 faces.
	 * @param	side	The side of the face to split in two. 0 , 1 or 2. (clockwize).
	 */
	public function splitFace(face:Face, ?side:Int=0):Void {
		
		_geometry.splitFace(face, side);
	}

	/**
	 * Updates the materials in the mesh object
	 */
	public function updateMaterials(source:Object3D, view:View3D):Void {
		
		if ((_material != null)) {
			_material.updateMaterial(source, view);
		}
		if ((back != null)) {
			back.updateMaterial(source, view);
		}
	}

	/**
	 * Duplicates the mesh properties to another 3d object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Mesh</code>.
	 * @return						The new object instance with duplicated properties applied.
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var mesh:Mesh = (cast(object, Mesh));
		if (mesh == null)  {
			mesh = new Mesh();
		};
		super.clone(mesh);
		mesh.type = type;
		mesh.material = material;
		mesh.outline = outline;
		mesh.back = back;
		mesh.bothsides = bothsides;
		mesh.debugbb = debugbb;
		mesh.geometry = geometry;
		return mesh;
	}

	/**
	 * Duplicates the mesh properties to another 3d object, including geometry
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied. The default is <code>Mesh</code>.
	 * @return						The new object instance with duplicated properties applied.
	 */
	public function cloneAll(?object:Object3D=null):Object3D {
		
		var mesh:Mesh = (cast(object, Mesh));
		if (mesh == null)  {
			mesh = new Mesh();
		};
		super.clone(mesh);
		mesh.type = type;
		mesh.material = material;
		mesh.outline = outline;
		mesh.back = back;
		mesh.bothsides = bothsides;
		mesh.debugbb = debugbb;
		mesh.geometry = geometry.clone();
		return mesh;
	}

	/**
	 * Plays a sequence of frames
	 * 
	 * @param	sequence	The animationsequence to play
	 */
	public function play(sequence:AnimationSequence):Void {
		
		geometry.play(sequence);
	}

	/**
	 * Starts playing the animation at the specified frame.
	 * 
	 * @param	value		A number representing the frame number.
	 */
	public function gotoAndPlay(value:Int):Void {
		
		geometry.gotoAndPlay(value);
	}

	/**
	 * Brings the animation to the specifed frame and stops it there.
	 * 
	 * @param	value		A number representing the frame number.
	 */
	public function gotoAndStop(value:Int):Void {
		
		geometry.gotoAndStop(value);
	}

	/**
	 * Plays a sequence of frames. 
	 * Note that the framenames must be be already existing in the system before you can use this handler
	 *
	 * @param	prefixes  	Array. The list of framenames to be played
	 * @param	fps			uint: frames per second
	 * @param	smooth		[optional] Boolean. if the animation must interpolate. Default = true.
	 * @param	loop			[optional] Boolean. if the animation must loop. Default = false.
	 */
	public function playFrames(prefixes:Array<String>, fps:Int, ?smooth:Bool=true, ?loop:Bool=false):Void {
		
		geometry.playFrames(prefixes, fps, smooth, loop);
	}

	/**
	 * Passes an array of animationsequence objects to be added to the animation.
	 * 
	 * @param	playlist				An array of animationsequence objects.
	 * @param	loopLast	[optional]	Determines whether the last sequence will loop. Defaults to false.
	 */
	public function setPlaySequences(playlist:Array<AnimationSequence>, ?loopLast:Bool=false):Void {
		
		geometry.setPlaySequences(playlist, loopLast);
	}

	/**
	 * Default method for adding a sequenceDone event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSequenceDone(listener:Dynamic):Void {
		
		geometry.addOnSequenceDone(listener);
	}

	/**
	 * Default method for removing a sequenceDone event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSequenceDone(listener:Dynamic):Void {
		
		geometry.removeOnSequenceDone(listener);
	}

	/**
	 * Default method for adding a cycle event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnCycle(listener:Dynamic):Void {
		
		geometry.addOnCycle(listener);
	}

	/**
	 * Default method for removing a cycle event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnCycle(listener:Dynamic):Void {
		
		geometry.removeOnCycle(listener);
	}


	/**
	 * Returns an xml representation of the mesh
	 * 
	 * @return	An xml object containing mesh information
	 */
	public function asXML():Xml {
		
		var result:Xml = Xml.parse("<mesh></mesh>");
		var refvertices:HashMap<Vertex, Int> = new HashMap<Vertex, Int>();
		var verticeslist:Array<Vertex> = [];
		var remembervertex = function (vertex:Vertex):Void {
			
			if (!refvertices.contains(vertex)) {
				refvertices.put(vertex, verticeslist.length);
				verticeslist.push(vertex);
			}
		};
		var refuvs:HashMap<UV, Int> = new HashMap<UV, Int>();
		var uvslist:Array<UV> = [];
		var rememberuv = function (uv:UV):Void {
			
			if (uv == null) {
				return;
			}
			if (!refuvs.contains(uv)) {
				refuvs.put(uv, uvslist.length);
				uvslist.push(uv);
			}
		};
		for (__i in 0..._geometry.faces.length) {
			var face:Face = _geometry.faces[__i];

			if (face != null) {
				remembervertex(face._v0);
				remembervertex(face._v1);
				remembervertex(face._v2);
				rememberuv(face._uv0);
				rememberuv(face._uv1);
				rememberuv(face._uv2);
			}
		}

		var vn:Int = 0;
		for (__i in 0...verticeslist.length) {
			var v:Vertex = verticeslist[__i];

			if (v != null) {
				result.addChild(Xml.parse("<vertex id={vn} x={v._x} y={v._y} z={v._z}/>"));
				vn++;
			}
		}

		var uvn:Int = 0;
		for (__i in 0...uvslist.length) {
			var uv:UV = uvslist[__i];

			if (uv != null) {
				result.addChild(Xml.parse("<uv id={uvn} u={uv._u} v={uv._v}/>"));
				uvn++;
			}
		}

		for (__i in 0..._geometry.faces.length) {
			var f:Face = _geometry.faces[__i];

			if (f != null) {
				result.addChild(Xml.parse("<face v0={refvertices.get(f._v0)} v1={refvertices.get(f._v1)} v2={refvertices.get(f._v2)} uv0={refuvs.get(f._uv0)} uv1={refuvs.get(f._uv1)} uv2={refuvs.get(f._uv2)}/>"));
			}
		}

		return result;
	}

	/**
	 * update vertex information.
	 * 
	 * @param		v						The vertex object to update
	 * @param		x						The new x value for the vertex
	 * @param		y						The new y value for the vertex
	 * @param		z						The new z value for the vertex
	 * @param		refreshNormals	[optional]	Defines whether normals should be recalculated
	 * 
	 */
	public function updateVertex(v:Vertex, x:Float, y:Float, z:Float, ?refreshNormals:Bool=false):Void {
		
		_geometry.updateVertex(v, x, y, z, refreshNormals);
	}

	/**
	 * Apply the local rotations to the geometry without altering the appearance of the mesh
	 */
	public override function applyRotations():Void {
		
		_geometry.applyRotations(rotationX, rotationY, rotationZ);
		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
	}

	/**
	 * Apply the given position to the geometry without altering the appearance of the mesh
	 */
	public override function applyPosition(dx:Float, dy:Float, dz:Float):Void {
		
		_geometry.applyPosition(dx, dy, dz);
		var dV:Number3D = new Number3D(dx, dy, dz);
		dV.rotate(dV, _transform);
		dV.add(dV, position);
		moveTo(dV.x, dV.y, dV.z);
	}

}

