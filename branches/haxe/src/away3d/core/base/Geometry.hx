package away3d.core.base;

import away3d.loaders.data.MaterialData;
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import away3d.core.utils.ValueObject;
import away3d.materials.IMaterial;
import away3d.animators.skin.Bone;
import away3d.animators.data.AnimationSequence;
import away3d.materials.ITriangleMaterial;
import away3d.containers.View3D;
import flash.events.Event;
import away3d.events.MaterialEvent;
import away3d.animators.data.AnimationGroup;
import away3d.animators.data.AnimationFrame;
import away3d.core.utils.IClonable;
import away3d.events.AnimationEvent;
import away3d.animators.skin.SkinController;
import away3d.animators.skin.SkinVertex;
import away3d.core.utils.Init;
import away3d.events.GeometryEvent;
import flash.display.Sprite;
import away3d.core.math.Number3D;
import away3d.core.math.Matrix3D;
import away3d.events.ElementEvent;
import away3d.events.FaceEvent;


/**
 * Dispatched when the bounding dimensions of the geometry object change.
 * 
 * @eventType away3d.events.GeometryEvent
 */
// [Event(name="dimensionsChanged", type="away3d.events.GeometryEvent")]

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
class Geometry extends EventDispatcher  {
	public var faces(getFaces, null) : Array<Dynamic>;
	public var vertexDirty(getVertexDirty, null) : Bool;
	public var segments(getSegments, null) : Array<Dynamic>;
	public var billboards(getBillboards, null) : Array<Dynamic>;
	public var elements(getElements, null) : Array<Dynamic>;
	public var vertices(getVertices, null) : Array<Dynamic>;
	public var frame(getFrame, setFrame) : Int;
	public var hasCycleEvent(getHasCycleEvent, null) : Bool;
	public var hasSequenceEvent(getHasSequenceEvent, null) : Bool;
	public var fps(null, setFps) : Int;
	public var loop(null, setLoop) : Bool;
	public var transitionValue(getTransitionValue, setTransitionValue) : Float;
	public var smooth(null, setSmooth) : Bool;
	public var isRunning(getIsRunning, null) : Bool;
	public var activePrefix(getActivePrefix, null) : String;
	
	private var _renderTime:Int;
	private var _faces:Array<Dynamic>;
	private var _segments:Array<Dynamic>;
	private var _billboards:Array<Dynamic>;
	private var _vertices:Array<Dynamic>;
	private var _verticesDirty:Bool;
	private var _dispatchedDimensionsChange:Bool;
	private var _dimensionschanged:GeometryEvent;
	private var _neighboursDirty:Bool;
	private var _neighbour01:Dictionary;
	private var _neighbour12:Dictionary;
	private var _neighbour20:Dictionary;
	private var _vertfacesDirty:Bool;
	private var _vertfaces:Dictionary;
	private var _vertnormalsDirty:Bool;
	private var _vertnormals:Dictionary;
	private var _fNormal:Number3D;
	private var _fAngle:Float;
	private var _fVectors:Array<Dynamic>;
	private var _n01:Face;
	private var _n12:Face;
	private var _n20:Face;
	private var _vertex:Vertex;
	private var _skinVertex:SkinVertex;
	private var _skinController:SkinController;
	private var clonedvertices:Dictionary;
	private var clonedskinvertices:Dictionary;
	private var clonedskincontrollers:Dictionary;
	private var cloneduvs:Dictionary;
	private var _frame:Int;
	private var _animation:Animation;
	private var _animationgroup:AnimationGroup;
	private var _sequencedone:AnimationEvent;
	private var _cycle:AnimationEvent;
	private var _activeprefix:String;
	private var _materialData:MaterialData;
	private var _index:Int;
	/**
	 * Instance of the Init object used to hold and parse default property values
	 * specified by the initialiser object in the 3d object constructor.
	 */
	private var ini:Init;
	/**
	 * Reference to the root heirarchy of bone controllers for a skin.
	 */
	public var rootBone:Bone;
	/**
	 * Array of vertices used in a skin.
	 */
	public var skinVertices:Array<Dynamic>;
	/**
	 * Array of controller objects used to bind vertices with joints in a skin.
	 */
	public var skinControllers:Array<Dynamic>;
	/**
	 * A dictionary containing all frames of the geometry.
	 */
	public var frames:Dictionary;
	/**
	 * A dictionary containing all frame names of the geometry.
	 */
	public var framenames:Hash<Int>;
	
	/**
	 * An dictionary containing all the materials included in the geometry.
	 */
	public var materialDictionary:Dictionary;
	/**
	 * An dictionary containing associations between cloned elements.
	 */
	public var cloneElementDictionary:Dictionary;
	

	/** @private */
	public function getFacesByVertex(vertex:Vertex):Array<Dynamic> {
		
		if (_vertfacesDirty) {
			findVertFaces();
		}
		return _vertfaces[untyped vertex];
	}

	/** @private */
	public function getVertexNormal(vertex:Vertex):Number3D {
		
		if (_vertfacesDirty) {
			findVertFaces();
		}
		if (_vertnormalsDirty) {
			findVertNormals();
		}
		return _vertnormals[untyped vertex];
	}

