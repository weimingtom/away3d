package awaybuilder.vo
{	import away3d.core.base.Object3D;
	import away3d.materials.IMaterial;
	
	
		/**	 * @author andreasengstrom	 */	public class SceneGeometryVO
	{		public var id : String ;
		public var name : String ;
		public var values : SceneObjectVO ;
		public var geometryExtras : Array ;
		public var materialExtras : Array ;
		public var material : IMaterial ;
		public var smooth : Boolean ;
		public var precision : Number = 0 ;
		public var mesh : Object3D ;
		public var enabled : Boolean = true ;
		public var mouseDownEnabled : Boolean ;
		public var mouseMoveEnabled : Boolean ;
		public var mouseOutEnabled : Boolean ;
		public var mouseOverEnabled : Boolean ;
		public var mouseUpEnabled : Boolean ;
		public var geometryType : String ;
		public var materialType : String ;
		public var materialData : Object ;
		public var targetCamera : String ;
		
		// getters and setters
		private var _assetClass : String ;
		private var _assetFile : String ;
		
		
		
		public function SceneGeometryVO ( )
		{
			this.geometryExtras = new Array ( ) ;
			this.materialExtras = new Array ( ) ;
		}
		
		
		
		/////////////////////////
		// GETTERS AND SETTERS //
		/////////////////////////
		
		
		
		public function set assetClass ( value : String ) : void
		{
			this._assetClass = value ;
			this._assetFile = null ;
		}
		
		
		
		public function get assetClass ( ) : String
		{
			return this._assetClass ;
		}
		
		
		
		public function set assetFile ( value : String ) : void
		{
			this._assetFile = value ;
			this._assetClass = null ;
		}
		
		
		
		public function get assetFile ( ) : String
		{
			return this._assetFile ;
		}
	}}