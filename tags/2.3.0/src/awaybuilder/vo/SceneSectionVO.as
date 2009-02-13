package awaybuilder.vo
{	import away3d.containers.ObjectContainer3D;
	
	
	
	public class SceneSectionVO 
	{		public var id : String = "" ;
		public var name : String = "" ;
		public var values : SceneObjectVO ;
		public var pivot : ObjectContainer3D ;
		public var cameras : Array = [ ] ;
		public var geometry : Array = [ ] ;
		public var sections : Array = [ ] ;
		public var enabled : Boolean = true ;
		
		
		
		public function SceneSectionVO ( )
		{
			this.values = new SceneObjectVO ( ) ;
			this.pivot = new ObjectContainer3D ( ) ;
		}
	}}