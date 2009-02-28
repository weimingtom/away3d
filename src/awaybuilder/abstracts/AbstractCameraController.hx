package awaybuilder.abstracts;

import awaybuilder.camera.AnimationControl;
import awaybuilder.interfaces.ICameraController;
import awaybuilder.vo.SceneCameraVO;
import flash.events.EventDispatcher;


class AbstractCameraController extends EventDispatcher, implements ICameraController {
	
	public var update:String;
	public var startCamera:SceneCameraVO;
	public var animationControl:String;
	

	public function new() {
		this.animationControl = AnimationControl.INTERNAL;
		
		
		super();
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Public Methods
	//
	////////////////////////////////////////////////////////////////////////////////
	public function navigateTo(vo:SceneCameraVO):Void {
		
	}

	public function teleportTo(vo:SceneCameraVO):Void {
		
	}

}

