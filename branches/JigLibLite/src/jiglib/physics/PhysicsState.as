package jiglib.physics
{
	import flash.geom.Vector3D;

	import jiglib.math.*;

	public class PhysicsState
	{
		public var position:Vector3D = new Vector3D();
		public var orientation:JMatrix3D = new JMatrix3D();
		public var linVelocity:Vector3D = new Vector3D();
		public var rotVelocity:Vector3D = new Vector3D();
	}
}