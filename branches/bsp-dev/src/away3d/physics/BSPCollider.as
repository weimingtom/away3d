package away3d.physics
{
	import away3d.arcane;
	import away3d.core.base.Face;
	import away3d.core.base.Mesh;
	import away3d.core.base.Object3D;
	import away3d.core.geom.Plane3D;
	import away3d.core.graphs.BSPTree;
	import away3d.core.math.Number3D;

	use namespace arcane;
	
	// TO DO: perform auto-update
	
	/**
	 * BSPCollider manages an object to move around in a BSPTree while doing collision detection.
	 * This can be used to create FPS-style navigation.
	 */
	public class BSPCollider
	{
		private static const MAX_ITERATIONS : int = 5;
		private static const EPSILON : Number = 1/32;
		
		private var _radii : Number3D;
		private var _boundOffset : Number3D;
		private var _maxClimbHeight : Number = 5;
		
		private var _object : Object3D;
		private var _bspTree : BSPTree;
		
		private var _velocity : Number3D = new Number3D();
		
		private var _startPos : Number3D = new Number3D();
		private var _targetPosition : Number3D = new Number3D();
		
		private var _gravity : Number = 6;
		private var _friction : Number = 0.5;
		
		private var _time : Number = -1;
		
		private var _force : Number3D = new Number3D();
		
		private var _maxVelocity : Number = 30;
		
		/**
		 * Creates a BSPCollider object.
		 * 
		 * @param object The object that moves around in the world. This can be a Camera3D (FPS) or a Mesh
		 * @bspTree The BSP tree against which collisions need to be checked
		 */
		public function BSPCollider(object : Object3D, bspTree : BSPTree)
		{
			_radii = new Number3D();
			_boundOffset = new Number3D();
			if (object is Mesh) {
				_radii.x = Math.abs(object.maxX-object.minX)*.5;
				_radii.y = Math.abs(object.maxY-object.minY)*.5;
				_radii.z = Math.abs(object.maxZ-object.minZ)*.5;
				// dunno if correct, needs check
				_boundOffset.x = _radii.x+object.minX;
				_boundOffset.y = _radii.y+object.minY;
				_boundOffset.z = _radii.z+object.minZ;
			}
			else {
				_radii.x = 5;
				_radii.y = 40;
				_radii.z = 5;
				_boundOffset.x = 0;
				_boundOffset.y = 35;
				_boundOffset.z = 0;
			}
			_object = object;
			_bspTree = bspTree;
		}
		
		/**
		 * The maximum velocity the object can have
		 */
		public function get maxVelocity() : Number
		{
			return _maxVelocity;
		}
		
		public function set maxVelocity(value : Number) : void
		{
			_maxVelocity = value;
		}
		
		/**
		 * The amount of gravity which will pull down the target object.
		 */
		public function get gravity() : Number
		{
			return _gravity;
		}
		
		public function set gravity(value : Number) : void
		{
			_gravity = value;
		}
		
		/**
		 * The amount of friction acting upon the object. This will decelerate the
		 * object. A value between 0 and 1.
		 */
		public function get friction() : Number
		{
			return _friction;
		}
		
		public function set friction(value : Number) : void
		{
			if (value > 1) value = 1;
			else if (value < 0) value = 0;
			_friction = value;
		}
		
		/**
		 * The offset of the bounding ellipse.
		 */
		public function get boundOffset() : Number3D
		{
			return _boundOffset;
		}
		
		public function set boundOffset(value : Number3D) : void
		{
			_boundOffset = value;
		}
		
		/**
		 * The radii of the bounding ellipse of the object
		 */
		public function get boundRadii() : Number3D
		{
			return _radii;
		}
		
		public function set boundRadii(value : Number3D) : void
		{
			_radii = value;
		}
		
		/**
		 * Accelerates the object along an axis. The y-coordinate is in world space, the x and z coordinates are local to the object.
		 */
		public function move(x : Number, y : Number, z : Number) : void
		{
			_force.x += x;
			_force.y += y;
			_force.z += z;
		}
		
		/**
		 * Updates the object's position based on the velocity and found collisions.
		 */
		public function update() : void
		{
			var it : int;
			var frameTime : Number = 1;
			var fy : Number = _force.y;
			_object.transform.multiplyVector3x3(_force);
			
			_velocity.x += _force.x;
			_velocity.y += fy-_gravity;
			_velocity.z += _force.z;
			
			// maximum velocity in xz-plane
			var len : Number = Math.sqrt(_velocity.x*_velocity.x+_velocity.z*_velocity.z);
			if (len > _maxVelocity) {
				len = _maxVelocity/len;
				_velocity.x *= len;
				_velocity.z *= len;
			}
			
			// TO DO: convert to bsp local coords
			_startPos.x = _object.position.x - _boundOffset.x;
			_startPos.y = _object.position.y - _boundOffset.y;
			_startPos.z = _object.position.z - _boundOffset.z;
			
			_velocity.x *= _friction;
			_velocity.z *= _friction;
			
			_targetPosition.x = _startPos.x + _velocity.x*frameTime;
			_targetPosition.y = _startPos.y + _velocity.y*frameTime;
			_targetPosition.z = _startPos.z + _velocity.z*frameTime;
			
			var collFace : Face;
			
			// until we find a position that is valid, keep checking where to "slide" the object
			do {
				collFace = _bspTree.traceCollision(_startPos, _targetPosition, _radii);
				
				if (collFace) {
					var plane : Plane3D = collFace._plane;
					var radX : Number = _radii.x*plane.a;
					var radY : Number = _radii.y*plane.b;
					var radZ : Number = _radii.z*plane.c;
					var radius : Number = Math.sqrt(radX*radX + radY*radY + radZ*radZ);
					// distance between collision plane and bounding ellipsoid
					// including some epsilon padding
					var dist : Number = EPSILON + radius -
										(	_targetPosition.x*plane.a + 
											_targetPosition.y*plane.b +
											_targetPosition.z*plane.c +
											plane.d);
					
					_targetPosition.x += plane.a*dist;
					_targetPosition.y += plane.b*dist;
					_targetPosition.z += plane.c*dist;
					
					++it;
				}
			} while (collFace && it < MAX_ITERATIONS);
			
			// update velocity due to collision
			if (it > 0) {
				_velocity.x = (_targetPosition.x-_startPos.x)/frameTime;
				// this shouldn't be set to 0 or will stop falling?
				_velocity.y = 0;
				_velocity.z = (_targetPosition.z-_startPos.z)/frameTime;
			}
			
			// check if we need to climb up a bit
			if (collFace && it == MAX_ITERATIONS) {
				_targetPosition.y += _maxClimbHeight;
				collFace = _bspTree.traceCollision(_startPos, _targetPosition, _radii);
			}
			
			// if still not allowed to move
			if (collFace && it == MAX_ITERATIONS) {
				// still colliding after maximum iterations
				// illegal move & stop
				_velocity.x = 0;
				_velocity.y = 0;
				_velocity.z = 0;
			}
			else {
				// object allowed to move
				_object.x = _targetPosition.x + _boundOffset.x;
				_object.y = _targetPosition.y + _boundOffset.y;
				_object.z = _targetPosition.z + _boundOffset.z;
			}
					
			_force.x = _force.y = _force.z = 0;
		}
	}
}