	/** @private */
	public function neighbour01(face:Face):Face {
		
		if (_neighboursDirty) {
			findNeighbours();
		}
		return _neighbour01[untyped face];
	}

	/** @private */
	public function neighbour12(face:Face):Face {
		
		if (_neighboursDirty) {
			findNeighbours();
		}
		return _neighbour12[untyped face];
	}

	/** @private */
	public function neighbour20(face:Face):Face {
		
		if (_neighboursDirty) {
			findNeighbours();
		}
		return _neighbour20[untyped face];
	}

	/** @private */
	public function notifyDimensionsChange():Void {
		
		if (_dispatchedDimensionsChange || !hasEventListener(GeometryEvent.DIMENSIONS_CHANGED)) {
			return;
		}
		if (_dimensionschanged == null) {
			_dimensionschanged = new GeometryEvent(GeometryEvent.DIMENSIONS_CHANGED, this);
		}
		dispatchEvent(_dimensionschanged);
		_dispatchedDimensionsChange = true;
	}

	/** @private */
	public function addMaterial(element:Element, material:IMaterial):Void {
		//detect if materialData exists
		
		if ((_materialData = materialDictionary[untyped material]) == null) {
			_materialData = materialDictionary[untyped material] = new MaterialData();
			//set material property of materialData
			_materialData.material = material;
			//add update listener
			material.addOnMaterialUpdate(onMaterialUpdate);
		}
		//check if element is added to elements array
		if (untyped _materialData.elements.indexOf(element) == -1) {
			_materialData.elements.push(element);
		}
	}

	/** @private */
	public function removeMaterial(element:Element, material:IMaterial):Void {
		//detect if materialData exists
		
		if (((_materialData = materialDictionary[untyped material]) != null)) {
			if ((_index = untyped _materialData.elements.indexOf(element)) != -1) {
				_materialData.elements.splice(_index, 1);
			}
			//check if elements array is empty
			if (_materialData.elements.length == 0) {
				materialDictionary[untyped material] = null;
				//remove update listener
				material.removeOnMaterialUpdate(onMaterialUpdate);
			}
		}
	}

	private function addElement(element:Element):Void {
		
		_verticesDirty = true;
		element.addOnVertexChange(onElementVertexChange);
		element.addOnVertexValueChange(onElementVertexValueChange);
		element.parent = this;
		notifyDimensionsChange();
	}

	private function removeElement(element:Element):Void {
		
		_verticesDirty = true;
		element.removeOnVertexChange(onElementVertexChange);
		element.removeOnVertexValueChange(onElementVertexValueChange);
		notifyDimensionsChange();
	}

	private function findVertFaces():Void {
		
		_vertfaces = new Dictionary();
		for (__i in 0...faces.length) {
			var face:Face = faces[__i];

			if (face != null) {
				var v0:Vertex = face.v0;
				if (_vertfaces[untyped v0] == null) {
					_vertfaces[untyped v0] = [face];
				} else {
					_vertfaces[untyped v0].push(face);
				}
				var v1:Vertex = face.v1;
				if (_vertfaces[untyped v1] == null) {
					_vertfaces[untyped v1] = [face];
				} else {
					_vertfaces[untyped v1].push(face);
				}
				var v2:Vertex = face.v2;
				if (_vertfaces[untyped v2] == null) {
					_vertfaces[untyped v2] = [face];
				} else {
					_vertfaces[untyped v2].push(face);
				}
			}
		}

		_vertfacesDirty = false;
		_vertnormalsDirty = true;
	}

	private function findVertNormals():Void {
		
		_vertnormals = new Dictionary();
		for (__i in 0...vertices.length) {
			var v:Vertex = vertices[__i];

			if (v != null) {
				var vF:Array<Dynamic> = _vertfaces[untyped v];
				var nX:Float = 0;
				var nY:Float = 0;
				var nZ:Float = 0;
				for (__i in 0...vF.length) {
					var f:Face = vF[__i];

					if (f != null) {
						_fNormal = f.normal;
						_fVectors = new Array<Dynamic>();
						for (__i in 0...f.vertices.length) {
							var fV:Vertex = f.vertices[__i];

							if (fV != null) {
								if (fV != v) {
									_fVectors.push(new Number3D(fV.x - v.x, fV.y - v.y, fV.z - v.z, true));
								}
							}
						}

						_fAngle = Math.acos((cast(_fVectors[0], Number3D)).dot(cast(_fVectors[1], Number3D)));
						nX += _fNormal.x * _fAngle;
						nY += _fNormal.y * _fAngle;
						nZ += _fNormal.z * _fAngle;
					}
				}

				var vertNormal:Number3D = new Number3D(nX, nY, nZ);
				vertNormal.normalize();
				_vertnormals[untyped v] = vertNormal;
			}
		}

		_vertnormalsDirty = false;
	}

	private function onMaterialUpdate(event:MaterialEvent):Void {
		
		dispatchEvent(event);
	}

	private function onFaceMappingChange(event:FaceEvent):Void {
		
		dispatchEvent(event);
	}

	private function onElementVertexChange(event:ElementEvent):Void {
		
		_verticesDirty = true;
		if (Std.is(event.element, Face)) {
			(cast(event.element, Face)).normalDirty = true;
			_vertfacesDirty = true;
		}
		notifyDimensionsChange();
	}

