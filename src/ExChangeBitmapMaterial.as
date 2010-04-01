package
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.cameras.*;
	import away3dlite.cameras.lenses.PerspectiveLens;
	import away3dlite.containers.*;
	import away3dlite.core.base.Mesh;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.utils.*;
	import away3dlite.events.*;
	import away3dlite.loaders.*;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.utils.*;
	
	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="360")]

	/**
	 * Change BitmapMaterial example.
	 */
	public class ExChangeBitmapMaterial extends BasicTemplate
	{
		private var collada:Collada;
		private var loader:Loader3D;
		private var loaded:Boolean = false;
		private var model:Object3D;
		private var skinAnimation:BonesAnimator;
		
		private function onSuccess(event:Loader3DEvent):void
		{
			loaded = true;
			model = loader.handle;
			model.layer = new Sprite();
			view.addChild(model.layer);

			// Apply some change to object to make it appear as I want
			model.transform.matrix3D.identity();
			model.transform.matrix3D.appendRotation( 90, new Vector3D(1,0,0));
			model.transform.matrix3D.appendRotation(180, new Vector3D(0,1,0));
			model.transform.matrix3D.appendTranslation(
				-((-0.7685800194740295) + (0.7679924368858337))*0.5,
				-((-1.0577828884124756) + (0.767961859703064 ))*0.5,
				-(-0.05018693208694458)
			);
			model.transform.matrix3D.appendScale(9, 9, 9);
			
			var pose4x4 : Vector.<Number> = new Vector.<Number>(16);
			pose4x4[ 0] = 0.9983117580413818
			pose4x4[ 1] = -0.052813105285167694;
			pose4x4[ 2] = -0.024173574522137642;
			pose4x4[ 3] = 0;
			pose4x4[ 4] = -0.027764596045017242;
			pose4x4[ 5] = -0.7994808554649353;
			pose4x4[ 6] = 0.6000495553016663;
			pose4x4[ 7] = 0;
			pose4x4[ 8] = -0.05101679265499115;
			pose4x4[ 9] = -0.5983654260635376;
			pose4x4[10] = -0.7995975017547607;
			pose4x4[11] = 0;
			pose4x4[12] = -0.01358937006443739;
			pose4x4[13] = 4.1685357093811035;
			pose4x4[14] = 19.230161666870117;
			pose4x4[15] = 1;				
			scene.transform.matrix3D.rawData = pose4x4;
			camera.transform.matrix3D.identity();
			
			skinAnimation = model.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		private var imgLoader:Loader = new Loader();
		
		/**
		 * @inheritDoc
		 */
		override protected function onInit():void
		{
			title += " : Change BitmapMaterial Example: Click onto objects to change texture";
			Debug.active = true;

			var url:URLRequest = new URLRequest("assets/moon.jpg");
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoad3DObject);
			imgLoader.load(url);
		}
		
		private var newBitmap:BitmapData;
			
		private function onLoad3DObject(event:Event):void
		{
			newBitmap = ((imgLoader.content) as Bitmap).bitmapData;
			
			// init camera
			var FOCAL_VALUE:Number = 415.69220099999995;  
			var focus:Number = 1;
			var zoom:Number = FOCAL_VALUE/focus;
			camera.lens = new PerspectiveLens();
			camera.zoom = zoom;
			camera.focus = focus;
			camera.z=0;

			renderer.useFloatZSort = true;
			
			collada = new Collada();
			collada.scaling = 1.5;

			loader = new Loader3D();
			loader.loadGeometry("assets/Total_Immersion_Anim_Object2_matrix_keys.dae", collada);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			scene.addChild(loader);
			
			scene.addEventListener(MouseEvent3D.MOUSE_UP, onSceneMouseUp);
		}
		
	    private function onSceneMouseUp(e:MouseEvent3D):void
	    {
	        if (e.object is Mesh)
			{
	            var mesh:Mesh = e.object as Mesh;
	            //mesh.material = new WireColorMaterial();
	            mesh.material = new BitmapMaterial(newBitmap);
	            mesh.updateMaterials();
	        }
	    }
		
		/**
		 * @inheritDoc
		 */
		override protected function onPreRender():void
		{
			//update the collada animation
			if(skinAnimation)
				skinAnimation.update(getTimer()/1000);
			
			//scene.rotationY++;
		}
	}
}