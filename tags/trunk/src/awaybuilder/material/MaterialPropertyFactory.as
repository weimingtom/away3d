package awaybuilder.material
{
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.DynamicAttributeVO;
	
	
	
	public class MaterialPropertyFactory
	{
		public function MaterialPropertyFactory ( )
		{
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		public function build ( vo : SceneGeometryVO ) : SceneGeometryVO
		{
			var boolean : Boolean ;
			
			for each ( var attribute : DynamicAttributeVO in vo.materialExtras )
			{
				switch ( attribute.key )
				{
					case MaterialAttributes.ALPHA :
					{
						vo.material[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.AMBIENT :
					{
						vo.material[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.ASSET_CLASS :
					{
						vo[ attribute.key ] = attribute.value ;
						break ;
					}
					case MaterialAttributes.ASSET_FILE :
					{
						vo[ attribute.key ] = attribute.value ;
						break ;
					}
					case MaterialAttributes.ASSET_FILE_BACK :
					{
						vo[ attribute.key ] = attribute.value ;
						break ;
					}
					case MaterialAttributes.COLOR :
					{
						vo.material[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.DIFFUSE :
					{
						vo.material[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.PRECISION :
					{
						vo[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.SMOOTH :
					{
						attribute.value == "1" ? boolean = true : boolean = false ;
						vo[ attribute.key ] = boolean ;
						break ;
					}
					case MaterialAttributes.SPECULAR :
					{
						vo.material[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.WIDTH :
					{
						vo.material[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.WIREALPHA :
					{
						vo.material[ attribute.key ] = Number ( attribute.value ) ;
						break ;
					}
					case MaterialAttributes.WIRECOLOR :
					{
						vo.material[ attribute.key ] = uint ( attribute.value ) ;
						break ;
					}
				}
			}
			
			return vo ;
		}
	}
}