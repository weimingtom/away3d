package away3d.primitives
{
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.core.base.Object3D;
	import away3d.core.base.Vertex;
	import away3d.core.draw.ScreenVertex;
	import away3d.core.math.Matrix3D;
	import away3d.core.math.Number3D;
	import away3d.core.render.BitmapRenderSession;
	import away3d.core.render.SpriteRenderSession;
	import away3d.events.ViewEvent;
	import away3d.materials.BitmapMaskMaterial;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.CompositeMaterial;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DisplacementMapFilterMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/* 
		Experimenting reflections injecting a secondary view into the plane material.
		
		Away3D engine changes to support this...
		- Added BitmapMaskMaterial. Review how this is implemented, seems overkill for only a slight change
		  in the render triangle method.
		- Added looking at target in Object3D. This is used to mirror the looking at point of the camera.
		  Review what would happen if lookAt is not used in the main camera...
		- Extended ViewEvent with type RENDER_COMPLETE.
	*/
	public class ReflectivePlane extends Plane
	{	
		//---------------------------------------------------------------------------------------------------------
		// static fields
		//---------------------------------------------------------------------------------------------------------
		
		public static const OPTICAL_MODE_REFLECTIVE:String = "reflectiveOpticMode";
		public static const OPTICAL_MODE_REFRACTIVE:String = "refractiveOpticMode";
		public static const OPTICAL_MODE_DUAL:String = "dualOpticMode";
		public static const RENDER_MODE_SPRITE:String = "spriteRenderMode";
		public static const RENDER_MODE_BITMAP:String = "bitmapRenderMode";
		
		//---------------------------------------------------------------------------------------------------------
		// private fields
		//---------------------------------------------------------------------------------------------------------
		
		private var _opticalModes:Array = [OPTICAL_MODE_REFLECTIVE, OPTICAL_MODE_REFRACTIVE, OPTICAL_MODE_DUAL];
		private var _renderModes:Array = [RENDER_MODE_SPRITE, RENDER_MODE_BITMAP];
		private var _zeroPoint:Point;
		private var _viewRect:Rectangle;
		private var _effectsBounds:Rectangle;
		private var _planeBounds:Rectangle;
		private var _camera:Camera3D;
		private var _view:View3D;
		private var _reflectionCamera:Camera3D;
		private var _reflectionView:View3D;
		private var _reflectionViewHolder:Sprite;
		private var _normal:Number3D;
		private var _reflectionMatrix3D:Matrix3D;
		private var _reflectionMatrix2D:Matrix;
		private var _plane2DRotation:Number = 0;
		private var _reflectionAlpha:Number = 1;
		private var _refractionAlpha:Number = 1;
		private var _reflectionColorTransform:ColorTransform;
		private var _refractionColorTransform:ColorTransform;
		private var _identityColorTransform:ColorTransform;
		private var _reflectionBlur:BlurFilter;
		private var _refractionBlur:BlurFilter;
		private var _hideList:Array;
		private var _opticalMode:String = OPTICAL_MODE_REFLECTIVE;
		private var _cameraOnFrontSide:Boolean;
		private var _materialBoundTolerance:Number = 0;
		private var _renderMode:String = RENDER_MODE_SPRITE;
		private var _bitmapRenderModeScale:Number = 2;
		private var _scaling:Number = 1;
		private var _backgroundImage:BitmapData;
		private var _smoothMaterials:Boolean;
		private var _backgroundColor:int;
		private var _backgroundAlpha:Number = 1;
		private var _redrawMatrix:Matrix;
		private var _compositeMaterial:CompositeMaterial;
		private var _backgroundMaterial:BitmapMaterial;
		private var _refractionMaterial:BitmapMaskMaterial;
		private var _reflectionMaterial:BitmapMaskMaterial;
		private var _backgroundBmd:BitmapData;
		private var _refractionBmd:BitmapData;
		private var _reflectionBmd:BitmapData;
		private var _v0:Vertex;
		private var _v1:Vertex;
		private var _v2:Vertex;
		private var _v3:Vertex;
		private var _sv0:ScreenVertex;
		private var _sv1:ScreenVertex;
		private var _sv2:ScreenVertex;
		private var _sv3:ScreenVertex;
		private var _useBackgroundImageForDistortion:Boolean = true;
		private var _bumpMapDummyPlane:Plane;
		private var _bumpMapContainer:Sprite;
		private var _distortionStrength:Number;
		private var _bumpMapBmd:BitmapData;
		private var _displacementMap:DisplacementMapFilter;
		private var _distortionChannel:uint = BitmapDataChannel.RED;
		private var _distortionImage:BitmapData;
		
		//TODO: Remove in final version.
		private var _debugLayer:Sprite;
		private var _debugBmp:Bitmap;
		private var _hasDebugGraphics:Boolean = false;
		
		//---------------------------------------------------------------------------------------------------------
		// setters & getters
		//---------------------------------------------------------------------------------------------------------
		
		//Virtual view.
		
			public function get reflectionView():View3D
			{
				return _reflectionView;
			}
		
		//Optical modes.
			
			public function set opticalMode(value:String):void
			{
				if(_opticalModes.indexOf(value) == -1)
					return;
				
				_opticalMode = value;
				
				buildMaterials();
			}
			public function get opticalMode():String
			{
				return _opticalMode;
			}
		
		//Rendering.
		
			public function set reflectionQuality(value:Number):void
			{
				value = value <= 0 ? 0.01 : value;
				value = value > 1 ? 1 : value;
				
				_scaling = 1/value;
				
				_reflectionViewHolder.scaleX = -_scaling;
				_reflectionViewHolder.scaleY = _scaling;
			}
			public function get reflectionQuality():Number
			{
				return 1/_scaling;
			}
		
			public function set renderMode(value:String):void
			{
				if(_renderModes.indexOf(value) == -1)
					return;
				
				if(_renderMode == value)
					return;
				
				if(!_view)
					return;
				
				_renderMode = value;
					
				if(_renderMode == RENDER_MODE_BITMAP)
					_reflectionView.session = new BitmapRenderSession(_bitmapRenderModeScale);
				else
					_reflectionView.session = new SpriteRenderSession();
			}
			public function get renderMode():String
			{
				return _renderMode;
			}
			
			public function set bitmapScaling(value:Number):void
			{
				_bitmapRenderModeScale = value;
				
				if(!_view)
					return;
				
				if(_renderMode == RENDER_MODE_BITMAP)
					_reflectionView.session = new BitmapRenderSession(_bitmapRenderModeScale);
			}
			public function get bitmapScaling():Number
			{
				return _bitmapRenderModeScale;
			}
		
		//Materials.
		
			public function set boundTolerance(value:Number):void
			{
				_materialBoundTolerance = value;
			}
			public function get boundTolerance():Number
			{
				return _materialBoundTolerance;
			}
		
			public function set smoothMaterials(value:Boolean):void
			{
				_smoothMaterials = value;
				
				if(!_compositeMaterial)
					return;
					
				_backgroundMaterial.smooth = value;
				_reflectionMaterial.smooth = value;
				_refractionMaterial.smooth = value;
			}
			public function get smoothMaterials():Boolean
			{
				return _smoothMaterials;
			}
		
			public function set backgroundImage(value:BitmapData):void
			{
				_backgroundImage = value;
				_backgroundColor = -1;
				
				buildMaterials();
			}
			public function get backgroundImage():BitmapData
			{
				return _backgroundBmd;
			}
		
			public function set backgroundColor(value:uint):void
			{
				_backgroundColor = value;
				_backgroundImage = null;
				
				if(_useBackgroundImageForDistortion)
					_displacementMap = null;
				
				buildMaterials();
			}
			public function get backgroundColor():uint
			{
				return _backgroundColor;
			}
		
			public function set backgroundAlpha(value:Number):void
			{
				_backgroundAlpha = value;
				_backgroundMaterial.alpha = value;
			}
			public function get backgroundAlpha():Number
			{
				return _backgroundAlpha;
			}
		
		//Optical adjustments.
		
			public function set reflectionBlur(value:Number):void
			{
				_reflectionBlur.blurX = value;
				_reflectionBlur.blurY = value;
			}
			public function get reflectionBlur():Number
			{
				return _reflectionBlur.blurX;
			}
			
			public function set reflectionBlurFilter(blur:BlurFilter):void
			{
				_reflectionBlur = blur;
			}
			public function get reflectionBlurFilter():BlurFilter
			{
				return _reflectionBlur;
			}
		
			public function set refractionBlur(value:Number):void
			{
				_refractionBlur.blurX = value;
				_refractionBlur.blurY = value;
			}
			public function get refractionBlur():Number
			{
				return _refractionBlur.blurX;
			}
			
			public function set refractionBlurFilter(blur:BlurFilter):void
			{
				_refractionBlur = blur;
			}
			public function get refractionBlurFilter():BlurFilter
			{
				return _refractionBlur;
			}
		
			public function set reflectionColorTransform(value:ColorTransform):void
			{
				_reflectionAlpha = value.alphaMultiplier;
				
				_reflectionColorTransform = value;
			}
			public function get reflectionColorTransform():ColorTransform
			{
				return _reflectionColorTransform;
			}
			
			public function set reflectionAlpha(value:Number):void
			{
				_reflectionAlpha = value;
				
				_reflectionColorTransform.alphaMultiplier = value;
			}
			public function get reflectionAlpha():Number
			{
				return _reflectionAlpha;
			}
		
			public function set refractionColorTransform(value:ColorTransform):void
			{
				_refractionAlpha = value.alphaMultiplier;
				
				_refractionColorTransform = value;
			}
			public function get refractionColorTransform():ColorTransform
			{
				return _refractionColorTransform;
			}
			
			public function set refractionAlpha(value:Number):void
			{
				_refractionAlpha = value;
				
				_refractionColorTransform.alphaMultiplier = value;
			}
			public function get refractionAlpha():Number
			{
				return _refractionAlpha;
			}
		
		//Distortion.
		
			public function set distortionStrength(value:Number):void
			{
				_distortionStrength = value;
			}
			public function get distortionStrength():Number
			{
				return _distortionStrength;
			}
			
			public function set distortionChannel(value:uint):void
			{
				_distortionChannel = value;
			}
			public function get distortionChannel():uint
			{
				return _distortionChannel;
			}
			
			public function set distortionImage(value:BitmapData):void
			{
				_distortionImage = value;
				
				buildDummyPlane();
			}
			public function get distortionImage():BitmapData
			{
				return _distortionImage;
			}
			
			public function set useBackgroundImageForDistortion(value:Boolean):void
			{
				if(_useBackgroundImageForDistortion == value)
					return;
					
				_useBackgroundImageForDistortion = value;
				
				if(value)
				{
					_distortionImage = null;
					
					if(this._backgroundColor != -1)
						_displacementMap = null;
					else
						buildDummyPlane();
				}
				else
					buildDummyPlane();
			}
			public function get useBackgroundImageForDistortion():Boolean
			{
				return _useBackgroundImageForDistortion;
			}
			
			//TODO: Remove in release.
			private var _enableDebugBoundingBox:Boolean = false;
			public function set enableDebugBoundingBox(value:Boolean):void
			{
				_enableDebugBoundingBox = value;
			}
			private var _enableDebugDummyPlane:Boolean = false;
			public function set enableDebugDummyPlane(value:Boolean):void
			{
				_enableDebugDummyPlane = value;
			}
			public function set enableDebugVisibleVirtualObjects(value:Boolean):void
			{
				_reflectionViewHolder.visible = value;
			}
		
		//---------------------------------------------------------------------------------------------------------
		// constructor and init
		//---------------------------------------------------------------------------------------------------------
		
		public function ReflectivePlane()
		{
			super();
			
			_zeroPoint = new Point();
			_planeBounds = new Rectangle();
			_refractionColorTransform = new ColorTransform();
			_reflectionColorTransform = new ColorTransform();
			_identityColorTransform = new ColorTransform();
			_reflectionBlur = new BlurFilter(0, 0, 1);
			_refractionBlur = new BlurFilter(0, 0, 1);
			
			_backgroundBmd = new BitmapData(1, 1, true, 0);
			_refractionBmd = new BitmapData(1, 1, true, 0);
			_refractionBmd = new BitmapData(1, 1, true, 0);
			_backgroundMaterial = new BitmapMaterial(_backgroundBmd);
			_refractionMaterial = new BitmapMaskMaterial(_refractionBmd);
			_reflectionMaterial = new BitmapMaskMaterial(_reflectionBmd);
			
			//Listens for scene change to trigger init().
			this.addOnSceneChange(sceneChangeHandler);
			
			//Listens for transform change to update plane data (normal and reflection matrixes) and dummy plane.
			this.addOnTransformChange(transformChangeHandler);
			this.addOnDimensionsChange(dimensionsChangeHandler);
		}
		
		private function init():void
		{
			this.removeOnSceneChange(sceneChangeHandler);
			
			//Find the main view automatically.
			var viewSet:Boolean;
			for each(var view:View3D in this.scene.viewDictionary)
			{
				if(!viewSet)
					_view = view;
			}
			_camera = view.camera;
			
			initSubScene();
			buildMaterials();
			calculatePlaneData();
			
			this.bothsides = true;
		}
		
		private function initSubScene():void
		{
			//Imitatest the main camera.
			_reflectionCamera = new Camera3D();
			_reflectionCamera.name = "virtualReflectionCamera";
			_reflectionCamera.focus = _camera.focus;
			_reflectionCamera.zoom = _camera.zoom;
			//_reflectionCamera.lens = _camera.lens; //TODO: Evaluate what other main view elements must be cloned.
			
			_reflectionView = new View3D({scene:this.scene, camera:_reflectionCamera});
			_reflectionView.name = "virtualReflectionView";
			//TODO: There could be a big performance boost here if the reflection view's clipping adapted more
			//intelligently to what will be actually redrawn on the plane. For now, it mimics the clipping of the main view.
			_reflectionView.clipping = _view.clipping;
			_reflectionView.mouseEnabled = false;
			_reflectionView.mouseChildren = false;
			_viewRect = new Rectangle(0, 0, _view.clipping.maxX - _view.clipping.minX, _view.clipping.maxY - _view.clipping.minY);
			
			if(_renderMode == RENDER_MODE_BITMAP)
				_reflectionView.session = new BitmapRenderSession(_bitmapRenderModeScale);
				
			//TODO: Remove in final version.
			//-----------------------------------
			_debugLayer = new Sprite();
			_debugBmp = new Bitmap();
			_debugLayer.addChild(_debugBmp);
			_debugLayer.x = _view.x;
			_debugLayer.y = _view.y;
			_view.parent.addChild(_debugLayer);
			//-----------------------------------
			
			//The reflection is placed on a holder, so that bitmap scaling techniques can be used
			//to control redrawing quality.
			_reflectionViewHolder = new Sprite();
			_reflectionViewHolder.x = _view.x;
			_reflectionViewHolder.y = _view.y;
			_reflectionViewHolder.addChildAt(_reflectionView, 0);
			_reflectionViewHolder.visible = false;
			_view.parent.addChild(_reflectionViewHolder); //TODO: Do not add at cero, add underneath.
			
			//TODO: Remove on final version.
			_reflectionViewHolder.alpha = 0.25;
			
			//TODO: What happens on stage resize?
	
			//Used to extract an image of the main view, used for refractions.
			_view.addEventListener(ViewEvent.UPDATE_SCENE, mainViewUpdateHandler);
			
			//Used to auto render the reflection view.
			_view.addEventListener(ViewEvent.RENDER_COMPLETE, mainViewRenderHandler); //I created this event in the engine.
				
			//A lot of comments to what the dummy plane is for below.
			if(_distortionStrength != 0)
				buildDummyPlane();
		}
		
		//---------------------------------------------------------------------------------------------------------
		// private methods
		//---------------------------------------------------------------------------------------------------------
		
		private function renderReflection():void
		{
			//Determines wether the camera is looking at the front,
			//or the backside of the plane.
			_cameraOnFrontSide = onFrontSide(_camera.position, false);
			
			//If camera is on the back side and the back material is externally set by the user,
			//no need to draw any reflection or refraction.
			if(!_cameraOnFrontSide && back)
				return;
				
			positionReflectionCamera(); //Uses the reflection matrix to mirror the refl camera.
			getPlaneBounds(); //Redrawing of the refl view occurs only for the relevant area, so plane bounds must be known.
			
			//Uses a dummy plane to get a perspectived image of the plane material or distortion image.
			//This image is used in a displacement map to distort the material. Might be overkill
			//but couldn't find another solution.
			updateBumpMapSource();
			
			
			if(_opticalMode == OPTICAL_MODE_REFLECTIVE || _opticalMode == OPTICAL_MODE_DUAL)
			{
				hideObjectsOnSide(); //Hides all objects on same side of refl camera including the plane (avoid holograms).
				_reflectionView.render();
				restoreObjectsOnSide(); //Restores hiden objects.
				
				//Redraws the reflection into the plane.
				updateLayerMaterial(_reflectionMaterial, _reflectionBmd, _reflectionColorTransform, _reflectionBlur);
			}
			
			//Refractive mode does not use the reflectionView. Instead, the class is listening
			//for scene update events and on such steals the main view image when the plane is not visible...
			//See captureCacheRefractiveBmd() method below.
			if(_opticalMode == OPTICAL_MODE_REFRACTIVE || _opticalMode == OPTICAL_MODE_DUAL)
				updateLayerMaterial(_refractionMaterial, _refractionBmd, _refractionColorTransform, _refractionBlur, false);
			
			this.material = _compositeMaterial;
		}
		
		//Redraws the refl view into the material of the plane. Can use input from the refl view or the 
		//main view depending on reflection or refraction respectively.
		//Also uses scaling of the refl view to manage redrawing quality.
		//Also applies blur, colorTransform and distortion effects to the redrawn image.
		private function updateLayerMaterial(layerMaterial:BitmapMaskMaterial, layerBmd:BitmapData, ct:ColorTransform, blur:BlurFilter, redrawBmd:Boolean = true):void
		{
			if(_planeBounds.width < 1 || _planeBounds.height < 1)
				return;
				
			if(_planeBounds.width > 2880 || _planeBounds.height > 2880)
				return;
			
			if(redrawBmd)
			{
				layerBmd = new BitmapData(_planeBounds.width/_scaling, _planeBounds.height/_scaling, true, 0x00000000);
				_redrawMatrix = new Matrix();
				_redrawMatrix.scale(1/_scaling, 1/_scaling);
				_redrawMatrix.translate(-_planeBounds.x/_scaling, -_planeBounds.y/_scaling);
				layerBmd.draw(_reflectionViewHolder, _redrawMatrix);
			}
			
			if(ct != _identityColorTransform)
				layerBmd.colorTransform(_effectsBounds, ct);
			
			if(blur)
			{
				if(blur.blurX != 0 || blur.blurY != 0)
					layerBmd.applyFilter(layerBmd, _effectsBounds, _zeroPoint, blur);
			}
			
			if(_distortionStrength != 0 && _displacementMap)
				layerBmd.applyFilter(layerBmd, _effectsBounds, _zeroPoint, _displacementMap);
				
			//Reflection and refraction materials are BitmapMaskMaterials.
			//These are identical to BitmapMaterials except that they dont pass a transformation matrix to 
			//AbstractRenderSession. They use renderTriangleBitmapMask in this method, which is just as
			//renderTriangleBitmap, but ignores transformations, except offsets and scales.
			layerMaterial.bitmap = layerBmd;
			layerMaterial.scaling = redrawBmd ? _scaling : 1;
			layerMaterial.offsetX = _planeBounds.x;
			layerMaterial.offsetY = _planeBounds.y;
		}
		
		//Redraws the container of the dummy plane and uses this image to distort the
		//reflection and refraction materials when updated.
		private function updateBumpMapSource():void
		{	
			if(_distortionStrength == 0)
				return;
			
			if(_useBackgroundImageForDistortion && _backgroundImage == null)
				return;
			
			if(_bumpMapContainer.width < 1 || _bumpMapContainer.height < 1)
				return;
			
			if(_bumpMapContainer.width > 2880 || _bumpMapContainer.height > 2880)
				return;
				
			_bumpMapBmd = new BitmapData(_planeBounds.width/_scaling, _planeBounds.height/_scaling, false, 0x000000);
			_redrawMatrix = new Matrix();
			_redrawMatrix.scale(1/_scaling, 1/_scaling);
			_redrawMatrix.translate(-_planeBounds.x/_scaling, -_planeBounds.y/_scaling);
			_bumpMapBmd.draw(_bumpMapContainer, _redrawMatrix);
			
			//TODO: Remove in final version.
			//------------------------------
			if(_enableDebugDummyPlane)
			{
				_debugBmp.x = -_view.x;
				_debugBmp.y = -_view.y;
				_debugBmp.bitmapData = _bumpMapBmd;
			}
			else
				_debugBmp.bitmapData = null;
			//------------------------------
			
			var k:int = _cameraOnFrontSide ? 1 : -1;
			_displacementMap = new DisplacementMapFilter(_bumpMapBmd, _zeroPoint,
					_distortionChannel, _distortionChannel, k*_distortionStrength,
					k*_distortionStrength, DisplacementMapFilterMode.IGNORE, 0xFFFF0000); 
		}
		
		//Looks for the plane's edges and determines the screen bounds for it. This is used to
		//redraw the reflectionView and main view into the plane materials.
		//It also considers inflating the bounds in order to give redrawing a bit of flexibility.
		private function getPlaneBounds():void
		{
			//TODO: Perhaps there is a faster way to fetch the on-screen plane bounds.
			//The array sorting below might be slow.
			
			_v0 = new Vertex(this.minX, this.minY, this.minZ);
			_v1 = new Vertex(this.maxX, this.minY, this.minZ);
			_v2 = new Vertex(this.maxX, this.maxY, this.maxZ);
			_v3 = new Vertex(this.minX, this.minY, this.maxZ);
			
			_sv0 = _view.camera.screen(this, _v0);
			_sv1 = _view.camera.screen(this, _v1);
			_sv2 = _view.camera.screen(this, _v2);
			_sv3 = _view.camera.screen(this, _v3);
			
			var xS:Array = [{x:_sv0.x}, {x:_sv1.x}, {x:_sv2.x}, {x:_sv3.x}];
			var yS:Array = [{y:_sv0.y}, {y:_sv1.y}, {y:_sv2.y}, {y:_sv3.y}];
			xS.sortOn("x", Array.NUMERIC);
			yS.sortOn("y", Array.NUMERIC);
			
			var minX:Number = Math.max(-_viewRect.width/2, xS[0].x);
			var minY:Number = Math.max(-_viewRect.height/2, yS[0].y);
			var maxX:Number = Math.min(_viewRect.width/2, xS[xS.length-1].x);
			var maxY:Number = Math.min(_viewRect.height/2, yS[yS.length-1].y);
			
			_planeBounds.x = minX;
			_planeBounds.y = minY;
			_planeBounds.width = maxX - minX;
			_planeBounds.height = maxY - minY;
			
			_planeBounds.inflate(_materialBoundTolerance, _materialBoundTolerance);
			
			_effectsBounds = new Rectangle(0, 0, _planeBounds.width, _planeBounds.height);
			
			//TODO: Remove in final version.
			//------------------------------
			if(_enableDebugBoundingBox)
			{
				_hasDebugGraphics = true;
				debugPlaneBoundingBox();
			}
			else if(_hasDebugGraphics)
			{
				_hasDebugGraphics = false;
				_debugLayer.graphics.clear();
			}
			//------------------------------
		}
		
		//Hides all scene objects that are on the same side of the refl camera according to the
		//reflection plane. Without this, the rendering of the reflectionView produces hologram reflections.
		private function hideObjectsOnSide():void
		{
			_hideList = [];
			
			for each(var obj:Object3D in this.scene.children)
			{
				if(!onFrontSide(obj.position))
				{
					obj.visible = false;
					_hideList.push(obj);
				}
			}
		}
		private function restoreObjectsOnSide():void
		{
			for each(var obj:Object3D in _hideList)
				obj.visible = true;
		}
		
		//Determines if an object is on the front side of the plane.
		private function onFrontSide(point:Number3D, allowCameraEval:Boolean = true):Boolean
		{
			var delta:Number3D = new Number3D();
			delta.sub(point, this.position);
			var proj:Number = delta.dot(_normal);
			
			if(allowCameraEval && !_cameraOnFrontSide)
				proj *= -1;
				
			return proj > 0;
		}
		
		//Reconstructs the composite material of the plane.
		//3 materials are used: 1 for the reflection, 1 for the refraction and 1 for the background of these two.
		private function buildMaterials():void
		{
			if(_backgroundImage)
			{
				_backgroundBmd = _backgroundImage; 
				_backgroundMaterial = new BitmapMaterial(_backgroundBmd);
			}
			else
				_backgroundBmd = new BitmapData(800, 600, false, _backgroundColor);
			_backgroundMaterial = new BitmapMaterial(_backgroundBmd);
			
			_compositeMaterial = new CompositeMaterial();
			_compositeMaterial.addMaterial(_backgroundMaterial);
			if(_opticalMode == OPTICAL_MODE_REFRACTIVE || _opticalMode == OPTICAL_MODE_DUAL)
				_compositeMaterial.addMaterial(_refractionMaterial);
			if(_opticalMode == OPTICAL_MODE_REFLECTIVE || _opticalMode == OPTICAL_MODE_DUAL)
				_compositeMaterial.addMaterial(_reflectionMaterial);
				
			_backgroundMaterial.smooth = _smoothMaterials;
			_reflectionMaterial.smooth = _smoothMaterials;
			_refractionMaterial.smooth = _smoothMaterials;	
				
			buildDummyPlane();
			
			backgroundAlpha = _backgroundAlpha;
		}
				
		//Applyes the 3D reflection matrix to position the refl camera as a mirror of the main camera,
		//according to the plane.
		private function positionReflectionCamera():void
		{
			_reflectionCamera.position = reflectPoint(_camera.position);
			_reflectionCamera.lookAt(reflectPoint(_camera.lookingAtTarget));
		}
		
		//Applies the 3D reflection matrix to any point and reflects it according to the plane.
		private function reflectPoint(point:Number3D):Number3D
		{
			var reflectedPoint:Number3D = new Number3D();
			reflectedPoint.sub(point, this.position);
			reflectedPoint.transform(reflectedPoint, _reflectionMatrix3D);
			reflectedPoint.add(reflectedPoint, this.position);
			
			return reflectedPoint;
		}
		
		//This is called on plane init() and each time it moves.
		//Calculates the global normal of the plane and the reflection matrixes for it.
		private function calculatePlaneData():void
		{
			var p0:Number3D = getVertexGlobalPosition(this.vertices[0]);
			var p1:Number3D = getVertexGlobalPosition(this.vertices[1]);
			var p2:Number3D = getVertexGlobalPosition(this.vertices[2]);
			
			var d0:Number3D = new Number3D();
			d0.sub(p1, p0);
			var d1:Number3D = new Number3D();
			d1.sub(p2, p0);
			
			_normal = new Number3D();
			_normal.cross(d0, d1);
			_normal.normalize();
			
			var a:Number = _normal.x;
			var b:Number = _normal.y;
			var c:Number = _normal.z;
			
			//This matrix is used to reflect any point in the scene according to the plane position
			//and orientation.
			_reflectionMatrix3D = new Matrix3D();
			_reflectionMatrix3D.sxx = 1 - 2*a*a;
			_reflectionMatrix3D.sxy = -2*a*b;
			_reflectionMatrix3D.sxz = -2*a*c;
			_reflectionMatrix3D.syx = -2*a*b;
			_reflectionMatrix3D.syy = 1 - 2*b*b;
			_reflectionMatrix3D.syz = -2*b*c;
			_reflectionMatrix3D.szx = -2*a*c;
			_reflectionMatrix3D.szy = -2*b*c;
			_reflectionMatrix3D.szz = 1 - 2*c*c;
			
			//This matrix is used to flip what the refl camera see's so that
			//it emulates the correct position of virtual objects in the refl view and hence
			//the reflection effect.
			_plane2DRotation = -this.rotationZ*Math.PI/180;
			_reflectionMatrix2D = _reflectionView.transform.matrix;
			_reflectionMatrix2D.a = Math.cos(2*_plane2DRotation);
			_reflectionMatrix2D.b = Math.sin(2*_plane2DRotation);
			_reflectionMatrix2D.c = Math.sin(2*_plane2DRotation);
			_reflectionMatrix2D.d = -Math.cos(2*_plane2DRotation);
			_reflectionView.transform.matrix = _reflectionMatrix2D;
		}
		
		//TODO: This is used to obtain global normal, maybe its not needed.
		//Quicker way?
		private function getVertexGlobalPosition(vertex:Vertex):Number3D
		{
			var m:Matrix3D = new Matrix3D();
	        m.tx = vertex.x;
	        m.ty = vertex.y;
	        m.tz = vertex.z;
	        m.multiply(this.transform, m);
			return new Number3D(m.tx, m.ty, m.tz);
		}
		
		//This is the only way I found to obtain a perspectived image of the plane's background material
		//for use in the distortion displacement map. It seems overkill and there must be a better way.
		//Besides, I dont like having a separate object in the scene for this, which the user has no
		//control of.
		private function buildDummyPlane():void
		{
			if(!this.scene)
				return;
			
			if(this.scene.children.indexOf(_bumpMapDummyPlane) != -1)
				this.scene.removeChild(_bumpMapDummyPlane);
			
			_bumpMapDummyPlane = new Plane();
			_bumpMapDummyPlane.name = "reflectionDistortionDummyPlane";
			_bumpMapDummyPlane.segmentsH = this.segmentsH;
			_bumpMapDummyPlane.segmentsW = this.segmentsW;
			_bumpMapDummyPlane.ownCanvas = true;
			_bumpMapDummyPlane.bothsides = true;
			
			updatePlaneDummyDimensions();
			updatePlaneDummyPosition();
			
			if(_distortionImage)
				_bumpMapDummyPlane.material = new BitmapMaterial(_distortionImage);
			else
			{	
				_bumpMapDummyPlane.material = _backgroundMaterial;
				BitmapMaterial(_bumpMapDummyPlane.material).alpha = 1;
			}
			
			//_bumpMapDummyPlane.pushback = true;
			_bumpMapDummyPlane.alpha = 0;
			
			scene.addChild(_bumpMapDummyPlane);
			_bumpMapContainer = _bumpMapDummyPlane.ownSession.getContainer(_view) as Sprite;
		}
		private function updatePlaneDummyDimensions():void
		{
			if(!_bumpMapDummyPlane)
				return;
			
			_bumpMapDummyPlane.width = this.width;
			_bumpMapDummyPlane.height = this.height;
		}
		private function updatePlaneDummyPosition():void
		{
			if(!_bumpMapDummyPlane)
				return;
				
			_bumpMapDummyPlane.position = this.position;
			_bumpMapDummyPlane.rotationX = this.rotationX;
			_bumpMapDummyPlane.rotationY = this.rotationY;
			_bumpMapDummyPlane.rotationZ = this.rotationZ;
		}
		
		//Called each time the main view scene updates.
		//A bitmap of the main view is captured and this image is used for refractions.
		//Extracted images are outdated (this is why refractions have more lag), but performance
		//is greatly boosted, since this makes no need for the refl view in refractions.
		private function captureCacheRefractiveBmd():void
		{
			if(_planeBounds.width < 1 || _planeBounds.height < 1)
				return;
			
			if(_planeBounds.width > 2880 || _planeBounds.height > 2880)
				return;
			
			_refractionBmd = new BitmapData(_planeBounds.width, _planeBounds.height, true, 0x00FF0000);
			_redrawMatrix = new Matrix();
			_redrawMatrix.translate(_planeBounds.width/2, _planeBounds.height/2);
			_refractionBmd.draw(_view, _redrawMatrix);
		}
		
		//---------------------------------------------------------------------------------------------------------
		// event handlers
		//---------------------------------------------------------------------------------------------------------
		
		private function sceneChangeHandler(event:Event):void
		{
			init();
		}
		
		private function transformChangeHandler(event:Event):void
		{
			calculatePlaneData();
			updatePlaneDummyPosition();
		}
		
		private function dimensionsChangeHandler(event:Event):void
		{
			updatePlaneDummyDimensions();
		}
		
		private function mainViewRenderHandler(event:Event):void
		{
			renderReflection();
		}
		
		private function mainViewUpdateHandler(event:Event):void
		{
			if(_opticalMode == OPTICAL_MODE_REFLECTIVE)
				return;
			
			captureCacheRefractiveBmd();
		}
		
		//---------------------------------------------------------------------------------------------------------
		// debugging methods (remove in release version)
		//---------------------------------------------------------------------------------------------------------
		
		private function debugPlaneBoundingBox():void
		{
			_debugLayer.graphics.clear();
			
			traceScreenVertex(_sv0, 0xFF0000);
			traceScreenVertex(_sv1, 0x00FF00);
			traceScreenVertex(_sv2, 0x0000FF);
			traceScreenVertex(_sv3, 0xFFFFFF); 
			
			_debugLayer.graphics.beginFill(0xFF0000, 0.25);
			_debugLayer.graphics.moveTo(_sv0.x, _sv0.y);
			_debugLayer.graphics.lineTo(_sv1.x, _sv1.y);
			_debugLayer.graphics.lineTo(_sv2.x, _sv2.y);
			_debugLayer.graphics.lineTo(_sv3.x, _sv3.y);
			_debugLayer.graphics.lineTo(_sv0.x, _sv0.y);
			_debugLayer.graphics.endFill();  
			
			_debugLayer.graphics.beginFill(0x00FF00, 0.25);
			_debugLayer.graphics.moveTo(_planeBounds.x, _planeBounds.y);
			_debugLayer.graphics.lineTo(_planeBounds.x + _planeBounds.width, _planeBounds.y);
			_debugLayer.graphics.lineTo(_planeBounds.x + _planeBounds.width, _planeBounds.y + _planeBounds.height);
			_debugLayer.graphics.lineTo(_planeBounds.x, _planeBounds.y + _planeBounds.height);
			_debugLayer.graphics.lineTo(_planeBounds.x, _planeBounds.y);
			_debugLayer.graphics.endFill();	 
		}
		
		private function traceScreenVertex(sv:ScreenVertex, color:uint):void
		{
			_debugLayer.graphics.beginFill(color);
			_debugLayer.graphics.drawCircle(sv.x, sv.y, 3);
			_debugLayer.graphics.endFill();
		}
	}
}