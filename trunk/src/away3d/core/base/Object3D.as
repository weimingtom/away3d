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
    import flash.utils.Dictionary;
    
    
    public class Object3D extends LazyEventDispatcher implements IClonable
    {
        use namespace arcane;

        arcane var _transformDirty:Boolean;
        arcane var _transform:Matrix3D = new Matrix3D();

        private var _rotationDirty:Boolean;

        private var _rotationX:Number;
        private var _rotationY:Number;
        private var _rotationZ:Number;
    	
        arcane var _sceneTransformDirty:Boolean;
        private var _localTransformDirty:Boolean;
        arcane var _sceneTransform:Matrix3D = new Matrix3D();
        
        public var projection:Projection = new Projection();
        public var inverseSceneTransform:Matrix3D = new Matrix3D();
        public var viewTransform:Matrix3D = new Matrix3D();
    	public var sceneTransformed:Boolean;
        public var session:AbstractRenderSession;
        
        private var _scene:Scene3D;

        private var _parent:ObjectContainer3D;

        // Whether or not the display object is visible.
        public var visible:Boolean = true;
    
        // An optional object name.
        public var name:String;
        
        //an optional canvas dictionary for the object in each view
        public var canvas:Dictionary = new Dictionary();
            
        //an optional filters array that can be applied to the canvas
        public var filters:Array;
    	    
        //an optional alpha property that can be applied to the canvas
        public var alpha:Number;
        
        //an optional blendMode that can be applied to the canvas
        public var blendMode:String;
        
        // An object that contains user defined properties.
        public var extra:Object;

        // Are the mouse events allowed
        public var mouseEnabled:Boolean = true;
        
        //use hand cursor when mouse is over object
        public var useHandCursor:Boolean = false;
        
        public var ownCanvas:Boolean = false;
        public var ownSession:AbstractRenderSession;
        
        public function get radius():Number
        {
            return 0;
        }
        
        public function get maxX():Number
        {
            return radius;
        }
        
        public function get minX():Number
        {
            return -radius;
        }
        
        public function get maxY():Number
        {
            return radius;
        }
        
        public function get minY():Number
        {
            return -radius;
        }
        
        public function get maxZ():Number
        {
            return radius;
        }
        
        public function get minZ():Number
        {
            return -radius;
        }
        
        arcane function get parentradius():Number
        {
            //if (_transformDirty)   ???
            //    updateTransform();

            var x:Number = _transform.tx;
            var y:Number = _transform.ty;
            var z:Number = _transform.tz;
            return Math.sqrt(x*x + y*y + z*z) + radius;
        }

        arcane function get parentmaxX():Number
        {
            return radius + _transform.tx;
        }

        arcane function get parentminX():Number
        {
            return -radius + _transform.tx;
        }

        arcane function get parentmaxY():Number
        {
            return radius + _transform.ty;
        }

        arcane function get parentminY():Number
        {
            return -radius + _transform.ty;
        }

        arcane function get parentmaxZ():Number
        {
            return radius + _transform.tz;
        }

        arcane function get parentminZ():Number
        {
            return -radius + _transform.tz;
        }

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
		
		internal var rot:Number3D;
		
        private function updateRotation():void
        {
            rot = _transform.matrix2euler();
            _rotationX = rot.x * toRADIANS;
            _rotationY = rot.y * toRADIANS;
            _rotationZ = rot.z * toRADIANS;
    
            _rotationDirty = false;
        }
    
        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;

        public function set position(value:Number3D):void
        {
            _transform.tx = value.x;
            _transform.ty = value.y;
            _transform.tz = value.z;

            _sceneTransformDirty = true;
			_localTransformDirty = true;
        }
        
        internal var _position:Number3D = new Number3D();
        
        public function get position():Number3D
        {
        	if (_transformDirty) 
                updateTransform();
            
        	_position.x = _transform.tx;
        	_position.y = _transform.ty;
        	_position.z = _transform.tz;
            return _position;
        }

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
		
		internal var q:Quaternion = new Quaternion();

		
        private function updateTransform():void
        {
            if (!_transformDirty) 
                return;

            q.euler2quaternion(-_rotationY, -_rotationZ, _rotationX); // Swapped
            _transform.quaternion2matrix(q);
			
            //m.scale(_scaleX, _scaleY, _scaleZ); // !! WRONG !!
			
            _transformDirty = false;
            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }
    
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

        private function updateSceneTransform():void
        {
            if (!_sceneTransformDirty) 
                return;

            _sceneTransform.multiply(_parent.sceneTransform, transform);
            inverseSceneTransform.inverse(_sceneTransform);
            
            _sceneTransformDirty = false;
            notifySceneTransformChange();
        }
    
        public function get scenePosition():Number3D
        {
            return new Number3D(sceneTransform.tx, sceneTransform.ty, sceneTransform.tz);
        }

        public function Object3D(init:Object = null):void
        {
            init = Init.parse(init);

            name = (init as Init).getString("name", name);
            ownCanvas = (init as Init).getBoolean("ownCanvas", ownCanvas);
            ownSession = (init as Init).getObject("ownSession", AbstractRenderSession) as AbstractRenderSession;
            visible = (init as Init).getBoolean("visible", visible);
            mouseEnabled = (init as Init).getBoolean("mouseEnabled", mouseEnabled);
            useHandCursor = (init as Init).getBoolean("useHandCursor", useHandCursor);
            filters = (init as Init).getArray("filters");
            
            x = (init as Init).getNumber("x", 0);
            y = (init as Init).getNumber("y", 0);
            z = (init as Init).getNumber("z", 0);
            
            rotationX = (init as Init).getNumber("rotationX", 0);
            rotationY = (init as Init).getNumber("rotationY", 0);
            rotationZ = (init as Init).getNumber("rotationZ", 0);

            extra = (init as Init).getObject("extra");

            parent = (init as Init).getObject3D("parent") as ObjectContainer3D;
			
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
        
        public function scale(scale:Number):void
        {
        	//overridden
        }
        
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

        public function get scene():Scene3D
        {
            return _scene;
        }

        public function distanceTo(obj:Object3D):Number
        {
            var m1:Matrix3D = scene == null ? transform : sceneTransform;
            var m2:Matrix3D = obj.scene == null ? obj.transform : obj.sceneTransform;

            var dx:Number = m1.tx - m2.tx;
            var dy:Number = m1.ty - m2.ty;
            var dz:Number = m1.tz - m2.tz;
    
            return Math.sqrt(dx*dx + dy*dy + dz*dz);
        }
    
        public function traverse(traverser:Traverser):void
        {
            if (traverser.match(this))
            {
                traverser.enter(this);
                traverser.apply(this);
                traverser.leave(this);
            }
        }
        
        internal var v:View3D;
        internal var c:Sprite;
        
        public function primitives(consumer:IPrimitiveConsumer, session:AbstractRenderSession):void
        {
        	// TODO: Canvas should match original render session
            v = session.view;
            if (ownCanvas) {
                if (!ownSession)
                	ownSession = session.clone();
                session.registerChildSession(ownSession);
                
                ownSession.view = v;
                ownSession.container.filters = filters;
                ownSession.container.alpha = alpha;
                
                if (blendMode != null)
                	ownSession.container.blendMode = blendMode;
                else
                	ownSession.container.blendMode = BlendMode.NORMAL;
                ownSession.lightarray = session.lightarray;
                this.session = ownSession;
             	
                consumer.primitive(new DrawDisplayObject(this, ownSession.container, new ScreenVertex(ownSession.container.x, ownSession.container.y, Math.sqrt(viewTransform.tz*viewTransform.tz + viewTransform.tx + viewTransform.tx + viewTransform.ty*viewTransform.ty)), session));
            }
            else
            {                
                this.session = session;
            } 
        }
        
        public function moveForward(distance:Number):void 
        { 
            translate(Number3D.FORWARD, distance); 
        }
    
        public function moveBackward(distance:Number):void 
        { 
            translate(Number3D.BACKWARD, distance); 
        }
    
        public function moveLeft(distance:Number):void 
        { 
            translate(Number3D.LEFT, distance); 
        }
    
        public function moveRight(distance:Number):void 
        { 
            translate(Number3D.RIGHT, distance); 
        }
    
        public function moveUp(distance:Number):void 
        { 
            translate(Number3D.UP, distance); 
        }
    
        public function moveDown(distance:Number):void 
        { 
            translate(Number3D.DOWN, distance); 
        }
    
        public function moveTo(target:Number3D):void
        {
            _transform.tx = target.x;
            _transform.ty = target.y;
            _transform.tz = target.z;
            
            _localTransformDirty = true;
        }

        public function translate(axis:Number3D, distance:Number):void
        {
            vector.rotate(axis, transform);
    
            x += distance * vector.x;
            y += distance * vector.y;
            z += distance * vector.z;
        }
    
        public function pitch(angle:Number):void
        {
            rotate(Number3D.RIGHT, angle);
        }

        public function yaw(angle:Number):void
        {
            rotate(Number3D.UP, angle);
        }
    
        public function roll(angle:Number):void
        {
            rotate(Number3D.FORWARD, angle);
        }
		
		internal var vector:Number3D = new Number3D();
		internal var m:Matrix3D = new Matrix3D();
		
        public function rotate(axis:Number3D, angle:Number):void
        {
            vector.rotate(axis, transform);
            m.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    		m.tx = _transform.tx;
    		m.ty = _transform.ty;
    		m.tz = _transform.tz;
    		_transform.multiply3x3(m, transform);
    
            _rotationDirty = true;
            _sceneTransformDirty = true;
            _localTransformDirty = true;
        }

    	internal var xAxis:Number3D = new Number3D();
    	internal var yAxis:Number3D = new Number3D();
    	internal var zAxis:Number3D = new Number3D();
        // Make the object look at a specific position.
        // @param target Position to look at.
        // @param upAxis The vertical axis of the universe. Normally the positive Y axis.
        public function lookAt(target:Number3D, upAxis:Number3D = null):void
        {
            zAxis.sub(target, position);
            zAxis.normalize();
    
            if (zAxis.modulo > 0.1 && (zAxis.x != _transform.sxz || zAxis.y != _transform.syz || zAxis.z != _transform.szz))
            {
                xAxis.cross(zAxis, upAxis || Number3D.UP);
                xAxis.normalize();
    
                yAxis.cross(zAxis, xAxis);
                yAxis.normalize();
    
                _transform.sxx = xAxis.x;
                _transform.syx = xAxis.y;
                _transform.szx = xAxis.z;
    
                _transform.sxy = -yAxis.x;
                _transform.syy = -yAxis.y;
                _transform.szy = -yAxis.z;
    
                _transform.sxz = zAxis.x;
                _transform.syz = zAxis.y;
                _transform.szz = zAxis.z;
    
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

        public function toString():String
        {
            return (name ? name : "$") + ': x:' + Math.round(x) + ' y:' + Math.round(y) + ' z:' + Math.round(z);
        }
    
        public function tick(time:int):void
        {
        }

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

        public function addOnTransformChange(listener:Function):void
        {
            addEventListener("transformchanged", listener, false, 0, true);
        }
        public function removeOnTransformChange(listener:Function):void
        {
            removeEventListener("transformchanged", listener, false);
        }
        
        private var transformchanged:Object3DEvent;
        
        protected function notifyTransformChange():void
        {
        	_localTransformDirty = false;
        	
            if (!hasEventListener("transformchanged"))
                return;

            if (transformchanged == null)
                transformchanged = new Object3DEvent("transformchanged", this);
                
            dispatchEvent(transformchanged);
        }
        
		public function addOnSceneTransformChange(listener:Function):void
        {
            addEventListener("scenetransformchanged", listener, false, 0, true);
        }
        public function removeOnSceneTransformChange(listener:Function):void
        {
            removeEventListener("scenetransformchanged", listener, false);
        }
        
		private var scenetransformchanged:Object3DEvent;
        
        protected function notifySceneTransformChange():void
        {
        	_sceneTransformDirty = false;
        	sceneTransformed = true;
        	
            if (!hasEventListener("scenetransformchanged"))
                return;

            if (scenetransformchanged == null)
                scenetransformchanged = new Object3DEvent("scenetransformchanged", this);
                
            dispatchEvent(scenetransformchanged);
        }
        
        public function addOnSceneChange(listener:Function):void
        {
            addEventListener("scenechanged", listener, false, 0, true);
        }
        public function removeOnSceneChange(listener:Function):void
        {
            removeEventListener("scenechanged", listener, false);
        }
        
        private var scenechanged:Object3DEvent;
        
        protected function notifySceneChange():void
        {
            if (!hasEventListener("scenechanged"))
                return;

            if (scenechanged == null)
                scenechanged = new Object3DEvent("scenechanged", this);
                
            dispatchEvent(scenechanged);
        }

        public function addOnRadiusChange(listener:Function):void
        {
            addEventListener("radiuschanged", listener, false, 0, true);
        }
        public function removeOnRadiusChange(listener:Function):void
        {
            removeEventListener("radiuschanged", listener, false);
        }
        private var radiuschanged:Object3DEvent;
        protected function notifyRadiusChange():void
        {
            if (!hasEventListener("radiuschanged"))
                return;
                
            if (radiuschanged == null)
                radiuschanged = new Object3DEvent("radiuschanged", this);
                
            dispatchEvent(radiuschanged);
        }

        public function addOnDimensionsChange(listener:Function):void
        {
            addEventListener("dimensionschanged", listener, false, 0, true);
        }
        public function removeOnDimensionsChange(listener:Function):void
        {
            removeEventListener("dimensionschanged", listener, false);
        }
        private var dimensionschanged:Object3DEvent;
        protected function notifyDimensionsChange():void
        {
            if (!hasEventListener("dimensionschanged"))
                return;
                
            if (dimensionschanged == null)
                dimensionschanged = new Object3DEvent("dimensionschanged", this);
                
            dispatchEvent(dimensionschanged);
        }

        public function addOnMouseMove(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_MOVE, listener, false, 0, false);
        }
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_MOVE, listener, false);
        }

        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_DOWN, listener, false, 0, false);
        }
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_DOWN, listener, false);
        }

        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_UP, listener, false, 0, false);
        }
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_UP, listener, false);
        }
        
        public function addOnMouseOver(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OVER, listener, false, 0, false);
        }
        public function removeOnMouseOver(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OVER, listener, false);
        }

        public function addOnMouseOut(listener:Function):void
        {
            addEventListener(MouseEvent3D.MOUSE_OUT, listener, false, 0, false);
        }
        public function removeOnMouseOut(listener:Function):void
        {
            removeEventListener(MouseEvent3D.MOUSE_OUT, listener, false);
        }
        
        arcane function dispatchMouseEvent(event:MouseEvent3D):Boolean
        {
            if (!hasEventListener(event.type))
                return false;

            dispatchEvent(event);

            return true;
        }
    }
}
