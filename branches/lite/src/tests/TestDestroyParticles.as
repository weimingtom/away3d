package tests
{
	import away3dlite.containers.Particles;
	import away3dlite.core.base.Particle;
	import away3dlite.materials.*;
	import away3dlite.primitives.*;
	import away3dlite.templates.BasicTemplate;

	import flash.display.*;
	import flash.events.*;
	import flash.geom.Matrix;
	import flash.system.System;

	[SWF(backgroundColor="#000000", frameRate="30", width="800", height="600")]
	/**
	 * @author katopz
	 */
	public class TestDestroyParticles extends BasicTemplate
	{
		[Embed(source="../basics/assets/dot.swf", symbol="DotClip")]
		private var _DotClip:Class;
		private var _dotClip:MovieClip = new _DotClip();

		private var _particles:Particles;
		private const _size:uint = 32;

		override protected function onInit():void
		{
			title = "Click to Create and Destroy Particles |";

			create();

			stage.addEventListener(MouseEvent.CLICK, onClick);
		}

		private function onClick(event:MouseEvent):void
		{
			dispose();
			create();
		}

		private function create():void
		{
			_particles = new Particles();
			_particles.animate = true;

			var _particleMaterial:ParticleMaterial = createParticleMaterial(_dotClip, _size, _size);

			for (var i:int = 0; i < 100; i++)
			{
				var _particle:Particle = new Particle(_particleMaterial.clone(), 400 * Math.random() - 200, 400 * Math.random() - 200, 400 * Math.random() - 200);
				_particles.addParticle(_particle);
			}

			scene.addChild(_particles);
		}

		private function createParticleMaterial(movieClip:MovieClip, _width:Number, _height:Number):ParticleMaterial
		{
			var _totalFrames:int = movieClip.totalFrames;
			var bitmapData:BitmapData = new BitmapData(_width * _totalFrames, _height, true, 0x00000000);
			var _material:ParticleMaterial = new ParticleMaterial(bitmapData, _width, _height, _totalFrames);

			for (var i:int = 0; i < _totalFrames; i++)
			{
				movieClip.gotoAndStop(i + 1);
				bitmapData.draw(movieClip, new Matrix(1, 0, 0, 1, (i * _width), 0));
			}

			return _material;
		}

		private function dispose():void
		{
			_particles.destroy();
			_particles = null;

			// gc
			System.gc();
		}

		override protected function onPreRender():void
		{
			scene.rotationY++;
		}
	}
}