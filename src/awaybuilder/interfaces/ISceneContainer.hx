package awaybuilder.interfaces;

import awaybuilder.vo.SceneCameraVO;
import awaybuilder.vo.SceneGeometryVO;


interface ISceneContainer  {
	
	function getCameras():Array<Dynamic>;

	function getGeometry():Array<Dynamic>;

	function getSections():Array<Dynamic>;

	function getCameraById(id:String):SceneCameraVO;

	function getGeometryById(id:String):SceneGeometryVO;

	

}

