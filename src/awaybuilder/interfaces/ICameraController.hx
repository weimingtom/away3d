package awaybuilder.interfaces;

import awaybuilder.vo.SceneCameraVO;


interface ICameraController  {
	
	function navigateTo(vo:SceneCameraVO):Void;

	function teleportTo(vo:SceneCameraVO):Void;

	

}

