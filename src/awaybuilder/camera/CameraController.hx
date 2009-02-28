package awaybuilder.camera;

import away3d.cameras.Camera3D;
import away3d.core.base.Object3D;
import awaybuilder.SceneUpdate;
import awaybuilder.abstracts.AbstractCameraController;
import awaybuilder.events.CameraEvent;
import awaybuilder.events.SceneEvent;
import awaybuilder.interfaces.ICameraController;
import awaybuilder.utils.CoordinateCopy;
import awaybuilder.utils.EasingUtil;
import awaybuilder.vo.SceneCameraVO;
import gs.TweenLite;
import flash.events.EventDispatcher;
import flash.events.Event;


class CameraController extends AbstractCameraController, implements ICameraController {
	
	private var camera:Camera3D;
	private var origin:Object3D;
	private var target:Object3D;
	private var targetCamera:SceneCameraVO;
	

	//protected var animating : Boolean ;
	public function new(camera:Camera3D) {
		
		
		super();
		this.camera = camera;
		this.origin = new Object3D();
		this.target = new Object3D();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Override Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	override public function navigateTo(vo:SceneCameraVO):Void {
		// FIXME: Remove animating property?
		/*if ( ! this.animating )
		 {*/
		
		if (vo != this.targetCamera) {
			this.targetCamera = vo;
			//this.animating = true ;
			this.copyCoordinates(this.camera, this.origin);
			this.copyCoordinates(vo.camera, this.target);
			// FIXME: Very rarely the camera appears to not rotate the shortest way.
			var tx:Float = this.target.rotationX % 360;
			var ty:Float = this.target.rotationY % 360;
			var tz:Float = this.target.rotationZ % 360;
			var ox:Float = this.origin.rotationX % 360;
			var oy:Float = this.origin.rotationY % 360;
			var oz:Float = this.origin.rotationZ % 360;
			var aDiffX:Float = Math.abs(tx - ox);
			var aDiffY:Float = Math.abs(ty - oy);
			var aDiffZ:Float = Math.abs(tz - oz);
			var aDistX:Float;
			var aDistY:Float;
			var aDistZ:Float;
			aDiffX < 180 ? aDistX = aDiffX : aDistX = 360 - aDiffX;
			aDiffY < 180 ? aDistY = aDiffY : aDistY = 360 - aDiffY;
			aDiffZ < 180 ? aDistZ = aDiffZ : aDistZ = 360 - aDiffZ;
			// rotationX
			if (aDiffX < 180) {
				if (tx > ox) {
					this.target.rotationX = ox + aDistX;
				} else if (tx < ox) {
					this.target.rotationX = ox - aDistX;
				}
			} else {
				if (tx > ox) {
					this.target.rotationX = ox - aDistX;
				} else if (tx < ox) {
					this.target.rotationX = ox + aDistX;
				}
			}
			// rotationY
			if (aDiffY < 180) {
				if (ty > oy) {
					this.target.rotationY = oy + aDistY;
				} else if (ty < oy) {
					this.target.rotationY = oy - aDistY;
				}
			} else {
				if (ty > oy) {
					this.target.rotationY = oy - aDistY;
				} else if (ty < oy) {
					this.target.rotationY = oy + aDistY;
				}
			}
			// rotationZ
			if (aDiffZ < 180) {
				if (tz > oz) {
					this.target.rotationZ = oz + aDistZ;
				} else if (tz < oz) {
					this.target.rotationZ = oz - aDistZ;
				}
			} else {
				if (tz > oz) {
					this.target.rotationZ = oz - aDistZ;
				} else if (tz < oz) {
					this.target.rotationZ = oz + aDistZ;
				}
			}
			this.animateCamera(vo);
		} else {
			if (this.startCamera != null) {
				this.navigateTo(this.startCamera);
			}
		}
		//}
		
	}

	override public function teleportTo(vo:SceneCameraVO):Void {
		
		this.copyCoordinates(vo.camera, this.target);
		this.cameraComplete();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Protected Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	private function copyCoordinates(source:Object3D, target:Object3D):Void {
		
		CoordinateCopy.position(source, target);
		CoordinateCopy.rotation(source, target);
	}

	private function animateCamera(vo:SceneCameraVO):Void {
		
		var init:Dynamic = new Object();
		var cameraEvent:CameraEvent = new CameraEvent(CameraEvent.ANIMATION_START);
		CoordinateCopy.position(this.target, init);
		CoordinateCopy.rotation(this.target, init);
		switch (this.animationControl) {
			case AnimationControl.INTERNAL :
				Reflect.setField(init, "ease", EasingUtil.stringToFunction(vo.transitionType));
				Reflect.setField(init, "onUpdate", this.cameraUpdate);
				Reflect.setField(init, "onComplete", this.cameraComplete);
				TweenLite.to(this.camera, vo.transitionTime, init);
				break;
			case AnimationControl.EXTERNAL :
				break;
				// TODO: Does external animation control need additional implementation?
				
			

		}
		cameraEvent.targetCamera = vo;
		this.dispatchEvent(cameraEvent);
	}

	private function cameraUpdate():Void {
		
		switch (this.update) {
			case SceneUpdate.MANUAL :
			case SceneUpdate.ON_CAMERA_UPDATE :
				this.dispatchEvent(new SceneEvent(SceneEvent.RENDER));
			

		}
	}

	private function cameraComplete():Void {
		
		var cameraEvent:CameraEvent = new CameraEvent(CameraEvent.ANIMATION_COMPLETE);
		this.copyCoordinates(this.target, this.camera);
		//this.animating = false ;
		cameraEvent.targetCamera = this.targetCamera;
		this.dispatchEvent(new SceneEvent(SceneEvent.RENDER));
		this.dispatchEvent(cameraEvent);
	}

}