	private function onElementVertexValueChange(event:ElementEvent):Void {
		
		if (Std.is(event.element, Face)) {
			(cast(event.element, Face)).normalDirty = true;
		}
		notifyDimensionsChange();
	}

	private function cloneFrame(frame:Frame):Frame {
		
		var result:Frame = new Frame();
		for (__i in 0...frame.vertexpositions.length) {
			var vertexPosition:VertexPosition = frame.vertexpositions[__i];

			if (vertexPosition != null) {
				result.vertexpositions.push(cloneVertexPosition(vertexPosition));
			}
		}

		return result;
	}

	private function cloneVertexPosition(vertexPosition:VertexPosition):VertexPosition {
		
		var result:VertexPosition = new VertexPosition(cloneVertex(vertexPosition.vertex));
		result.x = vertexPosition.x;
		result.y = vertexPosition.y;
		result.z = vertexPosition.z;
		return result;
	}

	private function cloneVertex(vertex:Vertex):Vertex {
		
		var result:Vertex = clonedvertices[untyped vertex];
		if (result == null) {
			result = vertex.clone();
			result.extra = (Std.is(vertex.extra, IClonable)) ? (cast(vertex.extra, IClonable)).clone() : vertex.extra;
			clonedvertices[untyped vertex] = result;
		}
		return result;
	}

	private function cloneSkinVertex(skinVertex:SkinVertex):SkinVertex {
		
		var result:SkinVertex = clonedskinvertices[untyped skinVertex];
		if (result == null) {
			result = new SkinVertex(cloneVertex(skinVertex.skinnedVertex));
			result.weights = skinVertex.weights.concat([]);
			for (__i in 0...skinVertex.controllers.length) {
				_skinController = skinVertex.controllers[__i];

				if (_skinController != null) {
					result.controllers.push(cloneSkinController(_skinController));
				}
			}

			clonedskinvertices[untyped skinVertex] = result;
		}
		return result;
	}

	private function cloneSkinController(skinController:SkinController):SkinController {
		
		var result:SkinController = clonedskincontrollers[untyped skinController];
		if (result == null) {
			result = new SkinController();
			result.name = skinController.name;
			result.bindMatrix = skinController.bindMatrix;
			clonedskincontrollers[untyped skinController] = result;
		}
		return result;
	}

	private function cloneUV(uv:UV):UV {
		
		if (uv == null) {
			return null;
		}
		var result:UV = cloneduvs[untyped uv];
		if (result == null) {
			result = new UV(uv._u, uv._v);
			cloneduvs[untyped uv] = result;
		}
		return result;
	}

	private function updatePlaySequence(e:AnimationEvent):Void {
		
		if (_animationgroup.playlist.length == 0) {
			_animation.removeEventListener(AnimationEvent.SEQUENCE_UPDATE, updatePlaySequence);
			_animation.sequenceEvent = false;
			if (hasSequenceEvent) {
				if (_sequencedone == null) {
					_sequencedone = new AnimationEvent(AnimationEvent.SEQUENCE_DONE, null);
				}
				dispatchEvent(_sequencedone);
			}
			if (_animationgroup.loopLast) {
				_animation.start();
			}
		} else {
			if (_animationgroup.playlist.length == 1) {
				loop = _animationgroup.loopLast;
				//trace("loop last = "+ _animation.loop);
				_animationgroup.playlist[0].loop = _animationgroup.loopLast;
				//trace("_animationgroup.playlist[0].loop = "+ _animationgroup.playlist[0].loop);
				
			}
			play(_animationgroup.playlist.shift());
		}
	}

	/**
	 * Returns an array of the faces contained in the geometry object.
	 */
	public function getFaces():Array<Dynamic> {
		
		return _faces;
	}

	public function getVertexDirty():Bool {
		
		for (__i in 0...vertices.length) {
			_vertex = vertices[__i];

			if (_vertex != null) {
				if (_vertex.positionDirty) {
					return true;
				}
			}
		}

		return false;
	}

	/**
	 * Returns an array of the segments contained in the geometry object.
	 */
	public function getSegments():Array<Dynamic> {
		
		return _segments;
	}

	/**
	 * Returns an array of the billboards contained in the geometry object.
	 */
	public function getBillboards():Array<Dynamic> {
		
		return _billboards;
	}

	/**
	 * Returns an array of all elements contained in the geometry object.
	 */
	public function getElements():Array<Dynamic> {
		
		return _billboards.concat(_faces).concat(_segments);
	}

	/**
	 * Returns an array of all vertices contained in the geometry object
	 */
	public function getVertices():Array<Dynamic> {
		
		if (_verticesDirty) {
			_vertices = [];
			var processed:Dictionary = new Dictionary();
			for (__i in 0...elements.length) {
				var element:Element = elements[__i];

				if (element != null) {
					for (__j in 0...element.vertices.length) {
						var vertex:Vertex = element.vertices[__j];

						if (vertex != null) {
							if (processed[untyped vertex] == null) {
								_vertices.push(vertex);
								processed[untyped vertex] = true;
							}
						}
					}

				}
			}

			_verticesDirty = false;
		}
		return _vertices;
	}

	/**
	 * Indicates the current frame of animation
	 */
	public function getFrame():Int {
		
		return Std.int(_animation.frame);
	}

