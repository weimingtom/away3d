package awaybuilder
{
	import away3d.containers.ObjectContainer3D;	import away3d.containers.View3D;	import away3d.core.base.Mesh;	import away3d.core.base.Object3D;	import away3d.loaders.Collada;	import away3d.loaders.Object3DLoader;	import away3d.materials.BitmapFileMaterial;	import away3d.materials.BitmapMaterial;	import away3d.materials.MovieMaterial;		import awaybuilder.abstracts.AbstractBuilder;	import awaybuilder.camera.CameraFactory;	import awaybuilder.events.SceneEvent;	import awaybuilder.geometry.GeometryAttributes;	import awaybuilder.geometry.GeometryFactory;	import awaybuilder.geometry.GeometryType;	import awaybuilder.interfaces.IAssetContainer;	import awaybuilder.interfaces.IBuilder;	import awaybuilder.interfaces.ISceneContainer;	import awaybuilder.material.MaterialAttributes;	import awaybuilder.material.MaterialFactory;	import awaybuilder.material.MaterialType;	import awaybuilder.utils.ConvertCoordinates;	import awaybuilder.vo.DynamicAttributeVO;	import awaybuilder.vo.SceneCameraVO;	import awaybuilder.vo.SceneGeometryVO;	import awaybuilder.vo.SceneObjectVO;	import awaybuilder.vo.SceneSectionVO;		import flash.display.BitmapData;	import flash.display.DisplayObject;	import flash.display.MovieClip;	import flash.events.Event;
	
	
	
	public class SceneBuilder extends AbstractBuilder implements IBuilder , IAssetContainer , ISceneContainer
	{
		public var coordinateSystem : String ;
		public var precision : uint ;
		
		protected var view : View3D ;
		protected var cameras : Array = [ ] ;
		protected var geometry : Array = [ ] ;
		protected var sections : Array = [ ] ;
		protected var mainSections : Array ;
		protected var cameraFactory : CameraFactory ;
		protected var materialFactory : MaterialFactory ;
		protected var geometryFactory : GeometryFactory ;
		protected var bitmapDataAssets : Array = [ ] ;
		protected var displayObjectAssets : Array = [ ] ;
		protected var colladaAssets : Array = [ ] ;
		
		
		
		public function SceneBuilder ( )
		{
			super ( ) ;
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Public Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		override public function build ( view : View3D , sections : Array ) : void
		{
			this.view = view ;
			this.mainSections = sections ;
			
			this.createCameraFactory ( ) ;
			this.createGeometryFactory ( ) ;
			this.createMaterialFactory ( ) ;
			this.createSections ( ) ;
			this.applyValues ( ) ;
			
			this.dispatchEvent ( new Event ( Event.COMPLETE ) ) ;
		}
		
		
		
		override public function addBitmapDataAsset ( id : String , data : BitmapData ) : void
		{
			this.bitmapDataAssets[ id ] = data ;
		}
		
		
		
		override public function addDisplayObjectAsset ( id : String , data : DisplayObject ) : void
		{
			this.displayObjectAssets[ id ] = data ;
		}
		
		
		
		override public function addColladaAsset ( id : String , data : XML ) : void
		{
			this.colladaAssets[ id ] = data ;
		}
		
		
		
		override public function getCameras ( ) : Array
		{
			return this.cameras ;
		}

		
		
		override public function getGeometry ( ) : Array
		{
			return this.geometry ;
		}

		
		
		override public function getSections ( ) : Array
		{
			return this.sections ;
		}

		
		
		override public function getCameraById ( id : String ) : SceneCameraVO
		{
			for each ( var vo : SceneCameraVO in this.cameras )
			{
				if ( vo.id == id ) return vo ;
			}
			
			if ( this.cameras.length == 0 )
			{
				throw new Error ( "no cameras available" ) ;
			}
			else
			{
				throw new Error ( "camera with id [" + id + "] not found" ) ;
			}
		}
		
		
		
		override public function getGeometryById ( id : String ) : SceneGeometryVO
		{
			for each ( var vo : SceneGeometryVO in this.geometry )
			{
				if ( vo.id == id ) return vo ;
			}
			
			if ( this.geometry.length == 0 )
			{
				throw new Error ( "no geometry available" ) ;
			}
			else
			{
				throw new Error ( "geometry with id [" + id + "] not found" ) ;
			}
		}
		
		
		
		////////////////////////////////////////////////////////////////////////////////
		//
		// Protected Methods
		//
		////////////////////////////////////////////////////////////////////////////////
		
		
		
		protected function createCameraFactory ( ) : void
		{
			this.cameraFactory = new CameraFactory ( ) ;
		}

		
		
		protected function createGeometryFactory ( ) : void
		{
			this.geometryFactory = new GeometryFactory ( ) ;
			this.geometryFactory.coordinateSystem = this.coordinateSystem ;
			this.geometryFactory.precision = this.precision ;
		}
		
		
		
		protected function createMaterialFactory ( ) : void
		{
			this.materialFactory = new MaterialFactory ( ) ;
		}
		
		
		
		protected function createSections ( ) : void
		{
			for each ( var section : SceneSectionVO in this.mainSections )
			{
				if ( section.enabled ) this.createSection ( section ) ;
			}
		}
		
		
		
		protected function createSection ( section : SceneSectionVO ) : void
		{
			if ( section.enabled )
			{
				this.view.scene.addChild ( section.pivot ) ;
				this.createCameras ( section ) ;
				this.createGeometry ( section ) ;
				this.createSubSections ( section ) ;
				this.sections.push ( section ) ;
			}
		}
		
		
		
		protected function createSubSections ( section : SceneSectionVO ) : void
		{
			for each ( var subSection : SceneSectionVO in section.sections )
			{
				this.createSection ( subSection ) ;
			}
		}
		
		
		
		protected function applyValues ( ) : void
		{
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
			
			for each ( var geometryVO : SceneGeometryVO in this.geometry )
			{
				switch ( geometryVO.geometryType )
				{
					case GeometryType.COLLADA :
					{
						break ;
					}
					default :
					{
						this.applyPosition ( geometryVO.mesh , geometryVO.values ) ;
						this.applyMeshRotation ( geometryVO.mesh , geometryVO.values ) ;
						this.applyScale ( geometryVO.mesh as Mesh , geometryVO.values ) ;
					}
				}
			}
			
			// FIXME: Implement group position and scale conversion.
			for each ( var sectionVO : SceneSectionVO in this.mainSections )
			{
				this.applyPosition ( sectionVO.pivot , sectionVO.values ) ;
				this.applyGroupRotation ( sectionVO.pivot , sectionVO.values ) ;
				this.applyPivotScale ( sectionVO.pivot , sectionVO.values ) ;
			}
			
			for each ( var cameraVO : SceneCameraVO in this.cameras )
			{
				/* FIXME: Camera to be relative to section pivot coordinates.
				this.applyPosition ( cameraVO.positionContainer , cameraVO.values ) ;
				this.applyMeshRotation ( cameraVO.positionContainer , cameraVO.values ) ;
				
				cameraVO.camera.transform = cameraVO.positionContainer.sceneTransform ;
				*/
				
				this.applyPosition ( cameraVO.camera , cameraVO.values ) ;
				this.applyCameraRotation ( cameraVO.camera , cameraVO.values ) ;
			}
			
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
		}
		
		
		
		protected function applyColladaValues ( target : Object3D , values : SceneObjectVO ) : void
		{
			this.applyPosition ( target , values ) ;
			this.applyColladaRotation ( target , values ) ;
			this.applyColladaScale ( target , values ) ;
		}
		
		
		
		protected function createCameras ( section : SceneSectionVO ) : void
		{
			for each ( var vo : SceneCameraVO in section.cameras )
			{
				/* FIXME: Camera to be relative to section pivot coordinates.
				vo.parentSection = section ;
				vo.positionContainer = new ObjectContainer3D ( ) ;
				
				section.pivot.addChild ( vo.positionContainer ) ;
				*/
				
				vo = this.cameraFactory.build ( vo ) ;
				this.cameras.push ( vo ) ;
			}
		}
		
		
		
		protected function createGeometry ( section : SceneSectionVO ) : void
		{
			for each ( var geometry : SceneGeometryVO in section.geometry )
			{
				var useDefaultGeometry : Boolean = true ;
				
				this.createMaterial ( geometry ) ;
				
				for each ( var attribute : DynamicAttributeVO in geometry.geometryExtras )
				{
					switch ( attribute.key )
					{
						case GeometryAttributes.CLASS :
						{
							geometry = this.geometryFactory.build ( attribute , geometry ) ;
							useDefaultGeometry = false ;
							break ;
						}
					}
				}
				
				if ( useDefaultGeometry ) geometry = geometryFactory.buildDefault ( geometry ) ;
				
				this.applyExternalAssets ( section , geometry ) ;
			}
		}
		
		
		
		protected function createMaterial ( geometry : SceneGeometryVO ) : void
		{
			var useDefaultMaterial : Boolean = true ;
			
			for each ( var attribute : DynamicAttributeVO in geometry.materialExtras )
			{
				switch ( attribute.key )
				{
					case MaterialAttributes.CLASS :
					{
						geometry = materialFactory.build ( attribute , geometry ) ;
						useDefaultMaterial = false ;
						break ;
					}
				}
			}
			
			if ( useDefaultMaterial )
			{
				geometry = materialFactory.buildDefault ( geometry ) ;
			}
		}
		
		
		
		protected function applyExternalAssets ( section : SceneSectionVO , vo : SceneGeometryVO ) : void
		{
			switch ( vo.materialType )
			{
				case MaterialType.BITMAP_MATERIAL :
				{
					var bitmapData : BitmapData = this.bitmapDataAssets[ vo.assetClass ] ;
					
					vo.materialData = bitmapData ;
					vo.material = new BitmapMaterial ( bitmapData ) ;
					vo.material[ MaterialAttributes.SMOOTH ] = vo.smooth ;
					vo.material[ MaterialAttributes.PRECISION ] = vo.precision ;
					Mesh ( vo.mesh ).material = vo.material as BitmapMaterial ;
					break ;
				}
				case MaterialType.BITMAP_FILE_MATERIAL :
				{
					vo.material = new BitmapFileMaterial ( vo.assetFile ) ;
					vo.material[ MaterialAttributes.SMOOTH ] = vo.smooth ;
					vo.material[ MaterialAttributes.PRECISION ] = vo.precision ;
					Mesh ( vo.mesh ).material = vo.material as BitmapFileMaterial ;
					
					if ( vo.assetFileBack )
					{
						vo.materialBack = new BitmapFileMaterial ( vo.assetFileBack ) ;
						vo.materialBack[ MaterialAttributes.SMOOTH ] = vo.smooth ;
						vo.materialBack[ MaterialAttributes.PRECISION ] = vo.precision ;
						Mesh ( vo.mesh ).back = vo.materialBack as BitmapFileMaterial ;
					}
					
					break ;
				}
				case MaterialType.MOVIE_MATERIAL :
				{
					var movieClip : MovieClip = this.displayObjectAssets[ vo.assetClass ] ;
					
					vo.materialData = movieClip ;
					vo.material = new MovieMaterial ( movieClip ) ;
					Mesh ( vo.mesh ).material = vo.material as MovieMaterial ;
					break ;
				}
			}
			
			switch ( vo.geometryType )
			{
				case GeometryType.COLLADA :
				{
					if ( vo.assetClass != null )
					{
						var xml : XML = this.colladaAssets[ vo.assetClass ] ;
						var container : ObjectContainer3D = Collada.parse ( xml ) ;
						
						vo.mesh = container ;
						section.pivot.addChild ( container ) ;
						this.applyColladaValues ( container , vo.values ) ;
					}
					else if ( vo.assetFile != null )
					{
						var loader : Object3DLoader = Collada.load ( vo.assetFile ) ;
						
						vo.mesh = ( loader.handle ) ;
						loader.extra = vo ;
						loader.addOnSuccess ( this.onColladaLoadSuccess ) ;
						section.pivot.addChild ( loader ) ;
					}
					
					break ;
				}
				default :
				{
					if ( vo.enabled )
					{
						section.pivot.addChild ( vo.mesh ) ;
					}
				}
			}
			
			this.geometry.push ( vo ) ;
		}
						protected function onColladaLoadSuccess ( event : Event ) : void
		{
			var loader : Object3DLoader = event.target as Object3DLoader ;
			var handle : Object3D = loader.handle ;
			var vo : SceneGeometryVO = loader.extra as SceneGeometryVO ;
			
			this.applyColladaValues ( handle , vo.values ) ;
			this.dispatchEvent ( new SceneEvent ( SceneEvent.RENDER ) ) ;
		}

		
		
		protected function applyPosition ( target : Object3D , values : SceneObjectVO ) : void
		{
			var s : uint = this.precision ;
			var c : String = this.coordinateSystem ;
			
			target.x = s * ConvertCoordinates.positionX ( values.x , c ) ;
			target.y = s * ConvertCoordinates.positionY ( values.y , c ) ;
			target.z = s * ConvertCoordinates.positionZ ( values.z , c ) ;
		}
		
		
		
		protected function applyMeshRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			var c : String = this.coordinateSystem ;
			
			target.rotationX = ConvertCoordinates.meshRotationX ( values.rotationX , c ) ;
			target.rotationY = ConvertCoordinates.meshRotationY ( values.rotationY , c ) ;
			target.rotationZ = ConvertCoordinates.meshRotationZ ( values.rotationZ , c ) ;
		}
		
		
		
		protected function applyGroupRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			var c : String = this.coordinateSystem ;
			
			target.rotationX = ConvertCoordinates.groupRotationX ( values.rotationX , c ) ;
			target.rotationY = ConvertCoordinates.groupRotationY ( values.rotationY , c ) ;
			target.rotationZ = ConvertCoordinates.groupRotationZ ( values.rotationZ , c ) ;
		}
		
		
		
		protected function applyColladaRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			var c : String = this.coordinateSystem ;
			
			target.rotationX = ConvertCoordinates.colladaRotationX ( values.rotationX , c ) ;
			target.rotationY = ConvertCoordinates.colladaRotationY ( values.rotationY , c ) ;
			target.rotationZ = ConvertCoordinates.colladaRotationZ ( values.rotationZ , c ) ;
		}
		
		
		
		protected function applyCameraRotation ( target : Object3D , values : SceneObjectVO ) : void
		{
			var c : String = this.coordinateSystem ;
			
			target.rotationX = ConvertCoordinates.cameraRotationX ( values.rotationX , c ) ;
			target.rotationY = ConvertCoordinates.cameraRotationY ( values.rotationY , c ) ;
			target.rotationZ = ConvertCoordinates.cameraRotationZ ( values.rotationZ , c ) ;
		}
		
		
		
		protected function applyScale ( target : Mesh , values : SceneObjectVO ) : void
		{
			// NOTE: Input Y and Z are switched. This is due to differences in creation plane.
			target.scaleX = values.scaleX ;
			target.scaleY = values.scaleZ ;
			target.scaleZ = values.scaleY ;
		}
		
		
		
		protected function applyPivotScale ( target : Object3D , values : SceneObjectVO ) : void
		{
			target.scale ( values.scaleX ) ;
		}

		
		
		protected function applyColladaScale ( target : Object3D , values : SceneObjectVO ) : void
		{
			var multiplier : uint ;
			
			switch ( this.coordinateSystem )
			{
				case CoordinateSystem.MAYA :
				{
					// NOTE: The divider is due to the Collada class having an internal scaling multiplier of 100.
					multiplier = this.precision / 100 ;
					break ;
				}
				case CoordinateSystem.NATIVE :
				{
					multiplier = 1 ;
					break ;
				}
			}
			// FIXME: Use custom geometry scaling property instead of geometry x scale value?
			target.scale ( multiplier * values.scaleX ) ;
		}
	}
}