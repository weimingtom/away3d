package awaybuilder.geometry
{
	import flash.events.Event;
	
	import away3d.core.base.Object3D;
	
	import awaybuilder.abstracts.AbstractGeometryController;
	import awaybuilder.events.GeometryEvent;
	import awaybuilder.interfaces.IGeometryController;
	import awaybuilder.vo.SceneGeometryVO;
	import awaybuilder.vo.SceneSectionVO;
	
	
		public class GeometryController extends AbstractGeometryController implements IGeometryController
	{
		protected var geometry : Array ;
		
		
		
		public function GeometryController ( geometry : Array )
		{
			super ( ) ;
			this.geometry = geometry ;
		}

		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function enableInteraction ( ) : void
		{
			for each ( var geometry : SceneGeometryVO in this.geometry )
			{
				this.enableGeometryInteraction ( geometry ) ;
			}
		}
		
		
		
		override public function disableInteraction ( ) : void
		{
			for each ( var geometry : SceneGeometryVO in this.geometry )
			{
				this.disableGeometryInteraction ( geometry ) ;
			}
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function extractGeometry ( mainSection : SceneSectionVO , allGeometry : Array , cascade : Boolean = false ) : Array
		{
			for each ( var geometry : SceneGeometryVO in mainSection.geometry )
			{
				allGeometry.push ( geometry ) ;
			}
			
			if ( cascade )
			{
				for each ( var subSection : SceneSectionVO in mainSection.sections )
				{
					var a : Array = this.extractGeometry ( subSection , allGeometry ) ;
					allGeometry.concat ( a ) ;
				}
			}
			
			return allGeometry ;
		}
		
		
		
		protected function enableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			this.disableGeometryInteraction ( geometry ) ;
			
			if ( geometry.mouseDownEnabled )
			{
				geometry.mesh.addOnMouseDown ( this.geometryMouseDown ) ;
			}
			
			if ( geometry.mouseMoveEnabled )
			{
				geometry.mesh.addOnMouseMove ( this.geometryMouseMove) ;
			}
			
			if ( geometry.mouseOutEnabled )
			{
				geometry.mesh.addOnMouseOut ( this.geometryMouseOut ) ;
			}
			
			if ( geometry.mouseOverEnabled )
			{
				geometry.mesh.addOnMouseOver ( this.geometryMouseOver ) ;
			}
			
			if ( geometry.mouseUpEnabled )
			{
				geometry.mesh.addOnMouseUp ( this.geometryMouseUp ) ;
			}
		}
		
		
		
		protected function disableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			geometry.mesh.removeOnMouseDown ( this.geometryMouseDown ) ;
			geometry.mesh.removeOnMouseMove ( this.geometryMouseMove ) ;
			geometry.mesh.removeOnMouseOut ( this.geometryMouseOut ) ;
			geometry.mesh.removeOnMouseOver ( this.geometryMouseOver ) ;
			geometry.mesh.removeOnMouseUp ( this.geometryMouseUp ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Event Handlers
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function geometryMouseDown ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.DOWN ) ;
					
					interactionEvent.geometry = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseMove ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.MOVE ) ;
					
					interactionEvent.geometry = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseOut ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.OUT ) ;
					
					interactionEvent.geometry = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseOver ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.OVER ) ;
					
					interactionEvent.geometry = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
		
		
		
		protected function geometryMouseUp ( event : Event ) : void
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.mesh == event.target )
				{
					var interactionEvent : GeometryEvent = new GeometryEvent ( GeometryEvent.UP ) ;
					
					interactionEvent.geometry = vo ;
					this.dispatchEvent ( interactionEvent ) ;
					break ;
				}
			}
		}
	}
}