	public function setFrame(value:Int):Int {
		
		if (_animation.frame == value) {
			return value;
		}
		_frame = value;
		_animation.frame = value;
		frames[untyped value].adjust(1);
		return value;
	}

	/**
	 * Indicates whether the animation has a cycle event listener
	 */
	public function getHasCycleEvent():Bool {
		
		return _animation.hasEventListener(AnimationEvent.CYCLE);
	}

	/**
	 * Indicates whether the animation has a sequencedone event listener
	 */
	public function getHasSequenceEvent():Bool {
		
		return hasEventListener(AnimationEvent.SEQUENCE_DONE);
	}

	/**
	 * Determines the frames per second at which the animation will run.
	 */
	public function setFps(value:Int):Int {
		
		_animation.fps = (value >= 1) ? value : 1;
		return value;
	}

	/**
	 * Determines whether the animation will loop.
	 */
	public function setLoop(loop:Bool):Bool {
		
		_animation.loop = loop;
		return loop;
	}

	/**
	 * Determines howmany frames a transition between the actual and the next animationSequence should interpolate together.
	 * must be higher or equal to 1. Default = 10;
	 */
	public function setTransitionValue(val:Float):Float {
		
		_animation.transitionValue = val;
		return val;
	}

	public function getTransitionValue():Float {
		
		return _animation.transitionValue;
	}

	/**
	 * Determines whether the animation will smooth motion (interpolate) between frames.
	 */
	public function setSmooth(smooth:Bool):Bool {
		
		_animation.smooth = smooth;
		return smooth;
	}

	/**
	 * Indicates whether the animation is currently running.
	 */
	public function getIsRunning():Bool {
		
		return (_animation != null) ? _animation.isRunning : false;
	}

	/**
	 * Adds a face object to the geometry object.
	 * 
	 * @param	face	The face object to be added.
	 */
	public function addFace(face:Face):Void {
		
		addElement(face);
		if (face.material != null) {
			addMaterial(face, face.material);
		}
		_vertfacesDirty = true;
		face.v0.geometry = this;
		face.v1.geometry = this;
		face.v2.geometry = this;
		face.addOnMappingChange(onFaceMappingChange);
		_faces.push(face);
	}

	/**
	 * Removes a face object from the geometry object.
	 * 
	 * @param	face	The face object to be removed.
	 */
	public function removeFace(face:Face):Void {
		
		var index:Int = untyped _faces.indexOf(face);
		if (index == -1) {
			return;
		}
		removeElement(face);
		if (face.material != null) {
			removeMaterial(face, face.material);
		}
		_vertfacesDirty = true;
		face.v0.geometry = null;
		face.v1.geometry = null;
		face.v2.geometry = null;
		face.notifyMappingChange();
		face.removeOnMappingChange(onFaceMappingChange);
		_faces.splice(index, 1);
	}

	/**
	 * Adds a segment object to the geometry object.
	 * 
	 * @param	segment	The segment object to be added.
	 */
	public function addSegment(segment:Segment):Void {
		
		addElement(segment);
		if (segment.material != null) {
			addMaterial(segment, segment.material);
		}
		segment.v0.geometry = this;
		segment.v1.geometry = this;
		_segments.push(segment);
	}

	/**
	 * Removes a segment object to the geometry object.
	 * 
	 * @param	segment	The segment object to be removed.
	 */
	public function removeSegment(segment:Segment):Void {
		
		var index:Int = untyped _segments.indexOf(segment);
		if (index == -1) {
			return;
		}
		removeElement(segment);
		if (segment.material != null) {
			removeMaterial(segment, segment.material);
		}
		segment.v0.geometry = null;
		segment.v1.geometry = null;
		_segments.splice(index, 1);
	}

	/**
	 * Adds a billboard object to the geometry object.
	 * 
	 * @param	billboard	The segment object to be added.
	 */
	public function addBillboard(billboard:Billboard):Void {
		
		addElement(billboard);
		if (billboard.material != null) {
			addMaterial(billboard, billboard.material);
		}
		billboard.vertex.geometry = this;
		_billboards.push(billboard);
	}

	/**
	 * Removes a segment object to the geometry object.
	 * 
	 * @param	segment	The segment object to be removed.
	 */
	public function removeBillboard(billboard:Billboard):Void {
		
		var index:Int = untyped _billboards.indexOf(billboard);
		if (index == -1) {
			return;
		}
		removeElement(billboard);
		if (billboard.material != null) {
			removeMaterial(billboard, billboard.material);
		}
		billboard.vertex.geometry = null;
		_billboards.splice(index, 1);
	}

	/**
	 * Inverts the geometry of all face objects.
	 * 
	 * @see away3d.code.base.Face#invert()
	 */
	public function invertFaces():Void {
		
		for (__i in 0..._faces.length) {
			var face:Face = _faces[__i];

			if (face != null) {
				face.invert();
			}
		}

	}

	/**
	 * Divides all faces objects of a Mesh into 4 equal sized face objects.
	 * Used to segment a geometry in order to reduce affine persepective distortion.
	 * 
	 * @see away3d.primitives.SkyBox
	 */
	public function quarterFaces():Void {
		
		var medians:Dictionary = new Dictionary();
		for (__i in 0..._faces.concat([]).length) {
			var face:Face = _faces.concat([])[__i];

			if (face != null) {
				quarterFace(face, medians);
			}
		}

	}

