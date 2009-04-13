package away3d.containers;

import away3d.haxeutils.Error;
import away3d.core.utils.Debug;
import away3d.loaders.data.AnimationData;
import away3d.core.math.Number3D;
import away3d.animators.skin.Bone;
import flash.events.EventDispatcher;
import away3d.loaders.utils.AnimationLibrary;
import away3d.loaders.data.MaterialData;
import away3d.core.math.Matrix3D;
import away3d.animators.skin.SkinController;
import away3d.loaders.utils.MaterialLibrary;
import away3d.haxeutils.HashMap;
import away3d.core.base.Geometry;
import away3d.core.project.ProjectorType;
import away3d.core.base.Object3D;
import away3d.core.base.Mesh;
import away3d.core.traverse.Traverser;
import away3d.events.Object3DEvent;


// use namespace arcane;

/**
 * 3d object container node for other 3d objects in a scene
 */
class ObjectContainer3D extends Object3D  {
	public var children(getChildren, null) : Array<Dynamic>;
	
	private var _children:Array<Dynamic>;
	private var _radiusChild:Object3D;
	

	/** @private */
	public function internalAddChild(child:Object3D):Void {
		
		_children.push(child);
		child.addOnTransformChange(onChildChange);
		child.addOnDimensionsChange(onChildChange);
		notifyDimensionsChange();
		if ((_session != null) && !child.ownCanvas) {
			session.internalAddOwnSession(child);
		}
		_sessionDirty = true;
	}

	/** @private */
	public function internalRemoveChild(child:Object3D):Void {
		
		var index:Int = untyped children.indexOf(child);
		if (index == -1) {
			return;
		}
		child.removeOnTransformChange(onChildChange);
		child.removeOnDimensionsChange(onChildChange);
		_children.splice(index, 1);
		notifyDimensionsChange();
		if ((session != null) && !child.ownCanvas) {
			session.internalRemoveOwnSession(child);
		}
		_sessionDirty = true;
	}

	private function onChildChange(event:Object3DEvent):Void {
		
		notifyDimensionsChange();
	}

	private override function updateDimensions():Void {
		//update bounding radius
		
		var children:Array<Dynamic> = _children.concat([]);
		if ((children.length > 0)) {
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
			var cradius:Float;
			var num:Number3D = new Number3D();
			for (__i in 0...children.length) {
				var child:Object3D = children[__i];

				if (child != null) {
					num.sub(child.position, _pivotPoint);
					cradius = num.modulo + child.parentBoundingRadius;
					if (mradius < cradius) {
						mradius = cradius;
					}
				}
			}

			_boundingRadius = mradius;
			//update max/min X
			untyped children.sortOn("parentmaxX", Array.DESCENDING | Array.NUMERIC);
			_maxX = children[0].parentmaxX;
			untyped children.sortOn("parentminX", Array.NUMERIC);
			_minX = children[0].parentminX;
			//update max/min Y
			untyped children.sortOn("parentmaxY", Array.DESCENDING | Array.NUMERIC);
			_maxY = children[0].parentmaxY;
			untyped children.sortOn("parentminY", Array.NUMERIC);
			_minY = children[0].parentminY;
			//update max/min Z
			untyped children.sortOn("parentmaxZ", Array.DESCENDING | Array.NUMERIC);
			_maxZ = children[0].parentmaxZ;
			untyped children.sortOn("parentminZ", Array.NUMERIC);
			_minZ = children[0].parentminZ;
		}
		super.updateDimensions();
	}

	/**
	 * Returns the children of the container as an array of 3d objects
	 */
	public function getChildren():Array<Dynamic> {
		
		return _children;
	}

	/**
	 * Creates a new <code>ObjectContainer3D</code> object
	 * 
	 * @param	...initarray		An array of 3d objects to be added as children of the container on instatiation. Can contain an initialisation object
	 */
	public function new(?initarray:Array<Dynamic>) {
		this._children = new Array();
		this._radiusChild = null;
		
		
		var init:Dynamic = null;
		var childarray:Array<Dynamic> = [];
		if (initarray != null) {
			for (__i in 0...initarray.length) {
				var object:Dynamic = initarray[__i];
	
				if (object != null) {
					if (Std.is(object, Object3D)) {
						childarray.push(object);
					} else {
						init = object;
					}
				}
			}
		}
		
		super(init);
		projectorType = ProjectorType.OBJECT_CONTAINER;
		for (__i in 0...childarray.length) {
			var child:Object3D = childarray[__i];

			if (child != null) {
				addChild(child);
			}
		}

	}

