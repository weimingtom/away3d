package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    import flash.events.EventDispatcher;
    
    // The DisplayObject class represents instances of 3D objects that are contained in the scene.
    // That includes all objects in the scene, not only those that can be rendered, but also the camera and its target.
    // The Object3D class supports basic functionality like the x, y and z position of an object, as well as rotationX, rotationY, rotationZ, scaleX, scaleY and scaleZ and visible. It also supports more advanced properties of the object such as its transform Matrix3D.
    // Object3D is not an abstract base class; therefore, you can call Object3D directly. Invoking new DisplayObject() creates a new empty object in 3D space, like when you used createEmptyMovieClip().
    public class Object3D extends EventDispatcher
    {
        // An Number that sets the X coordinate of a object relative to the scene coordinate system.
        public function get x():Number
        {
            return _transform.n14;
        }
    
        public function set x(value:Number):void
        {
            _transform.n14 = value;
        }
    
        // An Number that sets the Y coordinate of a object relative to the scene coordinates.
        public function get y():Number
        {
            return _transform.n24;
        }
    
        public function set y(value:Number):void
        {
            _transform.n24 = value;
        }
    
        // An Number that sets the Z coordinate of a object relative to the scene coordinates.
        public function get z():Number
        {
            return _transform.n34;
        }
    
        public function set z(value:Number):void
        {
            _transform.n34 = value;
        }
    
        // Specifies the rotation around the X axis from its original orientation.
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
    
        // Specifies the rotation around the Y axis from its original orientation.
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
    
        // Specifies the rotation around the Z axis from its original orientation.
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
    
        // Update rotation values
        private function updateRotation():void
        {
            var rot:Number3D = Matrix3D.matrix2euler(_transform);
            _rotationX = rot.x * toRADIANS;
            _rotationY = rot.y * toRADIANS;
            _rotationZ = rot.z * toRADIANS;
    
            _rotationDirty = false;
        }
    
        public function set scale(scale:Number):void
        {
            _scaleX = _scaleY = _scaleZ = scale;
    
            _transformDirty = true;
        }
    
        public function set scaleX(scale:Number):void
        {
            _scaleX = scale;
    
            _transformDirty = true;
        }
    
        public function set scaleY(scale:Number):void
        {
            _scaleY = scale;
    
            _transformDirty = true;
        }
    
        public function set scaleZ(scale:Number):void
        {
            _scaleZ = scale;
    
            _transformDirty = true;
        }
    
        public function get position():Number3D
        {
            return new Number3D(x, y, z);
        }

        // Whether or not the display object is visible.
        public var visible:Boolean = true;
    
        // An optional object name.
        public var name:String;
    
        // An object that contains user defined properties.
        public var extra:Object;
    
        // A Matrix3D object containing values that affect the scaling, rotation, and translation of the display object.
        private var _transform:Matrix3D = new Matrix3D();

        public function get transform():Matrix3D
        {
            updateTransform();

            return _transform;
        }

        public function set transform(value:Matrix3D):void
        {
            this._transform = value.clone();

            this._transformDirty = false;
            this._rotationDirty = true;
        }

        private var _transformDirty:Boolean = false;
        private var _rotationDirty:Boolean = false;
    
        private var _rotationX:Number = 0;
        private var _rotationY:Number = 0;
        private var _rotationZ:Number = 0;
    
        private var _scaleX:Number = 1;
        private var _scaleY:Number = 1;
        private var _scaleZ:Number = 1;

    
        // Creates a new Object3D instance. After creating the instance, call the addChild() method of a ObjectContainer3D.
        // @param name        [optional] - The name of the newly created object.
        // @param init  [optional] - An object that contains user defined properties with which to populate the newly created Object3D.
        // x: An Number that sets the X coordinate of a object relative to the scene coordinate system.
        // y: An Number that sets the Y coordinate of a object relative to the scene coordinate system.
        // z: An Number that sets the Z coordinate of a object relative to the scene coordinate system.
        // rotationX: Specifies the rotation around the X axis from its original orientation.
        // rotationY: Specifies the rotation around the Y axis from its original orientation.
        // rotationZ: Specifies the rotation around the Z axis from its original orientation.
        // scaleX: Sets the scale along the local X axis as applied from the registration point of the object.
        // scaleY: Sets the scale along the local Y axis as applied from the registration point of the object.
        // scaleZ: Sets the scale along the local Z axis as applied from the registration point of the object.
        // visible: Whether or not the display object is visible.
        // A Boolean value that indicates whether the object is projected, transformed and rendered. A value of false will effectively ignore the object. The default value is true.
        // extra: An object that contains user defined properties.
        // All properties of the extra field are copied into the new instance. The properties specified with extra are publicly available.
        public function Object3D(name:String = null, init:Object = null):void
        {
            this.name = name;
    
            if (init != null)
            {
                x = init.x || 0;
                y = init.y || 0;
                z = init.z || 0;
            
                rotationX = init.rotationX || 0;
                rotationY = init.rotationY || 0;
                rotationZ = init.rotationZ || 0;
            
                scaleX = init.scaleX || 1;
                scaleY = init.scaleY || 1;
                scaleZ = init.scaleZ || 1;
            
                extra = init.extra || null;
            }
        }
    
        public function distanceTo(obj:Object3D):Number
        {
            var x:Number = x - obj.x;
            var y:Number = y - obj.y;
            var z:Number = z - obj.z;
    
            return Math.sqrt(x*x + y*y + z*z);
        }
    
        public function traverse(traverser:Traverser):void
        {
            traverser.apply(this);
        }

        public function project(parentview:Matrix3D):Matrix3D
        {
            return Matrix3D.multiply(parentview, transform);
        }       
    
        // Translate the display object in the direction it is facing, i.e. it's positive Z axis.
        // @param    distance    The distance that the object should move forward.
        public function moveForward(distance:Number):void 
        { 
            translate(distance, Number3D.FORWARD); 
        }
    
        // Translate the display object in the opposite direction it is facing, i.e. it's negative Z axis.
        // @param    distance    The distance that the object should move backward.
        public function moveBackward(distance:Number):void 
        { 
            translate(distance, Number3D.BACKWARD); 
        }
    
        // Translate the display object lateraly, to the left of the direction it is facing, i.e. it's negative X axis.
        // @param distance The distance that the object should move left.
        public function moveLeft(distance:Number):void 
        { 
            translate(distance, Number3D.LEFT); 
        }
    
        // Translate the display object lateraly, to the right of the direction it is facing, i.e. it's positive X axis.
        // @param distance The distance that the object should move right.
        public function moveRight(distance:Number):void 
        { 
            translate(distance, Number3D.RIGHT); 
        }
    
        // Translate the display object upwards, with respect to the direction it is facing, i.e. it's positive Y axis.
        // @param distance The distance that the object should move up.
        public function moveUp(distance:Number):void 
        { 
            translate(distance, Number3D.UP); 
        }
    
        // Translate the display object downwards, with respect to the direction it is facing, i.e. it's negative Y axis.
        // @param distance The distance that the object should move down.
        public function moveDown(distance:Number):void 
        { 
            translate(distance, Number3D.DOWN); 
        }
    
        // Move the object along a given direction.
        // @param distance The distance that the object should travel.
        // @param axis The direction that the object should move towards.
        public function translate(distance:Number, axis:Number3D):void
        {
            var vector:Number3D = axis.rotate(transform);
    
            x += distance * vector.x;
            y += distance * vector.y;
            z += distance * vector.z;
        }
    
        // Rotate the display object around its lateral or transverse axis - an axis running from the pilot's left to right in piloted aircraft, and parallel to the wings of a winged aircraft; thus the nose pitches up and the tail down, or vice-versa.
        public function pitch(angle:Number):void
        {
            var vector:Number3D = Number3D.RIGHT.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            _rotationDirty = true;
        }

        // Rotate the display object around about the vertical axis - an axis drawn from top to bottom.
        public function yaw(angle:Number):void
        {
            var vector:Number3D = Number3D.UP.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            _rotationDirty = true;
        }
    
        // Rotate the display object around the longitudinal axis - an axis drawn through the body of the vehicle from tail to nose in the normal direction of flight, or the direction the object is facing.
        public function roll(angle:Number):void
        {
            var vector:Number3D = Number3D.FORWARD.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            _rotationDirty = true;
        }
    
        // Make the object look at a specific position.
        // @param targetObject Object to look at.
        // @param upAxis The vertical axis of the universe. Normally the positive Y axis.
        public function lookAt(targetObject:*, upAxis:Number3D = null):void
        {
            var position:Number3D = new Number3D(x, y, z);
            var target:Number3D = new Number3D(targetObject.x, targetObject.y, targetObject.z);
    
            var zAxis:Number3D = Number3D.sub(target, position);
            zAxis.normalize();
    
            if (zAxis.modulo > 0.1)
            {
                var xAxis:Number3D = Number3D.cross(zAxis, upAxis || Number3D.UP);
                xAxis.normalize();
    
                var yAxis:Number3D = Number3D.cross(zAxis, xAxis);
                yAxis.normalize();
    
                var look:Matrix3D = _transform;
    
                look.n11 = xAxis.x;
                look.n21 = xAxis.y;
                look.n31 = xAxis.z;
    
                look.n12 = -yAxis.x;
                look.n22 = -yAxis.y;
                look.n32 = -yAxis.z;
    
                look.n13 = zAxis.x;
                look.n23 = zAxis.y;
                look.n33 = zAxis.z;
    
                _transformDirty = false;
                _rotationDirty = true;
                // TODO: Implement scale
            }
            else
            {
                //throw new Error("lookAt Error");
            }
        }

        // Updates the transform Matrix3D with the current rotation and scale values.
        private function updateTransform():void
        {
            if (!_transformDirty) 
                return;

            var q:Quaternion = Matrix3D.euler2quaternion(-_rotationY, -_rotationZ, _rotationX); // Swapped
            var m:Matrix3D = Matrix3D.quaternion2matrix(q.x, q.y, q.z, q.w);

            m.n14 = _transform.n14;
            m.n24 = _transform.n24;
            m.n34 = _transform.n34;
            m.scale(_scaleX, _scaleY, _scaleZ);

            _transform = m;
            _transformDirty = false;
        }
    
        public override function toString():String
        {
            return this.name + ': x:' + Math.round(this.x) + ' y:' + Math.round(this.y) + ' z:' + Math.round(this.z);
        }
    
        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;

        public function tick(time:int):void
        {
        }
    }
}
