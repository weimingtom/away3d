package away3d.containers;

    import away3d.animators.skin.*;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.project.*;
    import away3d.core.traverse.*;
    import away3d.core.utils.Debug;
    import away3d.events.*;
    import away3d.loaders.data.*;
    import away3d.loaders.utils.*;
    
    import flash.display.*;
    
    use namespace arcane;
    
    /**
    * 3d object container node for other 3d objects in a scene
    */
    class ObjectContainer3D extends Object3D {
		public var children(getChildren, null) : Array<Dynamic>
        ;
		/** @private */
        
		/** @private */
        arcane function internalAddChild(child:Object3D):Void
        {
            _children.push(child);
			
            child.addOnTransformChange(onChildChange);
            child.addOnDimensionsChange(onChildChange);

            notifyDimensionsChange();
            
            if (_session && !child.ownCanvas)
            	session.internalAddOwnSession(child);
            
            _sessionDirty = true;
        }
		/** @private */
        arcane function internalRemoveChild(child:Object3D):Void
        {
            var index:Int = children.indexOf(child);
            if (index == -1)
                return;
			
            child.removeOnTransformChange(onChildChange);
            child.removeOnDimensionsChange(onChildChange);
			
            _children.splice(index, 1);

            notifyDimensionsChange();
            
            if (session && !child.ownCanvas)
            	session.internalRemoveOwnSession(child);
            
            _sessionDirty = true;
        }
        
        var _children:Array<Dynamic> ;
        var _radiusChild:Object3D ;
        
        function onChildChange(event:Object3DEvent):Void
        {
            notifyDimensionsChange();
        }
        
        override function updateDimensions():Void
        {
        	//update bounding radius
        	var children:Array<Dynamic> = _children.concat();
        	
        	if (children.length) {
	        	
	        	_boundingScale = _scaleX;
            	
            	if (_boundingScale < _scaleY)
            		_boundingScale = _scaleY;
            	
            	if (_boundingScale < _scaleZ)
            		_boundingScale = _scaleZ;
            	
	        	var mradius:Int = 0;
	        	var cradius:Float;
	            var num:Number3D = new Number3D();
	            for (child in children) {
	            	num.sub(child.position, _pivotPoint);
	            	
	                cradius = num.modulo + child.boundingRadius;
	                if (mradius < cradius)
	                    mradius = cradius;
	            }
	            
	            _boundingRadius = mradius;
	            
	            //update max/min X
	            children.sortOn("parentmaxX", Array.DESCENDING | Array.NUMERIC);
	            _maxX = children[0].parentmaxX;
	            children.sortOn("parentminX", Array.NUMERIC);
	            _minX = children[0].parentminX;
	            
	            //update max/min Y
	            children.sortOn("parentmaxY", Array.DESCENDING | Array.NUMERIC);
	            _maxY = children[0].parentmaxY;
	            children.sortOn("parentminY", Array.NUMERIC);
	            _minY = children[0].parentminY;
	            
	            //update max/min Z
	            children.sortOn("parentmaxZ", Array.DESCENDING | Array.NUMERIC);
	            _maxZ = children[0].parentmaxZ;
	            children.sortOn("parentminZ", Array.NUMERIC);
	            _minZ = children[0].parentminZ;
         	}
         	
            super.updateDimensions();
        }
        
        /**
        * Returns the children of the container as an array of 3d objects
        */
        public function getChildren():Array<Dynamic>
        {
            return _children;
        }
    	
	    /**
	    * Creates a new <code>ObjectContainer3D</code> object
	    * 
	    * @param	...initarray		An array of 3d objects to be added as children of the container on instatiation. Can contain an initialisation object
	    */
        public function new(initarray:Array<Dynamic>)
        {
        	
        	_children = new Array();
        	_radiusChild = null;
        	var init:Dynamic;
        	var childarray:Array<Dynamic> = [];
        	
            for each (var object:Dynamic in initarray)
            	if (Std.is( object, Object3D))
            		childarray.push(object);
            	else
            		init = object;
            
            super(init);
            
            projector = cast( ini.getObject("projector", IPrimitiveProvider), IPrimitiveProvider);
            
            if (!projector)
            	projector = new SessionProjector();
            
            for each (var child:Object3D in childarray)
                addChild(child);
        }
        
		/**
		 * Adds an array of 3d objects to the scene as children of the container
		 * 
		 * @param	...childarray		An array of 3d objects to be added
		 */
        public function addChildren(childarray:Array<Dynamic>):Void
        {
            for each (var child:Object3D in childarray)
                addChild(child);
        }
        
		/**
		 * Adds a 3d object to the scene as a child of the container
		 * 
		 * @param	child	The 3d object to be added
		 * @throws	Error	ObjectContainer3D.addChild(null)
		 */
        public function addChild(child:Object3D):Void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.addChild(null)");
            
            child.parent = this;
        }
        
		/**
		 * Removes a 3d object from the child array of the container
		 * 
		 * @param	child	The 3d object to be removed
		 * @throws	Error	ObjectContainer3D.removeChild(null)
		 */
        public function removeChild(child:Object3D):Void
        {
            if (child == null)
                throw new Error("ObjectContainer3D.removeChild(null)");
            if (child.parent != this)
                return;
            child.parent = null;
        }
        
		/**
		 * Returns a 3d object specified by name from the child array of the container
		 * 
		 * @param	name	The name of the 3d object to be returned
		 * @return			The 3d object, or <code>null</code> if no such child object exists with the specified name
		 */
        public function getChildByName(childName:String):Object3D
        {	
			var child:Object3D;
            for (object3D in children) {
            	if (object3D.name)
					if (object3D.name == childName)
						return object3D;
				
            	if (Std.is( object3D, ObjectContainer3D)) {
	                child = (cast( object3D, ObjectContainer3D)).getChildByName(childName);
	                if (child)
	                    return child;
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
        public function getBoneByName(boneName:String):Bone
        {	
			var bone:Bone;
            for (object3D in children) {
            	if (Std.is( object3D, Bone)) {
            		bone = cast( object3D, Bone);
            		
	            	if (bone.name)
						if (bone.name == boneName)
							return bone;
					
					if (bone.id)
						if (bone.id == boneName)
							return bone;
            	}
            	if (Std.is( object3D, ObjectContainer3D)) {
	                bone = (cast( object3D, ObjectContainer3D)).getBoneByName(boneName);
	                if (bone)
	                    return bone;
	            }
            }
			
            return null;
        }
        
		/**
		 * Removes a 3d object from the child array of the container
		 * 
		 * @param	name	The name of the 3d object to be removed
		 */
        public function removeChildByName(name:String):Void
        {
            removeChild(getChildByName(name));
        }
        
		/**
		 * @inheritDoc
		 */
        public override function traverse(traverser:Traverser):Void
        {
            if (traverser.match(this))
            {
                traverser.enter(this);
                traverser.apply(this);                for each (var child:Object3D in children)
                    child.traverse(traverser);
                traverser.leave(this);
            }
        }
        
		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public override function clone(?object:Object3D = null):Object3D
        {
            var container:ObjectContainer3D = (cast( object, ObjectContainer3D)) || new ObjectContainer3D();
            super.clone(container);
			
			var child:Object3D;
            for each (child in children)
            	if (!(Std.is( child, Bone)))
                	container.addChild(child.clone());
                
            return container;
        }
		
		/**
		 * Duplicates the 3d object's properties to another <code>ObjectContainer3D</code> object, including bones and geometry
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public function cloneAll(?object:Object3D = null):Object3D
        {
            var container:ObjectContainer3D = (cast( object, ObjectContainer3D)) || new ObjectContainer3D();
            super.clone(container);
			
			var _child:ObjectContainer3D;
            for (child in children) {
            	if (Std.is( child, Bone)) {
            		_child = new Bone();
                	container.addChild(_child);
                	(cast( child, Bone)).cloneAll(_child);
            	} else if (Std.is( child, ObjectContainer3D)) {
            		_child = new ObjectContainer3D();
                	container.addChild(_child);
                	(cast( child, ObjectContainer3D)).cloneAll(_child)
            	} else if (Std.is( child, Mesh)) {
                	container.addChild((cast( child, Mesh)).cloneAll());
            	} else {
                	container.addChild(child.clone());
             	}
            }
            
            if (animationLibrary) {
        		container.animationLibrary = new AnimationLibrary();
            	for each (var _animationData:AnimationData in animationLibrary) 
            		_animationData.clone(container);
            }
            
            //find existing root
            var root:ObjectContainer3D = container;
            
            while (root.parent)
            	root = root.parent;
            
        	if (container == root)
        		cloneBones(container, root);
        	
            return container;
        }
        
        function cloneBones(container:ObjectContainer3D, root:ObjectContainer3D):Void
        {
        	//wire up new bones to new skincontrollers if available
            for (child in container.children) {
            	if (Std.is( child, ObjectContainer3D)) {
            		(cast( child, ObjectContainer3D)).cloneBones(cast( child, ObjectContainer3D), root);
             	} else if (Std.is( child, Mesh)) {
                	var geometry:Geometry = (cast( child, Mesh)).geometry;
                	var skinControllers:Array<Dynamic> = geometry.skinControllers;
                	var rootBone:Bone;
                	var skinController:SkinController;
                	
					for (skinController in skinControllers) {
						var bone:Bone = root.getBoneByName(skinController.name);
		                if (bone) {
		                    skinController.joint = bone.joint;
		                    
		                    if (!(Std.is( bone.parent.parent, Bone)))
		                    	rootBone = bone;
		                } else
		                	Debug.warning("no joint found for " + skinController.name);
		            }
		            
		            //geometry.rootBone = rootBone;
		            
		            for (skinController in skinControllers) {
		            	//skinController.inverseTransform = new Matrix3D();
		            	skinController.inverseTransform = child.parent.inverseSceneTransform;
		            }
				}
            }
		}	
    }
