package
{
	import away3dlite.containers.Particles;
	import away3dlite.core.base.Particle;
	import away3dlite.core.clip.RectangleClipping;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	[SWF(backgroundColor="#000000", frameRate="30", quality="MEDIUM", width="800", height="600")]
	/**
	 * Particles Example
	 * @author katopz
	 */
	public class ExParticles extends BasicTemplate
	{
		private var particles:Particles;
		private var particleMaterial:ParticleMaterial;

		private const radius:uint = 350;
		private const max:int = 3000;
		private const size:uint = 10;

		private const _totalFrames:uint = 30;

		private var step:Number = 0;
		private var segment:Number;

		override protected function onInit():void
		{
			scrollRect = new Rectangle(0, 0, _customWidth, _customHeight);
			
			title = "Away3DLite | Particles : " + max + " | Click to toggle Particles Draw mode (sprite/bitmap)";

			// speed up
			view.mouseEnabled = false;
			
			// clipping
			clipping = new RectangleClipping();
			clipping.minX = -300;
			clipping.minY = -200;
			clipping.maxX = 300;
			clipping.maxY = 200;

			// create materials
			particleMaterial = createParticleMaterial(size, size);

			// create particles
			particles = new Particles(true);
			
			/* layer test
			particles.layer = new Sprite();
			addChild(particles.layer);
			particles.layer.filters = [new BlurFilter(4,4)]
			particles.layer.x = _customWidth/2;
			particles.layer.y = _customHeight/2;
			*/
			
			segment = size + 2 * Math.PI / (size * 1.25);

			var i:Number = (stage.stageHeight - 100) / max;
			for (var j:int = 0; j < max; j++)
			{
				var _particle:Particle = new Particle
				(
					radius * Math.cos(segment * j),
					i * (j - max / 2),
					radius * Math.sin(segment * j),
					particleMaterial.clone()
				)
				particles.addParticle(_particle);

				// each particle effect (slow warning!)
				//_particle.blendMode = BlendMode.OVERLAY;
				//_particle.filters = [new GlowFilter(0xFF00FF, .5, 6, 6, 1, 1, true)];
			}

			scene.addChild(particles);

			// center
			scene.addChild(new Sphere(null, 100, 6, 6));

			// orbit
			for (j = 0; j < 6; j++)
			{
				var sphere:Sphere = new Sphere(null, 25, 6, 6);
				scene.addChild(sphere);
				sphere.x = (radius + 50) * Math.cos(i);
				sphere.z = (radius + 50) * Math.sin(i);
				i += 2 * Math.PI / 6;
			}

			// toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			// debug
			var debugRect:Shape = new Shape();
			debugRect.graphics.lineStyle(1, 0xFF0000);
			debugRect.graphics.drawRect(clipping.minX, clipping.minY, Math.abs(clipping.minX) + clipping.maxX, Math.abs(clipping.minY) + clipping.maxY);
			debugRect.graphics.endFill();
			
			debugRect.x = _customWidth/2;
			debugRect.y = _customHeight/2;
			addChild(debugRect);
		}

		private function createParticleMaterial(_width:Number, _height:Number):ParticleMaterial
		{
			var bitmapData:BitmapData = new BitmapData(_width * _totalFrames, _height, true, 0x00000000);
			var _material:ParticleMaterial = new ParticleMaterial(bitmapData, _width, _height, _totalFrames);

			for (var i:int = 0; i < _totalFrames; i++)
			{
				var shape:Shape = new Shape();
				drawDot(shape.graphics, -size / 2, -size / 2, size / 2, 0xFFFFFF - 0xFFFFFF * Math.sin(Math.PI * i / 30), 0xFFFFFF);

				bitmapData.draw(shape, new Matrix(1, 0, 0, 1, (i * _width) + _width, _height));
			}

			addChild(bitmap = new Bitmap(bitmapData)).y = 80;

			return _material;
		}

		private var bitmap:Bitmap;

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
				scene.bitmap.filters = [new BlurFilter(6, 6)];
				scene.bitmap.blendMode = BlendMode.ADD;
			}
			else
			{
				removeChild(scene.bitmap);
				scene.bitmap = null;
			}
		}

		override protected function onPreRender():void
		{
			scene.rotationY += .5;
			scene.rotationZ += .5;

			/*
			   camera.x = 1000 * Math.cos(step);
			   camera.y = 10 * (300 - mouseY);
			   camera.z = 1000 * Math.sin(step);
			   camera.lookAt(new Vector3D());
			 */

			step += .01;
		}
	}
}