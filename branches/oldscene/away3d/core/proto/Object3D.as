package away3d.core.proto
{
    import away3d.core.*;
    import away3d.core.math.*;
    import away3d.core.proto.*;
    import away3d.core.physics.*;
    
    import flash.display.Sprite;
    import flash.utils.Dictionary;
    import flash.geom.Matrix;
    
    // The DisplayObject class represents instances of 3D objects that are contained in the scene.
    // That includes all objects in the scene, not only those that can be rendered, but also the camera and its target.
    // The Object3D class supports basic functionality like the x, y and z position of an object, as well as rotationX, rotationY, rotationZ, scaleX, scaleY and scaleZ and visible. It also supports more advanced properties of the object such as its transform Matrix3D.
    // Object3D is not an abstract base class; therefore, you can call Object3D directly. Invoking new DisplayObject() creates a new empty object in 3D space, like when you used createEmptyMovieClip().
	/** Root class for all objects and nodes in the scene */
    public class Object3D extends CollisionObject3D
    {
    	//physical properties
		public var innerCollisions:Boolean = false;
		
		//array holders
		public var constraints:Array = new Array();
		public var accelerations:Array = new Array();
		
        // An Number that sets the X coordinate of a object relative to the scene coordinate system.
        public function get x():Number
        {
            return _transform.n14;
        }
    
        public function set x(value:Number):void
        {
            _transform.n14 = oldPosition.x = value;
            transformUpdate = true;
            
        }
    
        // An Number that sets the Y coordinate of a object relative to the scene coordinates.
        public function get y():Number
        {
            return _transform.n24;
        }
    
        public function set y(value:Number):void
        {
            _transform.n24 = oldPosition.y = value;
            transformUpdate = true;
        }
    
        // An Number that sets the Z coordinate of a object relative to the scene coordinates.
        public function get z():Number
        {
            return _transform.n34;
        }
    
        public function set z(value:Number):void
        {
            _transform.n34 = oldPosition.z = value;
            transformUpdate = true;
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
            transformUpdate = _transformDirty = true;
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
            transformUpdate = _transformDirty = true;
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
            transformUpdate = _transformDirty = true;
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
            _scaleX = scale;
            _scaleY = scale;
            _scaleZ = scale;
    
            transformUpdate = _transformDirty = true;
        }
    
        public function set scaleX(scale:Number):void
        {
            _scaleX = scale;
    
            transformUpdate = _transformDirty = true;
        }
    
        public function set scaleY(scale:Number):void
        {
            _scaleY = scale;
    
            transformUpdate = _transformDirty = true;
        }
    
        public function set scaleZ(scale:Number):void
        {
            _scaleZ = scale;
    
            transformUpdate = _transformDirty = true;
        }
    
        public override function get position():Number3D
        {
            return new Number3D(x, y, z);
        }
    
        public override function set position(val:Number3D):void
        {
            _transform.n14 = val.x;
            _transform.n24 = val.y;
            _transform.n34 = val.z;
            transformUpdate = true;
        }
		
        // Whether or not the display object is visible.
        public var visible:Boolean = true;
    
        // An optional object name.
        public var name:String;
    
        // An object that contains user defined properties.
        public var extra:Object;

        public override function set parent(p:Object3D):void
        {
            if (p == _parent)
                return;
			
            if (_parent != null)
                (_parent as ObjectContainer3D).removeChild(this);
			
            if (p != null)
                (p as ObjectContainer3D).addChild(this);
        }

        private var _events:Object3DEvents;

        public function get events():Object3DEvents
        {
            if (_events == null)
                _events = new Object3DEvents();

            return _events;
        }

        public function get hasEvents():Boolean
        {
            return _events != null;
        }

        // A Matrix3D object containing values that affect the scaling, rotation, and translation of the display object.
        private var _transform:Matrix3D = new Matrix3D();

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
            transformUpdate = _rotationDirty = true;
        }
        
        public var transformUpdate:Boolean = false;
		public var sceneTransform:Matrix3D;
        
        public function relative(rel:Object3D = null):Matrix3D
        {
            var result:Matrix3D = new Matrix3D();
            var object:Object3D = this;

            while (object != rel)
            {
                result = Matrix3D.multiply(object.transform, result);
                object = object.parent;
            }

            return result;
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
        // extra: An object that contains user defined properties.
        public function Object3D(init:Object = null):void
        {
        	super(init);
            init = Init.parse(init);

            name = init.getString("name", null);
            visible = init.getBoolean("visible", true);

            _transform.n14 = init.getNumber("x", 0);
            _transform.n24 = init.getNumber("y", 0);
            _transform.n34 = init.getNumber("z", 0);
            
            rotationX = init.getNumber("rotationX", 0);
            rotationY = init.getNumber("rotationY", 0);
            rotationZ = init.getNumber("rotationZ", 0);
            
            var scaling:Number = init.getNumber("scale", 1);
			
            scaleX = init.getNumber("scaleX", 1) * scaling;
            scaleY = init.getNumber("scaleY", 1) * scaling;
            scaleZ = init.getNumber("scaleZ", 1) * scaling;
            
            extra = init.getObject("extra");
            
            innerCollisions = init.getBoolean("innerCollisions", innerCollisions);
            accelerations = init.getArray("accelerations");
            
           	oldPosition = position;
           	sceneTransform = transform;
            scenePosition = position;
        }
    
        public function distanceTo(obj:Object3D):Number
        {
            var dx:Number = x - obj.x;
            var dy:Number = y - obj.y;
            var dz:Number = z - obj.z;
    
            return Math.sqrt(dx*dx + dy*dy + dz*dz);
        }
    
        public function traverse(traverser:Traverser):void
        {
            traverser.apply(this);
        }

        public function project():void
        {       	
            if (transformUpdate = (_parent.transformUpdate || transformUpdate))
            	sceneTransform = Matrix3D.multiply(_parent.sceneTransform, transform);
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
    
            transformUpdate = _rotationDirty = true;
        }

        // Rotate the display object around about the vertical axis - an axis drawn from top to bottom.
        public function yaw(angle:Number):void
        {
            var vector:Number3D = Number3D.UP.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            transformUpdate = _rotationDirty = true;
        }
    
        // Rotate the display object around the longitudinal axis - an axis drawn through the body of the vehicle from tail to nose in the normal direction of flight, or the direction the object is facing.
        public function roll(angle:Number):void
        {
            var vector:Number3D = Number3D.FORWARD.rotate(transform);
    
            var m:Matrix3D = Matrix3D.rotationMatrix(vector.x, vector.y, vector.z, angle * toRADIANS);
    
            _transform.copy3x3(Matrix3D.multiply3x3(m, transform));
    
            transformUpdate = _rotationDirty = true;
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
                transformUpdate = _rotationDirty = true;
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
    
        public function toString():String
        {
            return name + ': x:' + Math.round(x) + ' y:' + Math.round(y) + ' z:' + Math.round(z);
        }
    
        private static var toDEGREES:Number = 180 / Math.PI;
        private static var toRADIANS:Number = Math.PI / 180;

        public function tick(time:int):void
        {
        }
		
		public override function thrust(val:Number3D):void
		{
			super.thrust(val);
			project();
			traverse(new ReactionTraverser());
        	transformUpdate = false;
		}
    }
}