	/**
	 * Adds an array of 3d objects to the scene as children of the container
	 * 
	 * @param	...childarray		An array of 3d objects to be added
	 */
	public function addChildren(?childarray:Array<Dynamic>):Void {
		if (childarray == null) childarray = new Array<Dynamic>();
		
		for (__i in 0...childarray.length) {
			var child:Object3D = childarray[__i];

			if (child != null) {
				addChild(child);
			}
		}

	}

	/**
	 * Adds a 3d object to the scene as a child of the container
	 * 
	 * @param	child	The 3d object to be added
	 * @throws	Error	ObjectContainer3D.addChild(null)
	 */
	public function addChild(child:Object3D):Void {
		
		if (child == null) {
			throw new Error("ObjectContainer3D.addChild(null)");
		}
		child.parent = this;
	}

	/**
	 * Removes a 3d object from the child array of the container
	 * 
	 * @param	child	The 3d object to be removed
	 * @throws	Error	ObjectContainer3D.removeChild(null)
	 */
	public function removeChild(child:Object3D):Void {
		
		if (child == null) {
			throw new Error("ObjectContainer3D.removeChild(null)");
		}
		if (child.parent != this) {
			return;
		}
		child.parent = null;
	}

	/**
	 * Returns a 3d object specified by name from the child array of the container
	 * 
	 * @param	name	The name of the 3d object to be returned
	 * @return			The 3d object, or <code>null</code> if no such child object exists with the specified name
	 */
	public function getChildByName(childName:String):Object3D {
		
		var child:Object3D;
		for (__i in 0...children.length) {
			var object3D:Object3D = children[__i];

			if (object3D != null) {
				if (object3D.name != null) {
					if (object3D.name == childName) {
						return object3D;
					}
				}
				if (Std.is(object3D, ObjectContainer3D)) {
					child = (cast(object3D, ObjectContainer3D)).getChildByName(childName);
					if ((child != null)) {
						return child;
					}
				}
			}
		}

		return null;
	}

	/**
	 * Returns a bone object specified by name from the child array of the container
	 * 
	 * @param	name	The name of the bone object to be returned
	 * @return			The bone object, or <code>null</code> if no such bone object exists with the specified name
	 */
	public function getBoneByName(boneName:String):Bone {
		
		var bone:Bone;
		for (__i in 0...children.length) {
			var object3D:Object3D = children[__i];

			if (object3D != null) {
				if (Std.is(object3D, Bone)) {
					bone = cast(object3D, Bone);
					if ((bone.name != null)) {
						if (bone.name == boneName) {
							return bone;
						}
					}
					if (bone.id != null) {
						if (bone.id == boneName) {
							return bone;
						}
					}
				}
				if (Std.is(object3D, ObjectContainer3D)) {
					bone = (cast(object3D, ObjectContainer3D)).getBoneByName(boneName);
					if ((bone != null)) {
						return bone;
					}
				}
			}
		}

		return null;
	}

	/**
	 * Removes a 3d object from the child array of the container
	 * 
	 * @param	name	The name of the 3d object to be removed
	 */
	public function removeChildByName(name:String):Void {
		
		removeChild(getChildByName(name));
	}

	/**
	 * @inheritDoc
	 */
	public override function traverse(traverser:Traverser):Void {
		
		if (traverser.match(this)) {
			traverser.enter(this);
			traverser.apply(this);
			for (__i in 0...children.length) {
				var child:Object3D = children[__i];

				if (child != null) {
					child.traverse(traverser);
				}
			}

			traverser.leave(this);
		}
	}

	/**
	 * Apply the local rotations to child objects without altering the appearance of the object container
	 */
	public override function applyRotations():Void {
		
		var x:Float;
		var y:Float;
		var z:Float;
		var x1:Float;
		var y1:Float;
		var z1:Float;
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
		for (__i in 0...children.length) {
			var child:Object3D = children[__i];

			if (child != null) {
				x = child.x;
				y = child.y;
				z = child.z;
				y1 = y;
				y = y1 * cosx + z * -sinx;
				z = y1 * sinx + z * cosx;
				x1 = x;
				x = x1 * cosy + z * siny;
				z = x1 * -siny + z * cosy;
				x1 = x;
				x = x1 * cosz + y * -sinz;
				y = x1 * sinz + y * cosz;
				child.moveTo(x, y, z);
			}
		}

		rotationX = 0;
		rotationY = 0;
		rotationZ = 0;
	}

