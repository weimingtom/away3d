package jiglib.plugin.away3dlite
{
	import away3dlite.containers.Scene3D;
	import away3dlite.core.base.Mesh;
	import away3dlite.materials.Material;
	import away3dlite.primitives.Cube6;
	import away3dlite.primitives.Plane;
	import away3dlite.primitives.Sphere;
	
	import flash.geom.Vector3D;
	
	import jiglib.geometry.JBox;
	import jiglib.geometry.JPlane;
	import jiglib.geometry.JSphere;
	import jiglib.math.JMatrix3D;
	import jiglib.physics.RigidBody;
	import jiglib.plugin.AbstractPhysics;

	/**
	 * @author bartekd
	 * @author katopz
	 */
	public class Away3DLitePhysics extends AbstractPhysics
	{
		private var scene:Scene3D;

		public function Away3DLitePhysics(scene:Scene3D, speed:Number = 1)
		{
			super(speed);
			this.scene = scene;
		}

		public function getMesh(body:RigidBody):Mesh
		{
			return Away3DLiteMesh(body.skin).mesh as Mesh;
		}

		public function createSphere(material:Material, radius:Number = 100, segmentsW:int = 8, segmentsH:int = 6):RigidBody
		{
			var sphere:Sphere = new Sphere(radius, segmentsW, segmentsH);
			sphere.material = material;
			scene.addChild(sphere);
			
			var jsphere:JSphere = new JSphere(new Away3DLiteMesh(sphere), radius);
			addBody(jsphere);
			return jsphere;
		}

		public function createCube(material:Material, width:Number = 100, depth:Number = 100, height:Number = 100):RigidBody
		{
			var cube:Cube6 = new Cube6(width, height, depth);
			cube.material = material;
			scene.addChild(cube);
			
			var jbox:JBox = new JBox(new Away3DLiteMesh(cube), width, depth, height);
			addBody(jbox);
			return jbox;
		}

		public function createGround(material:Material, size:Number, level:Number):RigidBody
		{
			var ground:Plane = new Plane(size, size, 1, 1);
			ground.material = material;
			ground.rotationX = 90;
			scene.addChild(ground);
			
			var jGround:JPlane = new JPlane(new Away3DLiteMesh(ground));
			jGround.movable = false;
			jGround.setOrientation(JMatrix3D.getRotationMatrixAxis(90, Vector3D.X_AXIS));
			jGround.y = level;
			addBody(jGround);
			return jGround;
		}
	}
}