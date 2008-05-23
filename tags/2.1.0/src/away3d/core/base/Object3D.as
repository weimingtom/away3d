package away3d.core.base
{
    import away3d.containers.*;
    import away3d.core.*;
    import away3d.core.draw.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.traverse.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.display.*;
    import flash.events.EventDispatcher;
    
	 /**
	 * Dispatched when the local transform matrix of the 3d object changes.
	 * 
	 * @eventType away3d.events.Object3DEvent
	 * @see	#transform
	 */
	[Event(name="transformchanged",type="away3d.events.Object3DEvent")]
	
	 /**
	 * Dispatched when the scene transform matrix of the 3d object changes.
	 * 
	 * @eventType away3d.events.Object3DEvent
	 * @see	#sceneTransform
	 */
	[Event(name="scenetransformchanged",type="away3d.events.Object3DEvent")]
			
	 /**
	 * Dispatched when the parent scene of the 3d object changes
	 * 
	 * @eventType away3d.events.Object3DEvent
	 * @see	#scene
	 */
	[Event(name="scenechanged",type="away3d.events.Object3DEvent")]
			
	 /**
	 * Dispatched when the bounding radius of the 3d object changes.
	 * 
	 * @eventType away3d.events.Object3DEvent
	 * @see	#radius
	 */
	[Event(name="radiuschanged",type="away3d.events.Object3DEvent")]
			
	 /**
	 * Dispatched when the bounding dimensions of the 3d object changes.
	 * 
	 * @eventType away3d.events.Object3DEvent
	 * @see	#minX
	 * @see	#maxX
	 * @see	#minY
	 * @see	#maxY
	 * @see	#minZ
	 * @see	#maxZ
	 */
	[Event(name="dimensionschanged",type="away3d.events.Object3DEvent")]
    			
	 /**
	 * Dispatched when a user moves the cursor while it is over the 3d object.
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseMove3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user presses the let hand mouse button while the cursor is over the 3d object.
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseDown3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user releases the let hand mouse button while the cursor is over the 3d object.
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseUp3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor over the 3d object.
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOver3D",type="away3d.events.MouseEvent3D")]
    			
	 /**
	 * Dispatched when a user moves the cursor away from the 3d object.
	 * 
	 * @eventType away3d.events.MouseEvent3D
	 */
	[Event(name="mouseOut3D",type="away3d.events.MouseEvent3D")]
	
    /**
    * Base class for all 3d objects.
    */
    public class Object3D extends EventDispatcher implements IClonable
    {
        use namespace arcane;
		/** @private */
        arcane var _transformDirty:Boolean;
        /** @private */
        arcane var _transform:Matrix3D = new Matrix3D();
        /** @private */
        arcane var _sceneTransformDirty:Boolean;
        /** @private */
        arcane var _sceneTransform:Matrix3D = new Matrix3D();
        /** @private */
        arcane function get parentradius():Number
        {
            //if (_transformDirty)   ???
            //    updateTransform();

            var x:Number = _transform.tx;
            var y:Number = _transform.ty;
            var z:Number = _transform.tz;
            return Math.sqrt(x*x + y*y + z*z) + boundingRadius;
        }
        /** @private */
        arcane function get parentmaxX():Number
        {
            return boundingRadius + _transform.tx;
        }
		/** @private */
        arcane function get parentminX():Number
        {
            return -boundingRadius + _transform.tx;
        }
		/** @private */
        arcane function get parentmaxY():Number
        {
            return boundingRadius + _transform.ty;
        }
		/** @private */
        arcane function get parentminY():Number
        {
            return -boundingRadius + _transform.ty;
        }
		/** @private */
        arcane function get parentmaxZ():Number
        {
            return boundingRadius + _transform.tz;
        }
		/** @private */
        arcane function get parentminZ():Number
        {
            return -boundingRadius + _transform.tz;
        }
        /** @private */
        arcane function notifyTransformChange():void
        {
        	_localTransformDirty = false;
        	
            if (!hasEventListener(Object3DEvent.TRANSFORM_CHANGED))
                return;

            if (!_transformchanged)
                _transformchanged = new Object3DEvent(Object3DEvent.TRANSFORM_CHANGED, this);
                
            dispatchEvent(_transformchanged);
        }
        /** @private */
        arcane function notifySceneTransformChange():void
        {
        	_sceneTransformDirty = false;
        	sceneTransformed = true;
        	
            if (!hasEventListener(Object3DEvent.SCENETRANSFORM_CHANGED))
                return;

            if (!_scenetransformchanged)
                _scenetransformchanged = new Object3DEvent(Object3DEvent.SCENETRANSFORM_CHANGED, this);
                
            dispatchEvent(_scenetransformchanged);
        }
        /** @private */       
        arcane function notifySceneChange():void
        {
            if (!hasEventListener(Object3DEvent.SCENE_CHANGED))
                return;

            if (!_scenechanged)
                _scenechanged = new Object3DEvent(Object3DEvent.SCENE_CHANGED, this);
                
            dispatchEvent(_scenechanged);
        }
        /** @private */
        arcane function notifyDimensionsChange():void
        {
            if (!hasEventListener(Object3DEvent.DIMENSIONS_CHANGED))
                return;
                
            if (!_dimensionschanged)
                _dimensionschanged = new Object3DEvent(Object3DEvent.DIMENSIONS_CHANGED, this);
                
            dispatchEvent(_dimensionschanged);
        }
        /** @private */
        arcane function notifyRadiusChange():void
        {
            if (!hasEventListener(Object3DEvent.RADIUS_CHANGED))
                return;
                
            if (!_radiuschanged)
                _radiuschanged = new Object3DEvent(Object3DEvent.RADIUS_CHANGED, this);
                
            dispatchEvent(_radiuschanged);
        }
        /** @private */
		arcane function dispatchMouseEvent(event:MouseEvent3D):Boolean
        {
            if (!hasEventListener(event.type))
                return false;

            dispatchEvent(event);

            return true;
        }
		
        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;
		
        private var _rotationDirty:Boolean;
        private var _rotationX:Number;
        private var _rotationY:Number;
        private var _rotationZ:Number;
        private var _localTransformDirty:Boolean;
        private var _scene:Scene3D;
        private var _parent:ObjectContainer3D;
		private var _quaternion:Quaternion = new Quaternion();
		private var _rot:Number3D;
        private var _position:Number3D = new Number3D();
        private var _scenePosition:Number3D = new Number3D();
        private var _ddo:DrawDisplayObject = new DrawDisplayObject();
        private var _sc:ScreenVertex = new ScreenVertex();
        private var _v:View3D;
        private var _c:DisplayObject;       		
		private var _vector:Number3D = new Number3D();
		private var _m:Matrix3D = new Matrix3D();
    	private var _xAxis:Number3D = new Number3D();
    	private var _yAxis:Number3D = new Number3D();
    	private var _zAxis:Number3D = new Number3D();        
        private var _transformchanged:Object3DEvent;
        private var _scenetransformchanged:Object3DEvent;
        private var _scenechanged:Object3DEvent;
        private var _dimensionschanged:Object3DEvent;
        private var _radiuschanged:Object3DEvent;
        
        private function updateTransform():void
        {
            if (!_transformDirty) 
                return;

            _quaternion.euler2quaternion(-_rotationY, -_rotationZ, _rotationX); // Swapped
            _transform.quaternion2matrix(_quaternion);
			
            //m.scale(_scaleX, _scaleY, _scaleZ); // !! WRONG !!
			
            _transformDirty = false;
            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }

        private function updateSceneTransform():void
        {
            if (!_sceneTransformDirty) 
                return;

            _sceneTransform.multiply(_parent.sceneTransform, transform);
            inverseSceneTransform.inverse(_sceneTransform);
            
            _sceneTransformDirty = false;
            notifySceneTransformChange();
        }
		
        private function updateRotation():void
        {
            _rot = _transform.matrix2euler();
            _rotationX = _rot.x * toRADIANS;
            _rotationY = _rot.y * toRADIANS;
            _rotationZ = _rot.z * toRADIANS;
    
            _rotationDirty = false;
        }

        private function onParentSceneChange(event:Object3DEvent):void
        {
            if (_scene == _parent.scene)
                return;

            _scene = _parent.scene;
            notifySceneChange();
        }

        private function onParentTransformChange(event:Object3DEvent):void
        {
            _sceneTransformDirty = true;
        }
		 
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		protected var ini:Init;
		
        public var projection:Projection = new Projection();
        public var inverseSceneTransform:Matrix3D = new Matrix3D();
        public var viewTransform:Matrix3D = new Matrix3D();
    	public var sceneTransformed:Boolean;
    	
    	/**
    	 * The render session used by the 3d object
    	 */
        public var session:AbstractRenderSession;
        
    	/**
    	 * Defines whether the 3d object is visible in the scene
    	 */
        public var visible:Boolean = true;
		
    	/**
    	 * An optional name string for the 3d object.
    	 * 
    	 * Can be used to access specific 3d object in a scene by calling the <code>getChildByName</code> method on the parent <code>ObjectContainer3D</code>.
    	 * 
    	 * @see away3d.containers.ObjectContainer3D#getChildByName()
    	 */
        public var name:String;
        
    	/**
    	 * An optional array of filters that can be applied to the 3d object.
    	 * 
    	 * Requires <code>ownCanvas</code> to be set to true.
    	 * 
    	 * @see #ownCanvas
    	 */
        public var filters:Array;
    	    
        
    	/**
    	 * An optional alpha value that can be applied to the 3d object.
    	 * 
    	 * Requires <code>ownCanvas</code> to be set to true.
    	 * 
    	 * @see #ownCanvas
    	 */
        public var alpha:Number;
        
    	/**
    	 * An optional blend mode that can be applied to the 3d object.
    	 * 
    	 * Requires <code>ownCanvas</code> to be set to true.
    	 * 
    	 * @see #ownCanvas
    	 */
        public var blendMode:String;
        
    	/**
    	 * An optional untyped object that can contain used-defined properties
    	 */
        public var extra:Object;

    	/**
    	 * Defines whether mouse events are received on the 3d object
    	 */
        public var mouseEnabled:Boolean = true;
        
    	/**
    	 * Defines whether a hand cursor is displayed when the mouse rolls over the 3d object.
    	 */
        public var useHandCursor:Boolean = false;

    	/**
    	 * Defines whether the contents of the 3d object are rendered inside it's own sprite
    	 */
        public var ownCanvas:Boolean = false;
        
    	/**
    	 * Defines whether the contents of the 3d object are rendered using it's own render session
    	 */
        public var ownSession:AbstractRenderSession;
        
    	/**
    	 * Returns the bounding radius of the 3d object
    	 */
        public function get boundingRadius():Number
        {
            return 0;
        }
        
    	/**
    	 * Returns the maximum x value of the 3d object
    	 * 
    	 * @see	#x
    	 */
        public function get maxX():Number
        {
            return boundingRadius;
        }
        
    	/**
    	 * Returns the minimum x value of the 3d object
    	 * 
    	 * @see	#x
    	 */
        public function get minX():Number
        {
            return -boundingRadius;
        }
        
    	/**
    	 * Returns the maximum y value of the 3d object
    	 * 
    	 * @see	#y
    	 */
        public function get maxY():Number
        {
            return boundingRadius;
        }
        
    	/**
    	 * Returns the minimum y value of the 3d object
    	 * 
    	 * @see	#y
    	 */
        public function get minY():Number
        {
            return -boundingRadius;
        }
        
    	/**
    	 * Returns the maximum z value of the 3d object
    	 * 
    	 * @see	#z
    	 */
        public function get maxZ():Number
        {
            return boundingRadius;
        }
        
    	/**
    	 * Returns the minimum z value of the 3d object
    	 * 
    	 * @see	#z
    	 */
        public function get minZ():Number
        {
            return -boundingRadius;
        }
		
    	/**
    	 * Defines the x coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get x():Number
        {
            return _transform.tx;
        }
    
        public function set x(value:Number):void
        {
            if (isNaN(value))
                throw new Error("isNaN(x)");

            if (value == Infinity)
                Debug.warning("x == Infinity");

            if (value == -Infinity)
                Debug.warning("x == -Infinity");

            _transform.tx = value;

            _sceneTransformDirty = true;
			_localTransformDirty = true;
        }
		
    	/**
    	 * Defines the y coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get y():Number
        {
            return _transform.ty;
        }
    
        public function set y(value:Number):void
        {
            if (isNaN(value))
                throw new Error("isNaN(y)");

            if (value == Infinity)
                Debug.warning("y == Infinity");

            if (value == -Infinity)
                Debug.warning("y == -Infinity");

            _transform.ty = value;

            _sceneTransformDirty = true;
			_localTransformDirty = true;
        }
		
    	/**
    	 * Defines the z coordinate of the 3d object relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get z():Number
        {
            return _transform.tz;
        }
    
        public function set z(value:Number):void
        {
            if (isNaN(value))
                throw new Error("isNaN(z)");

            if (value == Infinity)
                Debug.warning("z == Infinity");

            if (value == -Infinity)
                Debug.warning("z == -Infinity");

            _transform.tz = value;

            _sceneTransformDirty = true;
			_localTransformDirty = true;
        }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the x-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get rotationX():Number
        {
            if (_rotationDirty) 
                updateRotation();
    
            return -_rotationX * toDEGREES;
        }
    
        public function set rotationX(rot:Number):void
        {
            _rotationX = -rot * toRADIANS;

            _transformDirty = true;
        }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the y-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get rotationY():Number
        {
            if (_rotationDirty) 
                updateRotation();
    
            return -_rotationY * toDEGREES;
        }
    
        public function set rotationY(rot:Number):void
        {
            _rotationY = -rot * toRADIANS;

            _transformDirty = true;
        }
		
    	/**
    	 * Defines the euler angle of rotation of the 3d object around the z-axis, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get rotationZ():Number
        {
            if (_rotationDirty) 
                updateRotation();
    
            return -_rotationZ * toDEGREES;
        }
    
        public function set rotationZ(rot:Number):void
        {
            _rotationZ = -rot * toRADIANS;

            _transformDirty = true;
        }
		
    	/**
    	 * Defines the position of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get position():Number3D
        {
        	if (_transformDirty) 
                updateTransform();
            
        	_position.x = _transform.tx;
        	_position.y = _transform.ty;
        	_position.z = _transform.tz;
            return _position;
        }

        public function set position(value:Number3D):void
        {
            _transform.tx = value.x;
            _transform.ty = value.y;
            _transform.tz = value.z;

            _sceneTransformDirty = true;
			_localTransformDirty = true;
        }
		
    	/**
    	 * Defines the transformation of the 3d object, relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
    	 */
        public function get transform():Matrix3D
        {
            if (_transformDirty) 
                updateTransform();

            return _transform;
        }

        public function set transform(value:Matrix3D):void
        {
            if (value == _transform)
                return;

            _transform.clone(value);

            _transformDirty = false;
            _rotationDirty = true;
            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }
		
    	/**
    	 * Defines the parent of the 3d object.
    	 */
        public function get parent():ObjectContainer3D
        {
            return _parent;
        }
		
        public function set parent(value:ObjectContainer3D):void
        {
            if (value == _parent)
                return;

            var oldscene:Scene3D = scene;

            if (_parent != null)
            {
                _parent.removeOnSceneChange(onParentSceneChange);
                _parent.internalRemoveChild(this);
            }

            _parent = value;

            if (_parent != null)
            {
                _parent.internalAddChild(this);
                _parent.addOnSceneChange(onParentSceneChange);
                _parent.addOnSceneTransformChange(onParentTransformChange);
            }

            _scene = _parent ? _parent.scene : null;

            if (_scene != oldscene)
                notifySceneChange();

            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }
        
    	/**
    	 * Returns the transformation of the 3d object, relative to the global coordinates of the <code>Scene3D</code>.
    	 */
        public function get sceneTransform():Matrix3D
        {
        	sceneTransformed = false;
        	
        	//for camera transforms
            if (_scene == null) {
            	if (_transformDirty)
            		 _sceneTransformDirty = true;
            	if (_sceneTransformDirty) {
            		_sceneTransformDirty = false;
            		notifySceneTransformChange();
            	}
                return transform;
            }

            if (_transformDirty) 
                updateTransform();

            if (_sceneTransformDirty) 
                updateSceneTransform();
			
			if (_localTransformDirty)
				notifyTransformChange();
			
            return _sceneTransform;
        }
		
    	/**
    	 * Returns the position of the 3d object, relative to the global coordinates of the <code>Scene3D</code>.
    	 */
        public function get scenePosition():Number3D
        {
        	_scenePosition.x = sceneTransform.tx;
        	_scenePosition.y = sceneTransform.ty;
        	_scenePosition.z = sceneTransform.tz;
            return _scenePosition;
        }
		
    	/**
    	 * Returns the parent scene of the 3d object
    	 */
        public function get scene():Scene3D
        {
            return _scene;
        }
        
    	/**
    	 * @private
    	 */
        public function Object3D(init:Object = null):void
        {
            ini = Init.parse(init);

            name = ini.getString("name", name);
            ownCanvas = ini.getBoolean("ownCanvas", ownCanvas);
            ownSession = ini.getObject("ownSession", AbstractRenderSession) as AbstractRenderSession;
            visible = ini.getBoolean("visible", visible);
            mouseEnabled = ini.getBoolean("mouseEnabled", mouseEnabled);
            useHandCursor = ini.getBoolean("useHandCursor", useHandCursor);
            filters = ini.getArray("filters");
            alpha = ini.getNumber("alpha", 1);
            
            x = ini.getNumber("x", 0);
            y = ini.getNumber("y", 0);
            z = ini.getNumber("z", 0);
            
            rotationX = ini.getNumber("rotationX", 0);
            rotationY = ini.getNumber("rotationY", 0);
            rotationZ = ini.getNumber("rotationZ", 0);

            extra = ini.getObject("extra");

            parent = ini.getObject3D("parent") as ObjectContainer3D;
			
			if (ownSession)
				ownCanvas = true;
			
            /*
            var scaling:Number = init.getNumber("scale", 1);

            scaleX(init.getNumber("scaleX", 1) * scaling);
            scaleY(init.getNumber("scaleY", 1) * scaling);
            scaleZ(init.getNumber("scaleZ", 1) * scaling);
            */
            
            if (this is Scene3D)
                _scene = this as Scene3D;
        }
		
    	/**
    	 * Scales the contents of the 3d object.
    	 * 
    	 * @param	scale	The scaling value
    	 */
        public function scale(scale:Number):void
        {
        	//overridden
        }
		
    	/**
    	 * Calulates the absolute distance between the local 3d object position and the position of the given 3d object
    	 * 
    	 * @param	obj		The 3d object to use for calulating the distance
    	 * @return			The scalar distance between objects
    	 * 
    	 * @see	#position
    	 */
        public function distanceTo(obj:Object3D):Number
        {
            var m1:Matrix3D = scene == null ? transform : sceneTransform;
            var m2:Matrix3D = obj.scene == null ? obj.transform : obj.sceneTransform;

            var dx:Number = m1.tx - m2.tx;
            var dy:Number = m1.ty - m2.ty;
            var dz:Number = m1.tz - m2.tz;
    
            return Math.sqrt(dx*dx + dy*dy + dz*dz);
        }
    	
    	/**
    	 * Used when traversing the scenegraph
    	 * 
    	 * @param	tranverser		The traverser object
    	 * 
    	 * @see	away3d.core.traverse.BlockerTraverser
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.traverse.ProjectionTraverser
    	 * @see	away3d.core.traverse.TickTraverser
    	 */
        public function traverse(traverser:Traverser):void
        {
            if (traverser.match(this))
            {
                traverser.enter(this);
                traverser.apply(this);
                traverser.leave(this);
            }
        }
    	/**
    	 * Called from the <code>PrimitiveTraverser</code> when passing <code>DrawPrimitive</code> objects to the primitive consumer object
    	 * 
    	 * @param	consumer	The consumer instance
    	 * @param	session		The render session of the 3d object
    	 * 
    	 * @see	away3d.core.traverse.PrimitiveTraverser
    	 * @see	away3d.core.draw.DrawPrimitive
    	 */
        public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
            _v = session.view;
            if (ownCanvas) {
                if (!ownSession)
                	ownSession = new SpriteRenderSession();
                session.registerChildSession(ownSession);
                
                ownSession.view = _v;
                _c = ownSession.getContainer(_v);
                _c.filters = filters;
                _c.alpha = alpha;
                
                if (blendMode != null)
                	_c.blendMode = blendMode;
                else
                	_c.blendMode = BlendMode.NORMAL;
                ownSession.lightarray = session.lightarray;
                this.session = ownSession;
             	
             	_sc.x = _c.x;
             	_sc.y = _c.y;
             	_sc.z = Math.sqrt(viewTransform.tz*viewTransform.tz + viewTransform.tx + viewTransform.tx + viewTransform.ty*viewTransform.ty);
             	
             	_ddo.source = this;
             	_ddo.screenvertex = _sc;
             	_ddo.displayobject = _c;
             	_ddo.session = session;
             	_ddo.calc();
             	
                consumer.primitive(_ddo);
            }
            else
            {                
                this.session = session;
            } 
        }
        
        /**
        * Moves the 3d object forwards along it's local z axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveForward(distance:Number):void 
        { 
            translate(Number3D.FORWARD, distance); 
        }
        
        /**
        * Moves the 3d object backwards along it's local z axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveBackward(distance:Number):void 
        { 
            translate(Number3D.BACKWARD, distance); 
        }
        
        /**
        * Moves the 3d object backwards along it's local x axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveLeft(distance:Number):void 
        { 
            translate(Number3D.LEFT, distance); 
        }
        
        /**
        * Moves the 3d object forwards along it's local x axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveRight(distance:Number):void 
        { 
            translate(Number3D.RIGHT, distance); 
        }
        
        /**
        * Moves the 3d object forwards along it's local y axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveUp(distance:Number):void 
        { 
            translate(Number3D.UP, distance); 
        }
        
        /**
        * Moves the 3d object backwards along it's local y axis
        * 
        * @param	distance	The length of the movement
        */
        public function moveDown(distance:Number):void 
        { 
            translate(Number3D.DOWN, distance); 
        }
        
        /**
        * Moves the 3d object directly to a point in space
        * 
        * @param	target		A vector defining the new position of the 3d object
        */
        public function moveTo(target:Number3D):void
        {
            _transform.tx = target.x;
            _transform.ty = target.y;
            _transform.tz = target.z;
            
            _localTransformDirty = true;
        }
		
		/**
		 * Moves the 3d object along a vector by a defined length
		 * 
		 * @param	axis		The vector defining the axis of movement
		 * @param	distance	The length of the movement
		 */
        public function translate(axis:Number3D, distance:Number):void
        {
            _vector.rotate(axis, transform);
    
            x += distance * _vector.x;
            y += distance * _vector.y;
            z += distance * _vector.z;
        }
        
        /**
        * Rotates the 3d object around it's local x-axis
        * 
        * @param	angle		The amount of rotation in degrees
        */
        public function pitch(angle:Number):void
        {
            rotate(Number3D.RIGHT, angle);
        }
        
        /**
        * Rotates the 3d object around it's local y-axis
        * 
        * @param	angle		The amount of rotation in degrees
        */
        public function yaw(angle:Number):void
        {
            rotate(Number3D.UP, angle);
        }
        
        /**
        * Rotates the 3d object around it's local z-axis
        * 
        * @param	angle		The amount of rotation in degrees
        */
        public function roll(angle:Number):void
        {
            rotate(Number3D.FORWARD, angle);
        }
		
		/**
		 * Rotates the 3d object around an axis by a defined angle
		 * 
		 * @param	axis		The vector defining the axis of rotation
		 * @param	angle		The amount of rotation in degrees
		 */
        public function rotate(axis:Number3D, angle:Number):void
        {
            _vector.rotate(axis, transform);
            _m.rotationMatrix(_vector.x, _vector.y, _vector.z, angle * toRADIANS);
    		_m.tx = _transform.tx;
    		_m.ty = _transform.ty;
    		_m.tz = _transform.tz;
    		_transform.multiply3x3(_m, transform);
    
            _rotationDirty = true;
            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }

		
		/**
		 * Rotates the 3d object around to face a point defined relative to the local coordinates of the parent <code>ObjectContainer3D</code>.
		 * 
		 * @param	target		The vector defining the point to be looked at
		 * @param	upAxis		An optional vector used to define the desired up orientation of the 3d object after rotation has occurred
		 */
        public function lookAt(target:Number3D, upAxis:Number3D = null):void
        {
            _zAxis.sub(target, position);
            _zAxis.normalize();
    
            if (_zAxis.modulo > 0.1 && (_zAxis.x != _transform.sxz || _zAxis.y != _transform.syz || _zAxis.z != _transform.szz))
            {
                _xAxis.cross(_zAxis, upAxis || Number3D.UP);
                _xAxis.normalize();
    
                _yAxis.cross(_zAxis, _xAxis);
                _yAxis.normalize();
    
                _transform.sxx = _xAxis.x;
                _transform.syx = _xAxis.y;
                _transform.szx = _xAxis.z;
    
                _transform.sxy = -_yAxis.x;
                _transform.syy = -_yAxis.y;
                _transform.szy = -_yAxis.z;
    
                _transform.sxz = _zAxis.x;
                _transform.syz = _zAxis.y;
                _transform.szz = _zAxis.z;
    
                _transformDirty = false;
                _rotationDirty = true;
                _sceneTransformDirty = true;
                _localTransformDirty = true;
                // TODO: Implement scale
            }
            else
            {
                //throw new Error("lookAt Error");
            }
        }
		
		/**
		 * Used to trace the values of a 3d object.
		 * 
		 * @return A string representation of the 3d object.
		 */
        public override function toString():String
        {
            return (name ? name : "$") + ': x:' + Math.round(x) + ' y:' + Math.round(y) + ' z:' + Math.round(z);
        }
		
		/**
		 * Called by the <code>TickTraverser</code>.
		 * 
		 * Can be overridden to provide updates to the 3d object based on individual render calls from the renderer.
		 * 
		 * @param	time		The absolute time at the start of the render cycle
		 * 
		 * @see away3d.core.traverse.TickTraverser
		 */
        public function tick(time:int):void
        {
        }
		
		/**
		 * Duplicates the 3d object's properties to another <code>Object3D</code> object
		 * 
		 * @param	object	[optional]	The new object instance into which all properties are copied
		 * @return						The new object instance with duplicated properties applied
		 */
        public function clone(object:* = null):*
        {
            var object3D:Object3D = object || new Object3D();
            object3D.transform = transform;
            object3D.name = name;
            object3D.visible = visible;
            object3D.mouseEnabled = mouseEnabled;
            object3D.useHandCursor = useHandCursor;
            object3D.extra = (extra is IClonable) ? (extra as IClonable).clone() : extra;
            return object3D;
        }
		
		/**
		 * Default method for adding a transformchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnTransformChange(listener:Function):void
        {
            addEventListener(Object3DEvent.TRANSFORM_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a transformchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnTransformChange(listener:Function):void
        {
            removeEventListener(Object3DEvent.TRANSFORM_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a scenetransformchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
		public function addOnSceneTransformChange(listener:Function):void
        {
            addEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a scenetransformchanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSceneTransformChange(listener:Function):void
        {
            removeEventListener(Object3DEvent.SCENETRANSFORM_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a scenechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnSceneChange(listener:Function):void
        {
            addEventListener(Object3DEvent.SCENE_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a scenechanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnSceneChange(listener:Function):void
        {
            removeEventListener(Object3DEvent.SCENE_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a radiuschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnRadiusChange(listener:Function):void
        {
            addEventListener(Object3DEvent.RADIUS_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a radiuschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnRadiusChange(listener:Function):void
        {
            removeEventListener(Object3DEvent.RADIUS_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a dimensionschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnDimensionsChange(listener:Function):void
        {
            addEventListener(Object3DEvent.DIMENSIONS_CHANGED, listener, false, 0, true);
        }
		
		/**
		 * Default method for removing a dimensionschanged event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnDimensionsChange(listener:Function):void
        {
            removeEventListener(Object3DEvent.DIMENSIONS_CHANGED, listener, false);
        }
		
		/**
		 * Default method for adding a mouseMove3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseMove3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }
		
		/**
		 * Default method for adding a mouseDown3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseDown3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }
		
		/**
		 * Default method for adding a mouseUp3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseUp3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
		
		/**
		 * Default method for adding a mouseOver3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseOver3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }
		
		/**
		 * Default method for adding a mouseOut3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
		
		/**
		 * Default method for removing a mouseOut3D event listener
		 * 
		 * @param	listener		The listener function
		 */
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }
    }
}