	/**
	 * Apply the given position to child objects without altering the appearance of the object container
	 */
	public override function applyPosition(dx:Float, dy:Float, dz:Float):Void {
		
		var x:Float;
		var y:Float;
		var z:Float;
		for (__i in 0...children.length) {
			var child:Object3D = children[__i];

			if (child != null) {
				x = child.x;
				y = child.y;
				z = child.z;
				child.moveTo(x - dx, y - dy, z - dz);
			}
		}

		var dV:Number3D = new Number3D(dx, dy, dz);
		dV.rotate(dV, _transform);
		dV.add(dV, position);
		moveTo(dV.x, dV.y, dV.z);
	}

	/**
	 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public override function clone(?object:Object3D=null):Object3D {
		
		var container:ObjectContainer3D = (cast(object, ObjectContainer3D));
		if (container == null)  {
			container = new ObjectContainer3D();
		};
		super.clone(container);
		var child:Object3D;
		for (__i in 0...children.length) {
			child = children[__i];

			if (child != null) {
				if (!(Std.is(child, Bone))) {
					container.addChild(child.clone());
				}
			}
		}

		return container;
	}

	/**
	 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object, including bones and geometry
	 * 
	 * @param	object	[optional]	The new object instance into which all properties are copied
	 * @return						The new object instance with duplicated properties applied
	 */
	public function cloneAll(?object:Object3D=null):Object3D {
		
		var container:ObjectContainer3D = (cast(object, ObjectContainer3D));
		if (container == null)  {
			container = new ObjectContainer3D();
		};
		super.clone(container);
		var _child:ObjectContainer3D;
		for (__i in 0...children.length) {
			var child:Object3D = children[__i];

			if (child != null) {
				if (Std.is(child, Bone)) {
					_child = new Bone();
					container.addChild(_child);
					(cast(child, Bone)).cloneAll(_child);
				} else if (Std.is(child, ObjectContainer3D)) {
					_child = new ObjectContainer3D();
					container.addChild(_child);
					(cast(child, ObjectContainer3D)).cloneAll(_child);
				} else if (Std.is(child, Mesh)) {
					container.addChild((cast(child, Mesh)).cloneAll());
				} else {
					container.addChild(child.clone());
				}
			}
		}

		if ((animationLibrary != null)) {
			container.animationLibrary = new AnimationLibrary();
			var _animationData:AnimationData;
			for (_animationData in animationLibrary.iterator()) {
				if (_animationData != null) {
					_animationData.clone(container);
				}
			}

		}
		if ((materialLibrary != null)) {
			container.materialLibrary = new MaterialLibrary();
			var _materialData:MaterialData;
			for (_materialData in materialLibrary.iterator()) {
				if (_materialData != null) {
					_materialData.clone(container);
				}
			}

		}
		//find existing root
		var root:ObjectContainer3D = container;
		while ((root.parent != null)) {
			root = root.parent;
		}

		if (container == root) {
			cloneBones(container, root);
		}
		return container;
	}

	private function cloneBones(container:ObjectContainer3D, root:ObjectContainer3D):Void {
		//wire up new bones to new skincontrollers if available
		
		for (__i in 0...container.children.length) {
			var child:Object3D = container.children[__i];

			if (child != null) {
				if (Std.is(child, ObjectContainer3D)) {
					(cast(child, ObjectContainer3D)).cloneBones(cast(child, ObjectContainer3D), root);
				} else if (Std.is(child, Mesh)) {
					var geometry:Geometry = (cast(child, Mesh)).geometry;
					var skinControllers:Array<Dynamic> = geometry.skinControllers;
					var rootBone:Bone;
					var skinController:SkinController;
					for (__i in 0...skinControllers.length) {
						skinController = skinControllers[__i];

						if (skinController != null) {
							var bone:Bone = root.getBoneByName(skinController.name);
							if ((bone != null)) {
								skinController.joint = bone.joint;
								if (!(Std.is(bone.parent.parent, Bone))) {
									rootBone = bone;
								}
							} else {
								Debug.warning("no joint found for " + skinController.name);
							}
						}
					}

					//geometry.rootBone = rootBone;
					for (__i in 0...skinControllers.length) {
						skinController = skinControllers[__i];

						if (skinController != null) {
							skinController.inverseTransform = child.parent.inverseSceneTransform;
						}
					}

				}
			}
		}

	}

}

