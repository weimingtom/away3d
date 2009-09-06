package jiglib.physics
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.math.*;

	public class PhysicsState
	{
		public var position:Vector3D = new Vector3D();
		public var orientation:JMatrix3D = new JMatrix3D();
		public var linVelocity:Vector3D = new Vector3D();
		public var rotVelocity:Vector3D = new Vector3D();
		
		//tobe delete
		public function get __orientation():Matrix3D
		{ 
			return JMatrix3D.toMatrix3D(orientation);
		}
		public function set __orientation(m:Matrix3D):void
		{ 
			orientation = JMatrix3D.toJMatrix3D(m);
		}
	}
}