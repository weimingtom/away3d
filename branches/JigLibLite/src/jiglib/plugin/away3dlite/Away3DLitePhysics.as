package jiglib.plugin.away3dlite
{
	import away3dlite.containers.View3D;
	import away3dlite.core.base.Mesh;
	import away3dlite.materials.Material;
	import away3dlite.primitives.Ground;
	import away3dlite.primitives.SimpleCube;
	import away3dlite.primitives.Sphere;
	
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
		private var view:View3D;

		public function Away3DLitePhysics(view:View3D, speed:Number = 1)
		{
			super(speed);
			this.view = view;
		}

		public function getMesh(body:RigidBody):Mesh
		{
			return Away3DLiteMesh(body.skin).mesh as Mesh;
		}

		public function createSphere(material:Material, radius:Number = 100, segmentsW:int = 8, segmentsH:int = 6):RigidBody
		{
			var sphere:Sphere = new Sphere().create(material, radius, segmentsW, segmentsH);
			view.scene.addChild(sphere);
			var jsphere:JSphere = new JSphere(new Away3DLiteMesh(sphere), radius);
			addBody(jsphere);
			return jsphere;
		}

		public function createCube(material:Material, width:Number = 100, depth:Number = 100, height:Number = 100):RigidBody
		{
			var cube:SimpleCube = new SimpleCube(width, material);
			view.scene.addChild(cube);
			var jbox:JBox = new JBox(new Away3DLiteMesh(cube), width, depth, height);
			addBody(jbox);
			return jbox;
		}

		public function createGround(material:Material, size:Number, level:Number):RigidBody
		{
			var ground:Ground = new Ground().create(material, size, size) as Ground;
			view.scene.addChild(ground);
			var jGround:JPlane = new JPlane(new Away3DLiteMesh(ground));
			jGround.movable = false;
			jGround.setOrientation(JMatrix3D.rotationX(Math.PI / 2));
			jGround.y = level;
			addBody(jGround);
			return jGround;
		}
	}
}
