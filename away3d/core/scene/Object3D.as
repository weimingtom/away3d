package away3d.core.scene
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.utils.*;

    import flash.events.MouseEvent;
    
    public class Object3D extends LazyEventDispatcher
    {
        use namespace arcane;

        private var _transformDirty:Boolean;
        private var _transform:Matrix3D = new Matrix3D();

        private var _rotationDirty:Boolean;

        private var _rotationX:Number;
        private var _rotationY:Number;
        private var _rotationZ:Number;
    
        private var _worldDirty:Boolean;
        private var _world:Matrix3D;

        private var _scene:Scene3D;

        private var _parent:ObjectContainer3D;

        // Whether or not the display object is visible.
        public var visible:Boolean;
    
        // An optional object name.
        public var name:String;
    
        // An object that contains user defined properties.
        public var extra:Object;

        // Are the mouse events allowed
        public var mousable:Boolean;

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

            _worldDirty = true;

            notifyTransformChange();
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

            _worldDirty = true;

            notifyTransformChange();
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

            _worldDirty = true;

            notifyTransformChange();
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

            notifyTransformChange();
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

            notifyTransformChange();
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

            notifyTransformChange();
        }
    
        private function updateRotation():void
        {
            var rot:Number3D = Matrix3D.matrix2euler(_transform);
            _rotationX = rot.x * toRADIANS;
            _rotationY = rot.y * toRADIANS;
            _rotationZ = rot.z * toRADIANS;
    
            _rotationDirty = false;
        }
    
        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;

        public function get position():Number3D
        {
            return new Number3D(_transform.tx, _transform.ty, _transform.tz);
        }

        public function get transform():Matrix3D
        {
            if (_transformDirty) 
                updateTransform();

            return _transform;
        }

        public function set transform(value:Matrix3D):void
        {
            _transform = value.clone();

            _transformDirty = false;
            _rotationDirty = true;

            notifyTransformChange();
        }

        private function updateTransform():void
        {
            if (!_transformDirty) 
                return;

            var q:Quaternion = Matrix3D.euler2quaternion(-_rotationY, -_rotationZ, _rotationX); // Swapped
            var m:Matrix3D = Matrix3D.quaternion2matrix(q.x, q.y, q.z, q.w);

            m.tx = _transform.tx;
            m.ty = _transform.ty;
            m.tz = _transform.tz;
            //m.scale(_scaleX, _scaleY, _scaleZ); // !! WRONG !!

            _transform = m;
            _transformDirty = false;
            _worldDirty = true;
        }
    
        public function get world():Matrix3D
        {
            if (_scene == null)
                Debug.error("Can't access world transform of an object not belonging to the scene");

            if (_transformDirty) 
                updateTransform();

            if (_worldDirty) 
                updateWorld();

            return _world;
        }

        private function updateWorld():void
        {
            if (!_worldDirty) 
                return;

            _world = Matrix3D.multiply(_parent.world, transform);

            _worldDirty = false;
        }
    
        public function get worldPosition():Number3D
        {
            return new Number3D(world.tx, world.ty, world.tz);
        }

        public function Object3D(init:Object = null):void
        {
            init = Init.parse(init);

            name = init.getString("name", null);

            visible = init.getBoolean("visible", true);
            mousable = init.getBoolean("mousable", true);
                                           
            x = init.getNumber("x", 0);
            y = init.getNumber("y", 0);
            z = init.getNumber("z", 0);
            
            rotationX = init.getNumber("rotationX", 0);
            rotationY = init.getNumber("rotationY", 0);
            rotationZ = init.getNumber("rotationZ", 0);

            extra = init.getObject("extra");

            parent = init.getObject3D("parent") as ObjectContainer3D;

            /*
            var scaling:Number = init.getNumber("scale", 1);

            scaleX(init.getNumber("scaleX", 1) * scaling);
            scaleY(init.getNumber("scaleY", 1) * scaling);
            scaleZ(init.getNumber("scaleZ", 1) * scaling);
            */


            if (this is Scene3D)
                _scene = this as Scene3D;
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
                _parent.addOnTransformChange(onParentTransformChange);
            }

            _scene = _parent ? _parent.scene : null;

            if (_scene != oldscene)
                notifySceneChange();

            _worldDirty = true;
            notifyTransformChange();
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
            _worldDirty = true;
            notifyTransformChange();
        }

        public function get scene():Scene3D
        {
            return _scene;
        }

        public function distanceTo(obj:Object3D):Number
        {
            var m1:Matrix3D = scene == null ? transform : world;
            var m2:Matrix3D = obj.scene == null ? obj.transform : obj.world;

            var dx:Number = m1.tx - m2.tx;
            var dy:Number = m1.ty - m2.ty;
            var dz:Number = m1.tz - m2.tz;
    
            return Math.sqrt(dx*dx + dy*dy + dz*dz);
        }
    
        public function traverse(traverser:Traverser):void
        {
            traverser.apply(this);
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
    
        public function translate(axis:Number3D, distance:Number):void
        {
            var vector:Number3D = axis.rotate(transform);
    
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

        public function rotate(axis:Number3D, angle:Number):void
        {
            var vector:Number3D = axis.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            _rotationDirty = true;
        }

    
        // Make the object look at a specific position.
        // @param targetObject Object to look at.
        // @param upAxis The vertical axis of the universe. Normally the positive Y axis.
        public function lookAt(target:Number3D, upAxis:Number3D = null):void
        {
            var zAxis:Number3D = Number3D.sub(target, position);
            zAxis.normalize();
    
            if (zAxis.modulo > 0.1)
            {
                var xAxis:Number3D = Number3D.cross(zAxis, upAxis || Number3D.UP);
                xAxis.normalize();
    
                var yAxis:Number3D = Number3D.cross(zAxis, xAxis);
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
                // TODO: Implement scale
            }
            else
            {
                //throw new Error("lookAt Error");
            }
        }

        public function toString():String
        {
            return name + ': x:' + Math.round(x) + ' y:' + Math.round(y) + ' z:' + Math.round(z);
        }
    
        public function tick(time:int):void
        {
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
            if (!hasEventListener("transformchanged"))
                return;

            if (transformchanged == null)
                transformchanged = new Object3DEvent("transformchanged", this);
                
            dispatchEvent(transformchanged);
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
            addEventListener(MouseEvent.MOUSE_MOVE+"3D", listener, false, 0, false);
        }
        public function removeOnMouseMove(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_MOVE+"3D", listener, false);
        }

        public function addOnMouseDown(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_DOWN+"3D", listener, false, 0, false);
        }
        public function removeOnMouseDown(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_DOWN+"3D", listener, false);
        }

        public function addOnMouseUp(listener:Function):void
        {
            addEventListener(MouseEvent.MOUSE_UP+"3D", listener, false, 0, false);
        }
        public function removeOnMouseUp(listener:Function):void
        {
            removeEventListener(MouseEvent.MOUSE_UP+"3D", listener, false);
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