	/**
	 * Divides a face object into 4 equal sized face objects.
	 * 
	 * @param	face	The face to split in 4 equal faces.
	 */
	public function quarterFace(face:Face, ?medians:Dictionary=null):Void {
		
		if (medians == null) {
			medians = new Dictionary();
		}
		var v0:Vertex = face.v0;
		var v1:Vertex = face.v1;
		var v2:Vertex = face.v2;
		if (medians[untyped v0] == null) {
			medians[untyped v0] = new Dictionary();
		}
		if (medians[untyped v1] == null) {
			medians[untyped v1] = new Dictionary();
		}
		if (medians[untyped v2] == null) {
			medians[untyped v2] = new Dictionary();
		}
		var v01:Vertex = medians[untyped v0][untyped v1];
		if (v01 == null) {
			v01 = Vertex.median(v0, v1);
			medians[untyped v0][untyped v1] = v01;
			medians[untyped v1][untyped v0] = v01;
		}
		var v12:Vertex = medians[untyped v1][untyped v2];
		if (v12 == null) {
			v12 = Vertex.median(v1, v2);
			medians[untyped v1][untyped v2] = v12;
			medians[untyped v2][untyped v1] = v12;
		}
		var v20:Vertex = medians[untyped v2][untyped v0];
		if (v20 == null) {
			v20 = Vertex.median(v2, v0);
			medians[untyped v2][untyped v0] = v20;
			medians[untyped v0][untyped v2] = v20;
		}
		var uv0:UV = face.uv0;
		var uv1:UV = face.uv1;
		var uv2:UV = face.uv2;
		var uv01:UV = UV.median(uv0, uv1);
		var uv12:UV = UV.median(uv1, uv2);
		var uv20:UV = UV.median(uv2, uv0);
		var material:ITriangleMaterial = face.material;
		removeFace(face);
		addFace(new Face(v0, v01, v20, material, uv0, uv01, uv20));
		addFace(new Face(v01, v1, v12, material, uv01, uv1, uv12));
		addFace(new Face(v20, v12, v2, material, uv20, uv12, uv2));
		addFace(new Face(v12, v20, v01, material, uv12, uv20, uv01));
	}

	/**
	 * Divides all faces objects of a Mesh into 3 face objects.
	 * 
	 */
	public function triFaces():Void {
		
		for (__i in 0..._faces.concat([]).length) {
			var face:Face = _faces.concat([])[__i];

			if (face != null) {
				triFace(face);
			}
		}

	}

