package awaybuilder.interfaces
{	import awaybuilder.vo.SceneCameraVO;
	import awaybuilder.vo.SceneGeometryVO;
	
	
	
	public interface ISceneContainer
	{
		function getCameras ( ) : Array
		function getGeometry ( ) : Array
		function getSections ( ) : Array
		function getCameraById ( id : String ) : SceneCameraVO
		function getGeometryById ( id : String ) : SceneGeometryVO	}}