package jiglib.templates
{
	import away3dlite.core.render.*;
	import away3dlite.materials.ColorMaterial;
	import away3dlite.materials.WireframeMaterial;
	import away3dlite.primitives.Cube6;
	import away3dlite.templates.FastTemplate;
	
	import jiglib.physics.RigidBody;
	import jiglib.plugin.away3dlite.Away3DLitePhysics;
	
	/**
	 * Physics Template
	 * 
 	 * @see http://away3d.googlecode.com/svn/branches/JigLibLite/src
 	 * @see http://away3d.googlecode.com/svn/trunk/fp10/Examples/JigLibLite
 	 * 
	 * @author katopz
	 */
	public class PhysicsTemplate extends FastTemplate
	{
		protected var physics:Away3DLitePhysics;
		protected var ground:RigidBody;
		
		protected override function onInit():void
		{
			title += " | JigLibLite Physics";
			
			physics = new Away3DLitePhysics(scene, 10);
			ground = physics.createGround(new WireframeMaterial(), 1000, 0);
			ground.movable = false;
			ground.friction = 0.2;
			ground.restitution = 0.8;
			
			build();
		}

		override public function set debug(val:Boolean):void
		{
			super.debug = val;
			
			// debug cube, to be remove
			var length:int = 300;
			var oCube:Cube6 = new Cube6(10, 10, 10);
			oCube.material = new ColorMaterial(0xFFFFFF);
			scene.addChild(oCube);

			var xCube:Cube6 = new Cube6(10, 10, 10);
			oCube.material = new ColorMaterial(0xFF0000);
			xCube.x = length;
			scene.addChild(xCube);

			var yCube:Cube6 = new Cube6(10, 10, 10);
			yCube.material = new ColorMaterial(0x00FF00);
			yCube.y = length;
			scene.addChild(yCube);

			var zCube:Cube6 = new Cube6(10, 10, 10);
			zCube.material = new ColorMaterial(0x0000FF)
			zCube.z = length;
			scene.addChild(zCube);
		}
		
		protected function build():void
		{
			// override me
		}
	}
}