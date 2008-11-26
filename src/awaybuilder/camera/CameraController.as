package awaybuilder.camera
{
	import away3d.cameras.Camera3D;
	import away3d.core.base.Object3D;
	
	import caurina.transitions.Tweener;
	
	import awaybuilder.SceneUpdate;
	import awaybuilder.abstracts.AbstractCameraController;
	import awaybuilder.events.CameraEvent;
	import awaybuilder.events.SceneEvent;
	import awaybuilder.interfaces.ICameraController;
	import awaybuilder.utils.CoordinateCopy;
	import awaybuilder.vo.SceneCameraVO;
	
	
	
	public class CameraController extends AbstractCameraController implements ICameraController
	{
		private var camera : Camera3D ;
		private var origin : Object3D ;
		private var target : Object3D ;
		private var targetCamera : SceneCameraVO ;
		private var animating : Boolean ;

		
		
		public function CameraController ( camera : Camera3D )
		{
			super ( ) ;
			this.initialize ( camera ) ;
		}
		
		
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		
		
		override public function navigateTo ( vo : SceneCameraVO ) : void
		{
			if ( ! this.animating )
			{
				if ( vo != this.targetCamera )
				{
					this.targetCamera = vo ;
					this.animating = true ;
					
					this.copyCoordinates ( this.camera , this.origin ) ;
					this.copyCoordinates ( vo.camera , this.target ) ;
					
					// FIXME: Very rarely the camera appears to not rotate the shortest way.
					var tx : Number = this.target.rotationX % 360 ;
					var ty : Number = this.target.rotationY % 360 ;
					var tz : Number = this.target.rotationZ % 360 ;
					var ox : Number = this.origin.rotationX % 360 ;
					var oy : Number = this.origin.rotationY % 360 ;
					var oz : Number = this.origin.rotationZ % 360 ;
					var aDiffX : Number = Math.abs ( tx - ox ) ;
					var aDiffY : Number = Math.abs ( ty - oy ) ;
					var aDiffZ : Number = Math.abs ( tz - oz ) ;
					var aDistX : Number ;
					var aDistY : Number ;
					var aDistZ : Number ;
					
					( aDiffX < 180 ) ? aDistX = aDiffX : aDistX = 360 - aDiffX ;
					( aDiffY < 180 ) ? aDistY = aDiffY : aDistY = 360 - aDiffY ;
					( aDiffZ < 180 ) ? aDistZ = aDiffZ : aDistZ = 360 - aDiffZ ;
					
					// rotationX
					if ( aDiffX < 180 )
					{
						if ( tx > ox ) this.target.rotationX = ox + aDistX ;
						else if ( tx < ox ) this.target.rotationX = ox - aDistX ;
					}
					else
					{
						if ( tx > ox ) this.target.rotationX = ox - aDistX ;
						else if ( tx < ox ) this.target.rotationX = ox + aDistX ;
					}
					
					// rotationY
					if ( aDiffY < 180 )
					{
						if ( ty > oy ) this.target.rotationY = oy + aDistY ;
						else if ( ty < oy ) this.target.rotationY = oy - aDistY ;
					}
					else
					{
						if ( ty > oy ) this.target.rotationY = oy - aDistY ;
						else if ( ty < oy ) this.target.rotationY = oy + aDistY ;
					}
					
					// rotationZ
					if ( aDiffZ < 180 )
					{
						if ( tz > oz ) this.target.rotationZ = oz + aDistZ ;
						else if ( tz < oz ) this.target.rotationZ = oz - aDistZ ;
					}
					else
					{
						if ( tz > oz ) this.target.rotationZ = oz - aDistZ ;
						else if ( tz < oz ) this.target.rotationZ = oz + aDistZ ;
					}
					
					this.animateCamera ( vo ) ;
				}
				else
				{
					if ( this.mainCamera != null )
					{
						this.navigateTo ( this.mainCamera ) ;
					}
				}
			}
		}
		
		
		
		override public function teleportTo ( vo : SceneCameraVO ) : void
		{
			this.copyCoordinates ( vo.camera , this.target ) ;
			this.onCameraFinished ( ) ;
		}
		
		
		
		override public function toString ( ) : String
		{
			return "CameraController" ;
		}
		
		
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		
		
		private function initialize ( camera : Camera3D ) : void
		{
			this.camera = camera ;
			this.origin = new Object3D ( ) ;
			this.target = new Object3D ( ) ;
		}
		
		
		
		private function copyCoordinates ( source : Object3D , target : Object3D ) : void
		{
			CoordinateCopy.position ( source , target ) ;
			CoordinateCopy.rotation ( source , target ) ;
		}
		
		
		
		private function animateCamera ( vo : SceneCameraVO ) : void
		{
			var init : Object = new Object ( ) ;
			var cameraEvent : CameraEvent = new CameraEvent ( CameraEvent.ANIMATION_START ) ;
			
			CoordinateCopy.position ( this.target , init ) ;
			CoordinateCopy.rotation ( this.target , init ) ;
			
			// TODO: Cleanup.
			init[ "time" ] = vo.transitionTime ;
			init[ "transition" ] = vo.transitionType ;
			init[ "onUpdate" ] = this.onCameraUpdate ;
			init[ "onComplete" ] = this.onCameraFinished ;
			
			Tweener.addTween ( this.camera , init ) ;
			
			cameraEvent.targetCamera = vo ;
			this.dispatchEvent ( cameraEvent ) ;
		}
						////////////////////
		// EVENT HANDLERS //
		////////////////////
		
		
		
		private function onCameraUpdate ( ) : void
		{
			switch ( this.update )
			{
				case SceneUpdate.MANUAL :
				case SceneUpdate.ON_CAMERA_UPDATE :
				{
					this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
				}
			}
		}
						private function onCameraFinished ( ) : void
		{
			var cameraEvent : CameraEvent = new CameraEvent ( CameraEvent.ANIMATION_COMPLETE ) ;
			
			this.copyCoordinates ( this.target , this.camera ) ;
			this.animating = false ;
			
			cameraEvent.targetCamera = this.targetCamera ;
			
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
			this.dispatchEvent ( cameraEvent ) ;
		}
	}
}