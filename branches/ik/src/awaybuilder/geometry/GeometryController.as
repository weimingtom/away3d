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
		private var geometry : Array ;
		
		
		
		public function GeometryController ( geometry : Array )
		{
			super ( ) ;
			this.geometry = geometry ;
		}

		
		
		////////////////////
		// PUBLIC METHODS //
		////////////////////
		
		
		
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
		
		
		
		override public function toString ( ) : String
		{
			return "GeometryController" ;
		}
		
		
		
		/////////////////////
		// PRIVATE METHODS //
		/////////////////////
		
		
		
		private function extractGeometry ( mainSection : SceneSectionVO , allGeometry : Array , cascade : Boolean = false ) : Array
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
		
		
		
		private function enableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			this.disableGeometryInteraction ( geometry ) ;
			
			if ( geometry.mouseDownEnabled )
			{
				geometry.mesh.addOnMouseDown ( this.onGeometryMouseDown ) ;
			}
			
			if ( geometry.mouseMoveEnabled )
			{
				geometry.mesh.addOnMouseMove ( this.onGeometryMouseMove) ;
			}
			
			if ( geometry.mouseOutEnabled )
			{
				geometry.mesh.addOnMouseOut ( this.onGeometryMouseOut ) ;
			}
			
			if ( geometry.mouseOverEnabled )
			{
				geometry.mesh.addOnMouseOver ( this.onGeometryMouseOver ) ;
			}
			
			if ( geometry.mouseUpEnabled )
			{
				geometry.mesh.addOnMouseUp ( this.onGeometryMouseUp ) ;
			}
		}
		
		
		
		private function disableGeometryInteraction ( geometry : SceneGeometryVO ) : void
		{
			geometry.mesh.removeOnMouseDown ( this.onGeometryMouseDown ) ;
			geometry.mesh.removeOnMouseMove ( this.onGeometryMouseMove ) ;
			geometry.mesh.removeOnMouseOut ( this.onGeometryMouseOut ) ;
			geometry.mesh.removeOnMouseOver ( this.onGeometryMouseOver ) ;
			geometry.mesh.removeOnMouseUp ( this.onGeometryMouseUp ) ;
		}
		
		
		
		////////////////////
		// EVENT HANDLERS //
		////////////////////
		
		
		
		private function onGeometryMouseDown ( event : Event ) : void
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
		
		
		
		private function onGeometryMouseMove ( event : Event ) : void
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
		
		
		
		private function onGeometryMouseOut ( event : Event ) : void
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
		
		
		
		private function onGeometryMouseOver ( event : Event ) : void
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
		
		
		
		private function onGeometryMouseUp ( event : Event ) : void
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