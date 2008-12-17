package awaybuilder.collada
{
	import flash.events.Event;
	
	import awaybuilder.abstracts.AbstractParser;
	import awaybuilder.interfaces.IParser;
	import awaybuilder.vo.DynamicAttributeVO;
	import awaybuilder.vo.SceneCameraVO;
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneObjectVO;
	import awaybuilder.vo.SceneSectionVO;
	
	
	
	/**
	 * @author andreasengstrom
	 */
	public class ColladaParser extends AbstractParser implements IParser
	{
		public static const GROUP_IDENTIFIER : String = "NODE" ;
		public static const GROUP_CAMERA : uint = 0 ;
		public static const GROUP_GEOMETRY : uint = 1 ;
		public static const GROUP_SECTION : uint = 2 ;
		
		public static const PREFIX_CAMERA : String = "camera" ;
		public static const PREFIX_GEOMETRY : String = "geometry" ;
		public static const PREFIX_MATERIAL : String = "material" ;
		
		private var xml : XML ;
		private var worldId : String ;
		private var worldName : String ;
		
		// getters and setters
		private var _cameraZoom : uint ;
		private var _cameraFocus : uint ;
		private var _mainSections : Array ;
		private var _geometry : Array ;
		private var _cameras : Array ;
		private var _sections : Array ;
		
		
		
		public function ColladaParser ( )
		{
			super ( ) ;
			this.initialize ( ) ;
		}
		
		
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		
		
		override public function parse ( xml : XML ) : void
		{
			this.xml = xml ;
			this.worldId = xml[ ColladaNode.LIBRARY_VISUAL_SCENES ][ ColladaNode.VISUAL_SCENE ].@id ;
			this.worldName = xml[ ColladaNode.LIBRARY_VISUAL_SCENES ][ ColladaNode.VISUAL_SCENE ].@name ;
			
			this.extractMainSections ( ) ;
			
			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;
		}
		
		
		
		override public function getSections ( ) : Array
		{
			return this.mainSections ;
		}
		
		
		
		override public function toString ( ) : String
		{
			return "ColladaParser" ;
		}
		
		
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		
		
		private function initialize ( ) : void
		{
			this._mainSections = new Array ( ) ;
			this._geometry = new Array ( ) ;
			this._sections = new Array ( ) ;
			this._cameras = new Array ( ) ;
		}
		
		
		
		private function extractMainSections ( ) : void
		{
			var list : XMLList = this.xml[ ColladaNode.LIBRARY_VISUAL_SCENES ][ ColladaNode.VISUAL_SCENE ].node as XMLList ;
			
			for each ( var node : XML in list )
			{
				var children : XMLList = node.children ( ) ;
				var vo : SceneSectionVO = new SceneSectionVO ( ) ;
				
				vo.id = node.@id ;
				vo.name = node.@name ;
				vo.values = this.extractPivot ( node ) ;
				vo.cameras = this.extractGroup ( ColladaParser.GROUP_CAMERA , vo , children ) ;
				vo.geometry = this.extractGroup ( ColladaParser.GROUP_GEOMETRY , vo , children ) ;
				vo.sections = this.extractGroup ( ColladaParser.GROUP_SECTION , vo , children ) ;
				
				this.mainSections.push ( vo ) ;
				this.sections.push ( vo ) ;
			}
		}
		
		
		
		private function extractPivot ( xml : XML ) : SceneObjectVO
		{
			var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , xml[ ColladaNode.TRANSLATE ] ) ;
			var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , xml[ ColladaNode.ROTATE ] ) ;
			var scales : Array = this.extractValues ( ColladaNode.VALUE_TYPE_SCALE , xml[ ColladaNode.SCALE ] ) ;
			var pivot : SceneObjectVO = new SceneObjectVO ( ) ;
			
			this.applyPosition ( pivot , positions ) ;
			this.applyRotation ( pivot , rotations ) ;
			this.applyScale ( pivot , scales ) ;
			
			return pivot ;
		}
		
		
		
		private function extractGroup ( group : uint , section : SceneSectionVO , list : XMLList ) : Array
		{
			var a : Array = new Array ( ) ;
			var counter : uint = 0 ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER && counter == group )
				{
					switch ( group )
					{
						case ColladaParser.GROUP_CAMERA :
						{
							a = this.extractCameras ( section , node.children ( ) ) ;
							break ;
						}
						case ColladaParser.GROUP_GEOMETRY :
						{
							a = this.extractGeometry ( section , node.children ( ) ) ;
							break ;
						}	
						case ColladaParser.GROUP_SECTION :
						{
							a = this.extractSection ( /*section ,*/ node ) ;
							break ;
						}
					}
				}
				
				if ( type == ColladaParser.GROUP_IDENTIFIER ) counter ++ ;
			}
			
			return a ;
		}
		
		
		
		private function extractSection ( /*section : SceneSectionVO ,*/ xml : XML ) : Array
		{
			var a : Array = new Array ( ) ;
			
			for each ( var node : XML in xml[ ColladaNode.NODE ] )
			{
				var vo : SceneSectionVO = new SceneSectionVO ( ) ;
				var children : XMLList = node.children ( ) ;
				
				vo.id = node.@id ;
				vo.name = node.@name ;
				vo.values = this.extractPivot ( xml ) ;
				//vo.pivot = section.pivot ;
				vo.cameras = this.extractGroup ( ColladaParser.GROUP_CAMERA , vo , children ) ;
				vo.geometry = this.extractGroup ( ColladaParser.GROUP_GEOMETRY , vo , children ) ;
				vo.sections = this.extractGroup ( ColladaParser.GROUP_SECTION , vo , children ) ;
				
				a.push ( vo ) ;
				this.sections.push ( vo ) ;
			}
			
			return a ;
		}
		
		
		
		private function extractCameras ( section : SceneSectionVO , list : XMLList ) : Array
		{
			var cameras : Array = new Array ( ) ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER )
				{
					var vo : SceneCameraVO = new SceneCameraVO ( ) ;
					var values : SceneObjectVO = new SceneObjectVO ( ) ;
					var children : XMLList = node.children ( ) ;
					var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , children ) ;
					var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , children ) ;
					var extras : XMLList = ( node[ ColladaNode.EXTRA ][ ColladaNode.TECHNIQUE ][ ColladaNode.DYNAMIC_ATTRIBUTES ] as XMLList ).children ( ) ;
					
					this.applyPosition ( values , positions ) ;
					this.applyRotation ( values , rotations ) ;
					
					vo.id = node.@id ;
					vo.name = node.@name ;
					vo.parentSection = section ;
					vo.values = values ;
					
					if ( extras.toString ( ) != "" ) vo = this.extractCameraExtras ( vo , extras ) ;
					
					cameras.push ( vo ) ;
					this.cameras.push ( vo ) ;
				}
			}
			
			return cameras ;
		}
		
		
		
		private function extractCameraExtras ( vo : SceneCameraVO , extras : XMLList ) : SceneCameraVO
		{
			for each ( var node : XML in extras )
			{
				var attribute : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				var name : String = ( node.name ( ) ).toString ( ) ;
				var pair : Array = name.split ( "_" ) ;
				var prefix : String = pair[ 0 ] ;
				var key : String = pair[ 1 ] ;
				var value : String = node.toString ( ) ;
				
				attribute.key = key ;
				attribute.value = value ;
				
				switch ( prefix )
				{
					case ColladaParser.PREFIX_CAMERA :
					{
						vo.extras.push ( attribute ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
		
		
		
		private function extractGeometry ( section : SceneSectionVO , list : XMLList ) : Array
		{
			var geometry : Array = new Array ( ) ;
			
			for each ( var node : XML in list )
			{
				var type : String = node.@type ;
				
				if ( type == ColladaParser.GROUP_IDENTIFIER )
				{
					var vo : SceneGeometryVO = new SceneGeometryVO ( ) ;
					var values : SceneObjectVO = new SceneObjectVO ( ) ;
					var children : XMLList = node.children ( ) ;
					var positions : Array = this.extractValues ( ColladaNode.VALUE_TYPE_POSITION , children ) ;
					var rotations : Array = this.extractValues ( ColladaNode.VALUE_TYPE_ROTATION , children ) ;
					var scales : Array = this.extractValues ( ColladaNode.VALUE_TYPE_SCALE , children ) ;
					var extras : XMLList = ( node[ ColladaNode.EXTRA ][ ColladaNode.TECHNIQUE ][ ColladaNode.DYNAMIC_ATTRIBUTES ] as XMLList ).children ( ) ;
					
					this.applyPosition ( values , positions ) ;
					this.applyRotation ( values , rotations ) ;
					this.applyScale ( values , scales ) ;
					
					vo.id = node.@id ;
					vo.name = node.@name ;
					vo.values = values ;
					vo.enabled = section.enabled ;
					
					if ( extras.toString ( ) != "" ) vo = this.extractGeometryExtras ( vo , extras ) ;
					
					geometry.push ( vo ) ;
					this.geometry.push ( vo ) ;
				}
			}
			
			return geometry ;
		}
		
		
		
		private function extractGeometryExtras ( vo : SceneGeometryVO , extras : XMLList ) : SceneGeometryVO
		{
			for each ( var node : XML in extras )
			{
				var attribute : DynamicAttributeVO = new DynamicAttributeVO ( ) ;
				var name : String = ( node.name ( ) ).toString ( ) ;
				var pair : Array = name.split ( "_" ) ;
				var prefix : String = pair[ 0 ] ;
				var key : String = pair[ 1 ] ;
				var value : String = node.toString ( ) ;
				
				attribute.key = key ;
				attribute.value = value ;
				
				switch ( prefix )
				{
					case ColladaParser.PREFIX_GEOMETRY :
					{
						vo.geometryExtras.push ( attribute ) ;
						break ;
					}
					case ColladaParser.PREFIX_MATERIAL :
					{
						vo.materialExtras.push ( attribute ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
		
		
		
		private function extractValues ( type : String , list : XMLList ) : Array
		{
			var sList : String = list.toString ( ) ;
			var positions : Array = new Array ( 0 , 0 , 0 ) ;
			var rotations : Array = new Array ( 0 , 0 , 0 ) ;
			var scales : Array = new Array ( 1 , 1 , 1 ) ;
			var values : Array ;
			
			if ( sList != "" )
			{
				for each ( var node : XML in list )
				{
					var sNode : String = node.toString ( ) ;
					var sid : String = node.@sid ;
					
					switch ( sid )
					{
						case ColladaNode.TRANSLATE :
						{
							positions = sNode.split ( " " ) ;
							break ;
						}	
						case ColladaNode.ROTATE_X :
						{
							rotations[ 0 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.ROTATE_Y :
						{
							rotations[ 1 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.ROTATE_Z :
						{
							rotations[ 2 ] = this.extractLastEntry ( sNode ) ;
							break ;
						}	
						case ColladaNode.SCALE :
						{
							scales = sNode.split ( " " ) ;
							break ;
						}	
					}
				}
			}
			
			switch ( type )
			{
				case ColladaNode.VALUE_TYPE_POSITION :
				{
					values = positions ;
					break ;
				}	
				case ColladaNode.VALUE_TYPE_ROTATION :
				{
					values = rotations ;
					break ;
				}	
				case ColladaNode.VALUE_TYPE_SCALE :
				{
					values = scales ;
					break ;
				}	
			}
			
			return values ;
		}
		
		
		
		private function extractLastEntry ( sNode : String ) : Number
		{
			var values : Array = sNode.split ( " " ) ;
			var last : Number = values[ values.length - 1 ] ;
			
			return last ;
		}
		
		
		
		private function applyPosition ( target : SceneObjectVO , values : Array ) : void
		{
			target.x = values[ 0 ] ;
			target.y = values[ 1 ] ;
			target.z = values[ 2 ] ;
		}
		
		
		
		private function applyRotation ( target : SceneObjectVO , values : Array ) : void
		{
			target.rotationX = values[ 0 ] ;
			target.rotationY = values[ 1 ] ;
			target.rotationZ = values[ 2 ] ;
		}
		
		
		
		private function applyScale ( target : SceneObjectVO , values : Array ) : void
		{
			target.scaleX = values[ 0 ] ;
			target.scaleY = values[ 1 ] ;
			target.scaleZ = values[ 2 ] ;
		}
		
		
		
		/////////////////////////
		// GETTERS AND SETTERS //
		/////////////////////////
		
		
		
		public function set cameraZoom ( value : uint ) : void
		{
			this._cameraZoom = value ;
		}
		
		
		
		public function get cameraZoom ( ) : uint
		{
			return this._cameraZoom ;
		}
		
		
		
		public function set cameraFocus ( value : uint ) : void
		{
			this._cameraFocus = value ;
		}
		
		
		
		public function get cameraFocus ( ) : uint
		{
			return this._cameraFocus ;
		}
		
		
		
		public function get mainSections ( ) : Array
		{
			return this._mainSections ;
		}
		
		
		
		public function get geometry ( ) : Array
		{
			return this._geometry ;
		}
		
		
		
		public function get cameras ( ) : Array
		{
			return this._cameras ;
		}
		
		
		
		public function get sections ( ) : Array
		{
			return this._sections ;
		}
	}
}