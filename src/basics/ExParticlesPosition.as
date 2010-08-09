package basics
{
	import away3dlite.containers.Particles;
	import away3dlite.core.base.Particle;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.*;

	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * Particles Position Example
	 * @author katopz
	 */
	public class ExParticlesPosition extends BasicTemplate
	{
		private var _particles:Particles;
		private var _particleMaterial:ParticleMaterial;

		private const radius:uint = 100;
		private const size:uint = 10;

		private const _totalFrames:uint = 30;

		override protected function onInit():void
		{
			title = "Away3DLite | Particles Position | Click to toggle Particles Draw mode (sprite/bitmap)";

			// create materials
			_particleMaterial = createParticleMaterial(size);

			// create particles
			_particles = new Particles();
			scene.addChild(_particles);

			// positions
			_particles.addParticle(new Particle(_particleMaterial.clone(), radius, 0, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, radius, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, 0, radius));

			_particles.addParticle(new Particle(_particleMaterial.clone(), -radius, 0, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, -radius, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, 0, -radius));
			
			// clip positions
			_particles.addParticle(new Particle(_particleMaterial.clone(), radius*12, 0, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, radius*12, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, 0, radius*12));
			
			_particles.addParticle(new Particle(_particleMaterial.clone(), -radius*12, 0, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, -radius*12, 0));
			_particles.addParticle(new Particle(_particleMaterial.clone(), 0, 0, -radius*12));

			// center
			scene.addChild(new Sphere(null, 100, 6, 6));

			// toggle
			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function createParticleMaterial(radius:Number):ParticleMaterial
		{
			var bitmapData:BitmapData = new BitmapData(radius * 2, radius * 2, true, 0x00000000);
			var _material:ParticleMaterial = new ParticleMaterial(bitmapData, radius * 2, radius * 2);

			var shape:Shape = new Shape();
			shape.graphics.lineStyle();
			shape.graphics.beginFill(0xFF00FF, 0.75);
			shape.graphics.drawCircle(0, 0, radius);
			shape.graphics.endFill();

			bitmapData.draw(shape, new Matrix(1, 0, 0, 1, radius, radius));

			return _material;
		}

		private function onClick(event:MouseEvent):void
		{
			if (!_particles.bitmap)
			{
				_particles.bitmap = new Bitmap(new BitmapData(view.screenWidth, view.screenHeight, true, 0x00000000));
				addChild(_particles.bitmap);

				// bitmap effect
				_particles.bitmap.filters = [new BlurFilter(8, 8)];
				_particles.bitmap.blendMode = BlendMode.ADD;
			}
			else
			{
				removeChild(_particles.bitmap);
				_particles.bitmap.bitmapData.dispose();
				_particles.bitmap = null;
			}
		}

		override protected function onPreRender():void
		{
			scene.rotationX += .5;
			scene.rotationY += .5;
			scene.rotationZ += .5;
		}
	}
}