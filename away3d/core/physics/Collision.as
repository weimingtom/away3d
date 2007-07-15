package away3d.core.physics
{
	import away3d.core.proto.*;
	import away3d.core.math.*;
	import away3d.core.physics.*;
	
	public class Collision
	{
		public var penetration:Number;
		public var normal:Number3D;
		public var used:Boolean = true;
		public var object:CollisionObject3D;
		
		public function Collision()
		{
		}
		
		public function setProperties(object:CollisionObject3D, normal:Number3D, penetration:Number):void
		{
			this.object = object;
			this.penetration = penetration;
			this.normal = normal;
			used = false;
		}
		
		public static function calcFriction(object1:CollisionObject3D, object2:CollisionObject3D):Number
		{

			return Math.min(object1.friction, object2.friction);
		}
		
		public static function calcBounce(object1:CollisionObject3D, object2:CollisionObject3D):Number
		{
			return Math.max(object1.bounce, object2.bounce);
		}
	}
}