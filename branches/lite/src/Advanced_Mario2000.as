package
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
		private var particles:Particles;
		new par
		private var particleMaterial:ParticleMaterial;

		private const size:uint = 25;


		private var step:Number = 0;

		private var skinAnimation:BonesAnimator;

		private var amount:uint = 13;
		private const max:int = amount * amount * amount;

		override protected function onInit():void
		{
			title = "Away3DLite | Particles : " + max + " | Click to toggle Particles Draw mode (sprite/bitmap)";

			// speed up
			view.mouseEnabled = false;
			view.mouseEnabled3D = false;

			//camera.z = -2000;

			// clipping
			clipping = new RectangleClipping();
			clipping.minX = -300;
			clipping.minY = -200;

			clipping.maxX = 300;
			clipping.maxY = 200;

			// create materials
			bitmapData = new BitmapData(size, size, true, 0x00000000);
			particleMaterial = new ParticleMaterial(bitmapData, size, size);

			// create particles
			particles = new Particles();
			//particles.animate = true;
			/* layer test
			   particles.layer = new Sprite();
			   addChild(particles.layer);
			   particles.layer.filters = [new BlurFilter(4,4)]
			   particles.layer.x = _customWidth/2;
			   particles.layer.y = _customHeight/2;
			 */

			/*
			   segment = size + 2 * Math.PI / (size * 1.25);
			   var i:Number = (stage.stageHeight - 100) / max;
			   for (var j:int = 0; j < max; j++)
			   {
			   var _particle:Particle = new Particle
			   (
			   radius * Math.cos(segment * j),
			   i * (j - max / 2),
			   radius * Math.sin(segment * j),
			   particleMaterial
			   )
			   particles.addParticle(_particle);

			   // each particle effect (slow warning!)
			   //_particle.blendMode = BlendMode.OVERLAY;
			   //_particle.filters = [new GlowFilter(0xFF00FF, .5, 6, 6, 1, 1, true)];
			   }
			 */

			var _factor:Number = 0.25 * max;
			var gap:int = _factor / (amount - 1);

			for (var i:int = 0; i < amount; ++i)
			{
				for (var j:int = 0; j < amount; ++j)
				{
					for (var k:int = 0; k < amount; ++k)
					{
						var _particle:Particle = new Particle(gap * i - _factor / 2, gap * j - _factor / 2, gap * k - _factor / 2, particleMaterial);
						particles.addParticle(_particle);
					}
				}
			}

			scene.addChild(particles);

			// toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);

			// debug
			var debugRect:Shape = new Shape();
			debugRect.graphics.lineStyle(1, 0xFF0000);
			debugRect.graphics.drawRect(clipping.minX, clipping.minY, Math.abs(clipping.minX) + clipping.maxX, Math.abs(clipping.minY) + clipping.maxY);
			debugRect.graphics.endFill();

			debugRect.x = _screenRect.width / 2;
			debugRect.y = _screenRect.height / 2;
			addChild(debugRect);

			var collada:Collada = new Collada();
			collada.scaling = 2;

			var loader:Loader3D = new Loader3D();
			loader.loadGeometry("assets/mario_testrun.dae", collada);
			loader.addEventListener(Loader3DEvent.LOAD_SUCCESS, onSuccess);
			scene.addChild(loader);
		}

		private function onSuccess(event:Loader3DEvent):void
		{
			model = event.loader.handle;
			model.canvas = new Sprite();
			view.addChild(model.canvas);
			model.y = 10;
			model.canvas.visible = false;

			skinAnimation = event.loader.handle.animationLibrary.getAnimation("default").animation as BonesAnimator;
		}

		private var model:Object3D;
		private var bitmapData:BitmapData;

		private function drawDot(_graphics:Graphics, x:Number, y:Number, size:Number, colorLight:uint, colorDark:uint):void
		{
			var colors:Array = [colorLight, colorDark, colorLight];
			var alphas:Array = [1.0, 1.0, 1.0];
			var ratios:Array = [0, 200, 255];
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(size * 2, size * 2, 0, x - size, y - size);

			_graphics.lineStyle();
			_graphics.beginGradientFill(GradientType.RADIAL, colors, alphas, ratios, matrix);
			_graphics.drawCircle(x, y, size);
			_graphics.endFill();
		}

		private function onClick(event:MouseEvent):void
		{
			if (!scene.bitmap)
			{
				scene.bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000));
				addChild(scene.bitmap);

					// bitmap effect
					//scene.bitmap.filters = [new BlurFilter(6, 6)];
					//scene.bitmap.blendMode = BlendMode.ADD;
			}
			else
			{
				removeChild(scene.bitmap);
				scene.bitmap = null;
			}
		}

		private function updateBitmapdata():void
		{
			bitmapData.fillRect(bitmapData.rect, 0x00000000);
			bitmapData.draw(model.canvas, new Matrix(1, 0, 0, 1, model.canvas.width / 2, model.canvas.height / 2));
		}

		override protected function onPreRender():void
		{
			scene.rotationX += .5;
			scene.rotationY += .5;
			scene.rotationZ += .5;

			if (model && model.canvas)
				updateBitmapdata();

			step += .01;

			if (skinAnimation)
				skinAnimation.update(getTimer() / 1000);
		}
	}
}