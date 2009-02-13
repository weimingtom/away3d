package awaybuilder.geometry
{	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.DynamicAttributeVO;
	
	
		public class GeometryPropertyFactory
	{
		public var precision : uint ;
		
		
		
		public function GeometryPropertyFactory ( )
		{
		}
		
		
				////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			for each ( var attribute : DynamicAttributeVO in vo.geometryExtras )
			{
				var boolean : Boolean ;
				
				switch ( attribute.key )
				{
					case GeometryAttributes.ASSET_CLASS :
					{
						vo.assetClass = attribute.value ;
						break ;
					}
					case GeometryAttributes.ASSET_FILE :
					{
						vo.assetFile = attribute.value ;
						break ;
					}
					case GeometryAttributes.ASSET_FILE_BACK :
					{
						vo.assetFileBack = attribute.value ;
						break ;
					}
					case GeometryAttributes.BOTHSIDES :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mesh[ attribute.key ] = boolean ;
						break ;
					}
					case GeometryAttributes.DEPTH :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.enabled = boolean ;
						break ;
					}
					case GeometryAttributes.HEIGHT :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.MOUSE_DOWN_ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mouseDownEnabled = boolean ;
						break ;
					}
					case GeometryAttributes.MOUSE_MOVE_ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mouseMoveEnabled = boolean ;
						break ;
					}
					case GeometryAttributes.MOUSE_OUT_ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mouseOutEnabled = boolean ;
						break ;
					}
					case GeometryAttributes.MOUSE_OVER_ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mouseOverEnabled = boolean ;
						break ;
					}
					case GeometryAttributes.MOUSE_UP_ENABLED :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mouseUpEnabled = boolean ;
						break ;
					}
					case GeometryAttributes.OWN_CANVAS :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mesh[ attribute.key ] = boolean ;
						break ;
					}
					case GeometryAttributes.RADIUS :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.SEGMENTS_W :
					{
						vo.mesh[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.SEGMENTS_H :
					{
						vo.mesh[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.SEGMENTS_R :
					{
						vo.mesh[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.SEGMENTS_T :
					{
						vo.mesh[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.TARGET_CAMERA :
					{
						vo.targetCamera = attribute.value ;
						break ;
					}
					case GeometryAttributes.TUBE :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.USE_HAND_CURSOR :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mesh[ attribute.key ] = boolean ;
						break ;
					}
					case GeometryAttributes.WIDTH :
					{
						vo.mesh[ attribute.key ] = this.precision * Number ( attribute.value ) ;
						break ;
					}
					case GeometryAttributes.Y_UP :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo.mesh[ attribute.key ] = boolean ;
						break ;
					}
				}
			}
			
			return vo ;
		}
	}}