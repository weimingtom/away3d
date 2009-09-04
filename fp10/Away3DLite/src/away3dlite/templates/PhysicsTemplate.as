package away3dlite.templates
{
	import away3dlite.core.render.*;
	import away3dlite.materials.WireframeMaterial;
	
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
			
			physics = new Away3DLitePhysics(view, 10);
			ground = physics.createGround(new WireframeMaterial(), 1000, 0);
			ground.movable = false;
			ground.friction = 0.2;
			ground.restitution = 0.8;
			
			build();
		}
		
		protected function build():void
		{
			// override me
		}
	}
}