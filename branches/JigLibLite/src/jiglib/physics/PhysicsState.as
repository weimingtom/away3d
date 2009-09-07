package jiglib.physics
{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	
	import jiglib.math.*;

	public class PhysicsState
	{
		public var position:Vector3D = new Vector3D();
		public var orientation:Matrix3D = new Matrix3D();
		public var linVelocity:Vector3D = new Vector3D();
		public var rotVelocity:Vector3D = new Vector3D();
		
		public function orientation__getCols():Vector.<Vector3D>
		{
			return JMatrix3D.__getCols(orientation);
		}
		
		/*
		//tobe delete
		public function get orientation.toMatrix3D()():Matrix3D
		{ 
			return JMatrix3D.getMatrix3D(orientation);
		}
		public function set orientation.toMatrix3D()(m:Matrix3D):void
		{ 
			orientation = JMatrix3D.getMatrix3D(m);
		}
		*/
	}
}