package advances
{
	import away3dlite.animators.BonesAnimator;
	import away3dlite.containers.Particles;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.base.Particle;
	import away3dlite.core.clip.RectangleClipping;
	import away3dlite.events.Loader3DEvent;
	import away3dlite.loaders.Collada;
	import away3dlite.loaders.Loader3D;
	import away3dlite.materials.*;
	import away3dlite.templates.*;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.utils.*;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Particles Example
	 * @author katopz
	 */
	public class Advanced_Mario2000 extends BasicTemplate
	{
		private const size:uint = 25;
		private const amount:uint = 13;
		private const max:uint = amount * amount * amount;

		private var _step:uint = 0;

		private var _model:Object3D;
		private var _bonesAnimator:BonesAnimator;

		private var _particles:Particles;
		private var _particleMaterial:ParticleMaterial;

		private var _bitmapData:BitmapData;

		override protected function onInit():void
		{
			title = "Away3DLite | Particles : " + max + " | Click to toggle Particles Draw mode (sprite/bitmap)";

			// speed up
			view.mouseEnabled = false;
			view.mouseEnabled3D = false;

			// clipping
			clipping = new RectangleClipping();
			clipping.minX = -300;
			clipping.minY = -200;

			clipping.maxX = 300;
			clipping.maxY = 200;

			// create materials
			_bitmapData = new BitmapData(size, size, true, 0x00000000);
			_particleMaterial = new ParticleMaterial(_bitmapData, size, size);

			// create particles
			_particles = new Particles();

			var _factor:Number = 0.25 * max;
			var gap:int = _factor / (amount - 1);

			for (var i:int = 0; i < amount; ++i)
				for (var j:int = 0; j < amount; ++j)
					for (var k:int = 0; k < amount; ++k)
					{
						var _particle:Particle = new Particle(_particleMaterial, gap * i - _factor / 2, gap * j - _factor / 2, gap * k - _factor / 2);
						_particles.addParticle(_particle);
					}

			scene.addChild(_particles);

			// toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);

			// debug
			var debugRect:Shape = new Shape();
			debugRect.graphics.lineStyle(1, 0xFF0000);
			debugRect.graphics.drawRect(clipping.minX, clipping.minY, Math.abs(clipping.minX) + clipping.maxX, Math.abs(clipping.minY) + clipping.maxY);
			debugRect.graphics.endFill();

			debugRect.x = screenRect.width / 2;
			debugRect.y = screenRect.height / 2;
			addChild(debugRect);

			var collada:Collada = new Collada();
			collada.scaling = 2;

			var loader:Loader3D = new Loader3D();
			loader.loadGeometry("../src/advances/assets/mario_testrun.dae", collada);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			scene.addChild(loader);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			_model = event.loader.handle;
			_model.canvas = new Sprite();
			view.addChild(_model.canvas);
			_model.y = 10;
			_model.canvas.visible = false;

			_bonesAnimator = event.loader.handle.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		private function onClick(event:MouseEvent):void
		{
			if (!_particles.bitmap)
			{
				_particles.bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000));
				addChild(_particles.bitmap);
				title = "Away3DLite | Particles : " + max + " | (Click to toggle) Draw as Bitmap |";
			}
			else
			{
				removeChild(_particles.bitmap);
				_particles.bitmap.bitmapData.dispose();
				_particles.bitmap = null;
				title = "Away3DLite | Particles : " + max + " | (Click to toggle) Draw as Sprite |";
			}
		}

		private function updateBitmapdata():void
		{
			_bitmapData.fillRect(_bitmapData.rect, 0x00000000);
			_bitmapData.draw(_model.canvas, new Matrix(1, 0, 0, 1, _model.canvas.width / 2, _model.canvas.height / 2));
		}

		override protected function onPreRender():void
		{
			scene.rotationX += .5;
			scene.rotationY += .5;
			scene.rotationZ += .5;

			if (_model && _model.canvas)
				updateBitmapdata();

			_step += .01;

			if (_bonesAnimator)
				_bonesAnimator.update(getTimer() / 1000);
		}
	}
}