package
{
	import away3dlite.containers.Particles;
	import away3dlite.core.base.Particle;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;

	[SWF(backgroundColor="#000000",frameRate="30",quality="MEDIUM",width="800",height="600")]
	/**
	 * Particles Example
	 * @author katopz
	 */
	public class ExParticles extends BasicTemplate
	{
		private var particles:Particles;
		private var particleMaterial:ParticleMaterial;

		private const radius:uint = 200;
		private const max:int = 2000;
		private const size:uint = 10;

		private const _totalFrames:uint = 30;

		private var step:Number = 0;
		private var segment:Number;
		 
		override protected function onInit():void
		{
			title = "Away3DLite | Particles : " + max + " | Click to toggle Particles BlendMode.INVERT | ";

			// speed up
			view.mouseEnabled = false;

			// create materials
			particleMaterial = createParticleMaterial(size, size);

			// create particles
			particles = new Particles(true);

			segment = size + 2 * Math.PI / (size * 1.25);

			var i:Number = (stage.stageHeight-100)/max;
			for (var j:int = 0; j < max; j++)
			{
				particles.addParticle(new Particle(
				radius * Math.cos(segment * j),
				i*(j - max/2),
				radius * Math.sin(segment * j), 
				particleMaterial));
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

			// layer test
			stage.addEventListener(MouseEvent.CLICK, onClick);
			
			view.visible = false;
			
			view.x = stage.stageWidth/2;
			view.y = stage.stageHeight/2;
			
			scene.bitmap = new Bitmap(new BitmapData(stage.stageWidth, stage.stageHeight, true, 0x00000000));
			//scene.bitmap.x = view.x;
			//scene.bitmap.y = view.y;
			addChild(scene.bitmap);
			
			///for(var ii:int = 0; ii<10; ii++)
			//	view.addChild(new Bitmap(new BitmapData(800,600)));
		}

		private function createParticleMaterial(_width:Number, _height:Number):ParticleMaterial
		{
			var bitmapData:BitmapData = new BitmapData(_width * _totalFrames, _height, true, 0x00000000);
			var _material:ParticleMaterial = new ParticleMaterial(bitmapData, _width, _height, _totalFrames);

			for (var i:int = 0; i < _totalFrames; i++)
			{
				var shape:Shape = new Shape();
				drawDot(shape.graphics,-size/2,-size/2, size/2, 0xFFFFFF - 0xFFFFFF * Math.sin(Math.PI * i / 30), 0xFFFFFF);
				
				//TODO:MovieClip//_clip.gotoAndStop(i + 1);

				bitmapData.draw(shape, new Matrix(1, 0, 0, 1, (i * _width) + _width, _height));
			}
			
			addChild(bitmap = new Bitmap(bitmapData)).y = 200;

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
			if (scene.bitmap.blendMode != BlendMode.ADD)
			{
				/*
				particles.layer = new Sprite();
				particles.layer.blendMode = BlendMode.INVERT;
				view.addChild(particles.layer);
				*/
				scene.bitmap.blendMode = BlendMode.INVERT;
			}
			else
			{
				/*
				view.removeChild(particles.layer);
				particles.layer = null;
				*/
				scene.bitmap.blendMode = BlendMode.NORMAL;
			}
		}
		
		override protected function onPreRender():void
		{
			scene.rotationY += .5;
			//scene.rotationZ += .5;
			/*
			camera.x = 1000 * Math.cos(step);
			camera.y = 10 * (300 - mouseY);
			camera.z = 1000 * Math.sin(step);
			camera.lookAt(new Vector3D(0, 0, 0));
			
			step += .01*/
		}
	}
}