	/**
	 * Divides a face object into 3 face objects.
	 * 
	 * @param	face	The face to split in 3 faces.
	 */
	public function triFace(face:Face):Void {
		
		var v0:Vertex = face.v0;
		var v1:Vertex = face.v1;
		var v2:Vertex = face.v2;
		var vc:Vertex = new Vertex((face.v0.x + face.v1.x + face.v2.x) / 3, (face.v0.y + face.v1.y + face.v2.y) / 3, (face.v0.z + face.v1.z + face.v2.z) / 3);
		var uv0:UV = face.uv0;
		var uv1:UV = face.uv1;
		var uv2:UV = face.uv2;
		var uvc:UV = new UV((uv0.u + uv1.u + uv2.u) / 3, (uv0.v + uv1.v + uv2.v) / 3);
		var material:ITriangleMaterial = face.material;
		removeFace(face);
		addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));
		addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
		addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));
	}

	/**
	 * Divides all faces objects of a Mesh into 2 face objects.
	 * 
	 * @param	side	The side of the faces to split in two. 0 , 1 or 2. (clockwize).
	 */
	public function splitFaces(?side:Int=0):Void {
		
		side = (side < 0) ? 0 : (side > 2) ? 2 : side;
		for (__i in 0..._faces.concat([]).length) {
			var face:Face = _faces.concat([])[__i];

			if (face != null) {
				splitFace(face, side);
			}
		}

	}

	/**
	 * Divides a face object into 2 face objects.
	 * 
	 * @param	face	The face to split in 2 faces.
	 * @param	side	The side of the face to split in two. 0 , 1 or 2. (clockwize).
	 */
	public function splitFace(face:Face, ?side:Int=0):Void {
		
		var v0:Vertex = face.v0;
		var v1:Vertex = face.v1;
		var v2:Vertex = face.v2;
		var uv0:UV = face.uv0;
		var uv1:UV = face.uv1;
		var uv2:UV = face.uv2;
		var vc:Vertex;
		var uvc:UV;
		var material:ITriangleMaterial = face.material;
		removeFace(face);
		switch (side) {
			case 0 :
				vc = new Vertex((face.v0.x + face.v1.x) * .5, (face.v0.y + face.v1.y) * .5, (face.v0.z + face.v1.z) * .5);
				uvc = new UV((uv0.u + uv1.u) * .5, (uv0.v + uv1.v) * .5);
				addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
				addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));
			case 1 :
				vc = new Vertex((face.v1.x + face.v2.x) * .5, (face.v1.y + face.v2.y) * .5, (face.v1.z + face.v2.z) * .5);
				uvc = new UV((uv1.u + uv2.u) * .5, (uv1.v + uv2.v) * .5);
				addFace(new Face(v0, v1, vc, material, uv0, uv1, uv2));
				addFace(new Face(v0, vc, v2, material, uv0, uvc, uv2));
			default :
				vc = new Vertex((face.v2.x + face.v0.x) * .5, (face.v2.y + face.v0.y) * .5, (face.v2.z + face.v0.z) * .5);
				uvc = new UV((uv2.u + uv0.u) * .5, (uv2.v + uv0.v) * .5);
				addFace(new Face(v0, v1, vc, material, uv0, uv1, uvc));
				addFace(new Face(vc, v1, v2, material, uvc, uv1, uv2));
			

		}
	}

	private function findNeighbours():Void {
		
		_neighbour01 = new Dictionary();
		_neighbour12 = new Dictionary();
		_neighbour20 = new Dictionary();
		for (__i in 0..._faces.length) {
			var face:Face = _faces[__i];

			if (face != null) {
				var skip:Bool = true;
				for (__i in 0..._faces.length) {
					var another:Face = _faces[__i];

					if (another != null) {
						if (skip) {
							if (face == another) {
								skip = false;
							}
							continue;
						}
						if ((face._v0 == another._v2) && (face._v1 == another._v1)) {
							_neighbour01[untyped face] = another;
							_neighbour12[untyped another] = face;
						}
						if ((face._v0 == another._v0) && (face._v1 == another._v2)) {
							_neighbour01[untyped face] = another;
							_neighbour20[untyped another] = face;
						}
						if ((face._v0 == another._v1) && (face._v1 == another._v0)) {
							_neighbour01[untyped face] = another;
							_neighbour01[untyped another] = face;
						}
						if ((face._v1 == another._v2) && (face._v2 == another._v1)) {
							_neighbour12[untyped face] = another;
							_neighbour12[untyped another] = face;
						}
						if ((face._v1 == another._v0) && (face._v2 == another._v2)) {
							_neighbour12[untyped face] = another;
							_neighbour20[untyped another] = face;
						}
						if ((face._v1 == another._v1) && (face._v2 == another._v0)) {
							_neighbour12[untyped face] = another;
							_neighbour01[untyped another] = face;
						}
						if ((face._v2 == another._v2) && (face._v0 == another._v1)) {
							_neighbour20[untyped face] = another;
							_neighbour12[untyped another] = face;
						}
						if ((face._v2 == another._v0) && (face._v0 == another._v2)) {
							_neighbour20[untyped face] = another;
							_neighbour20[untyped another] = face;
						}
						if ((face._v2 == another._v1) && (face._v0 == another._v0)) {
							_neighbour20[untyped face] = another;
							_neighbour01[untyped another] = face;
						}
					}
				}

			}
		}

		_neighboursDirty = false;
	}

	/**
	 * Updates the elements in the geometry object
	 * 
	 * @param	time		The absolute time at the start of the render cycle
	 * 
	 * @see away3d.core.traverse.TickTraverser
	 * @see away3d.core.basr.Animation#update()
	 */
	public function updateElements(time:Int):Void {
		
		_dispatchedDimensionsChange = false;
		if (_renderTime == time) {
			return;
		}
		_renderTime = time;
		if (skinControllers != null) {
			for (__i in 0...skinControllers.length) {
				_skinController = skinControllers[__i];
	
				if (_skinController != null) {
					_skinController.update();
				}
			}
		}
		
		if (skinVertices != null) {
			for (__i in 0...skinVertices.length) {
				_skinVertex = skinVertices[__i];
	
				if (_skinVertex != null) {
					_skinVertex.update();
				}
			}
		}

		if ((_animation != null) && (frames != null)) {
			_animation.update();
		}
		if (vertexDirty) {
			notifyDimensionsChange();
		}
	}

	/**
	 * Updates the materials in the geometry object
	 */
	public function updateMaterials(source:Object3D, view:View3D):Void {
		
		var __keys:Iterator<Dynamic> = untyped (__keys__(materialDictionary)).iterator();
		for (__key in __keys) {
			_materialData = materialDictionary[untyped __key];

			if (_materialData != null) {
				_materialData.material.updateMaterial(source, view);
			}
		}

	}

	/**
	 * Duplicates the geometry properties to another geometry object.
	 * 
	 * @return				The new geometry instance with duplicated properties applied.
	 */
	public function clone():Geometry {
		
		var geometry:Geometry = new Geometry();
		clonedvertices = new Dictionary();
		cloneduvs = new Dictionary();
		if ((skinVertices != null)) {
			clonedskinvertices = new Dictionary(true);
			clonedskincontrollers = new Dictionary(true);
			geometry.skinVertices = new Array<Dynamic>();
			geometry.skinControllers = new Array<Dynamic>();
			for (__i in 0...skinVertices.length) {
				var skinVertex:SkinVertex = skinVertices[__i];

				if (skinVertex != null) {
					geometry.skinVertices.push(cloneSkinVertex(skinVertex));
				}
			}

			var __keys:Iterator<Dynamic> = untyped (__keys__(clonedskincontrollers)).iterator();
			for (__key in __keys) {
				var skinController:SkinController = clonedskincontrollers[untyped __key];

				if (skinController != null) {
					geometry.skinControllers.push(skinController);
				}
			}

		}
		for (__i in 0..._faces.length) {
			var face:Face = _faces[__i];

			if (face != null) {
				var cloneFace:Face = new Face(cloneVertex(face._v0), cloneVertex(face._v1), cloneVertex(face._v2), face.material, cloneUV(face._uv0), cloneUV(face._uv1), cloneUV(face._uv2));
				geometry.addFace(cloneFace);
				cloneElementDictionary[untyped face] = cloneFace;
			}
		}

		for (__i in 0..._segments.length) {
			var segment:Segment = _segments[__i];

			if (segment != null) {
				var cloneSegment:Segment = new Segment(cloneVertex(segment._v0), cloneVertex(segment._v1), segment.material);
				geometry.addSegment(cloneSegment);
				cloneElementDictionary[untyped segment] = cloneSegment;
			}
		}

		geometry.frames = new Dictionary(true);
		var i:Int = 0;
		var __keys:Iterator<Dynamic> = untyped (__keys__(frames)).iterator();
		for (__key in __keys) {
			var frame:Frame = frames[untyped __key];

			if (frame != null) {
				geometry.frames[i++] = cloneFrame(frame);
			}
		}

		geometry.framenames = new Hash<Int>();
		var framename:String;
		var __keys:Iterator<Dynamic> = untyped (__keys__(framenames)).iterator();
		for (framename in framenames.keys()) {
			geometry.framenames.set(framename, framenames.get(framename));
			
		}

		return geometry;
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
		
		v.setValue(x, y, z);
		if (refreshNormals) {
			_vertnormalsDirty = true;
		}
	}

	/**
	 * Apply the given rotation values to vertex coordinates.
	 */
	public function applyRotations(rotationX:Float, rotationY:Float, rotationZ:Float):Void {
		
		var x:Float;
		var y:Float;
		var z:Float;
		var x1:Float;
		var y1:Float;
		var rad:Float = Math.PI / 180;
		var rotx:Float = rotationX * rad;
		var roty:Float = rotationY * rad;
		var rotz:Float = rotationZ * rad;
		var sinx:Float = Math.sin(rotx);
		var cosx:Float = Math.cos(rotx);
		var siny:Float = Math.sin(roty);
		var cosy:Float = Math.cos(roty);
		var sinz:Float = Math.sin(rotz);
		var cosz:Float = Math.cos(rotz);
		for (__i in 0...vertices.length) {
			var vertex:Vertex = vertices[__i];

			if (vertex != null) {
				x = vertex.x;
				y = vertex.y;
				z = vertex.z;
				y1 = y;
				y = y1 * cosx + z * -sinx;
				z = y1 * sinx + z * cosx;
				x1 = x;
				x = x1 * cosy + z * siny;
				z = x1 * -siny + z * cosy;
				x1 = x;
				x = x1 * cosz + y * -sinz;
				y = x1 * sinz + y * cosz;
				updateVertex(vertex, x, y, z, false);
			}
		}

	}

	/**
	 * Apply the given position values to vertex coordinates.
	 */
	public function applyPosition(dx:Float, dy:Float, dz:Float):Void {
		
		var x:Float;
		var y:Float;
		var z:Float;
		for (__i in 0...vertices.length) {
			var vertex:Vertex = vertices[__i];

			if (vertex != null) {
				x = vertex.x;
				y = vertex.y;
				z = vertex.z;
				vertex.setValue(x - dx, y - dy, z - dz);
			}
		}

	}

	/**
	 * Plays a sequence of frames
	 * 
	 * @param	sequence	The animationsequence to play
	 */
	public function play(sequence:AnimationSequence):Void {
		
		if (_animation == null) {
			_animation = new Animation(this);
		} else {
			_animation.sequence = new Array<Dynamic>();
		}
		_animation.fps = sequence.fps;
		_animation.smooth = sequence.smooth;
		_animation.loop = sequence.loop;
		if (sequence.prefix != null && sequence.prefix != "") {
			if (_animation.smooth) {
				_animation.interpolate();
			}
			var bvalidprefix:Bool = false;
			var framename:String;
			for (framename in framenames.keys()) {
				if (framename.indexOf(sequence.prefix) == 0) {
					bvalidprefix = true;
					_activeprefix = (_activeprefix != sequence.prefix) ? sequence.prefix : _activeprefix;
					_animation.sequence.push(new AnimationFrame(framenames.get(framename), "" + Std.parseInt(framename.substr(0, sequence.prefix.length))));
				}
				
			}

			if (bvalidprefix) {
				untyped _animation.sequence.sortOn("sort", Array.NUMERIC);
				frames[untyped _frame].adjust(1);
				_animation.start();
				//trace(">>>>>>>> [  start "+activeprefix+"  ]");
				
			} else {
				trace("--------- \n--> unable to play animation: unvalid prefix [" + sequence.prefix + "]\n--------- ");
			}
		} else {
			trace("--------- \n--> unable to play animation: prefix is null \n--------- ");
		}
	}

	/**
	 * return the prefix of the animation actually started.
	 * 
	 */
	public function getActivePrefix():String {
		
		return _activeprefix;
	}

	/**
	 * Starts playing the animation at the specified frame.
	 * 
	 * @param	value		A number representing the frame number.
	 */
	public function gotoAndPlay(value:Int):Void {
		
		_animation.frame = _frame  = value;
		frames[untyped _frame].adjust(1);
		if (!_animation.isRunning) {
			_animation.start();
		}
	}

	/**
	 * Brings the animation to the specifed frame and stops it there.
	 * 
	 * @param	value		A number representing the frame number.
	 */
	public function gotoAndStop(value:Int):Void {
		
		_animation.frame = _frame  = value;
		frames[untyped _frame].adjust(1);
		if (_animation.isRunning) {
			_animation.stop();
		}
	}

	/**
	 * Plays a sequence of frames
	 * Note that the framenames must be be already existing in the system before you can use this handler
	 * @param	prefixes  	Array. The list of framenames to be played
	 * @param	fps			uint: frames per second
	 * @param	smooth		[optional] Boolean. if the animation must interpolate. Default = true.
	 * @param	loop			[optional] Boolean. if the animation must loop. Default = false.
	 */
	public function playFrames(prefixes:Array<Dynamic>, fps:Int, ?smooth:Bool=true, ?loop:Bool=false):Void {
		
		if ((_animation != null)) {
			_animation.sequence = [];
		} else {
			_animation = new Animation(this);
		}
		_animation.fps = fps;
		_animation.smooth = smooth;
		_animation.loop = loop;
		if (smooth) {
			_animation.createTransition();
		}
		for (__i in 0...prefixes.length) {
			var framename:String = prefixes[__i];

			if (framename != null) {
				if (framenames.get(framename) != null) {
					_animation.sequence.push(new AnimationFrame(framenames.get(framename)));
				}
			}
		}

		if (_animation.sequence.length > 0) {
			_animation.start();
		}
	}

	/**
	 * Passes an array of animationsequence objects to be added to the animation.
	 * 
	 * @param	playlist				An array of animationsequence objects.
	 * @param	loopLast	[optional]	Determines whether the last sequence will loop. Defaults to false.
	 */
	public function setPlaySequences(playlist:Array<Dynamic>, ?loopLast:Bool=false):Void {
		
		if (playlist.length == 0) {
			return;
		}
		if (_animation == null) {
			_animation = new Animation(this);
		}
		_animationgroup = new AnimationGroup();
		_animationgroup.loopLast = loopLast;
		_animationgroup.playlist = [];
		var i:Int = 0;
		while (i < playlist.length) {
			_animationgroup.playlist[i] = new AnimationSequence(playlist[i].prefix, playlist[i].smooth, true, playlist[i].fps);
			
			// update loop variables
			++i;
		}

		if (!_animation.hasEventListener(AnimationEvent.SEQUENCE_UPDATE)) {
			_animation.addEventListener(AnimationEvent.SEQUENCE_UPDATE, updatePlaySequence);
		}
		_animation.sequenceEvent = true;
		loop = true;
		play(_animationgroup.playlist.shift());
	}

	/**
	 * Default method for adding a sequenceDone event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnSequenceDone(listener:Dynamic):Void {
		
		addEventListener(AnimationEvent.SEQUENCE_DONE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a sequenceDone event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnSequenceDone(listener:Dynamic):Void {
		
		removeEventListener(AnimationEvent.SEQUENCE_DONE, listener, false);
	}

	/**
	 * Default method for adding a cycle event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnCycle(listener:Dynamic):Void {
		
		_animation.cycleEvent = true;
		_cycle = new AnimationEvent(AnimationEvent.CYCLE, _animation);
		_animation.addEventListener(AnimationEvent.CYCLE, listener, false, 0, false);
	}

	/**
	 * Default method for removing a cycle event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnCycle(listener:Dynamic):Void {
		
		_animation.cycleEvent = false;
		_animation.removeEventListener(AnimationEvent.CYCLE, listener, false);
	}

	/**
	 * Default method for adding a dimensionsChanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnDimensionsChange(listener:Dynamic):Void {
		
		addEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a dimensionsChanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnDimensionsChange(listener:Dynamic):Void {
		
		removeEventListener(GeometryEvent.DIMENSIONS_CHANGED, listener, false);
	}

	/**
	 * Default method for adding a materialUpdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMaterialUpdate(listener:Dynamic):Void {
		
		addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a materialUpdated event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMaterialUpdate(listener:Dynamic):Void {
		
		removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
	}

	/**
	 * Default method for adding a mappingChanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function addOnMappingChange(listener:Dynamic):Void {
		
		addEventListener(FaceEvent.MAPPING_CHANGED, listener, false, 0, true);
	}

	/**
	 * Default method for removing a mappingChanged event listener
	 * 
	 * @param	listener		The listener function
	 */
	public function removeOnMappingChange(listener:Dynamic):Void {
		
		removeEventListener(FaceEvent.MAPPING_CHANGED, listener, false);
	}

	// autogenerated
	public function new () {
		super();
		this._faces = [];
		this._segments = [];
		this._billboards = [];
		this._verticesDirty = true;
		this._neighboursDirty = true;
		this._vertfacesDirty = true;
		this._vertnormalsDirty = true;
		this.materialDictionary = new Dictionary(true);
		this.cloneElementDictionary = new Dictionary();
		
	}

	

}

