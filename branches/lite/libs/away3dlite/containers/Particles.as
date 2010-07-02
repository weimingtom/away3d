package away3dlite.containers
{
	import away3dlite.arcane;
	import away3dlite.cameras.Camera3D;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.base.Particle;
	
	import flash.display.Sprite;
	import flash.geom.Matrix3D;

	use namespace arcane;

	/**
	 * Particles
	 * @author katopz
	 */
	public class Particles extends Object3D
	{
		private var _interactive:Boolean;
		private var _animate:Boolean;

		// linklist
		private var _firstParticle:Particle;
		private var _lastParticle:Particle;

		// still need array for sortOn
		public var lists:Array;

		public function Particles()
		{

		}

		override public function set layer(value:Sprite):void
		{
			super.layer = value;

			if (!_firstParticle)
				return;

			var particle:Particle = _firstParticle;
			if (particle)
				do
				{
					// layer dirty
					if (particle.layer != value)
						particle.layer = value;
				} while (particle = particle.next);
		}

		arcane override function updateScene(val:Scene3D):void
		{
			_scene = val;
		}

		/** @private */
		arcane override function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			super.project(camera, parentSceneMatrix3D);

			if (_scene.bitmap)
				_scene.bitmap.bitmapData.fillRect(_scene.bitmap.bitmapData.rect, 0x00000000);

			// by pass
			var _transform_matrix3D:Matrix3D = transform.matrix3D;
			var _particle:Particle = _firstParticle;
			if (_particle)
				do
					_particle.update(_viewMatrix3D, _transform_matrix3D); while (_particle = _particle.next);

			if (_animate && _scene)
				_scene.isDirty = true;
		}

		public function addParticle(particle:Particle):Particle
		{
			// add to lists
			if (!lists)
				lists = [];

			lists.push(particle);

			//link list
			if (!_firstParticle)
				_firstParticle = particle;

			if (_lastParticle)
				_lastParticle.next = particle;

			particle.prev = _lastParticle;

			_lastParticle = particle;

			particle.animate = _animate;
			particle.interactive = _interactive;

			particle.parent = this;
			particle.layer = _layer;

			return particle;
		}

		public function removeParticle(particle:Particle):Particle
		{
			if (!lists)
				return null;

			lists.splice(lists.indexOf(particle), 1);
			particle.parent = null;

			// prev, particle, next // prev -> next
			particle.prev = particle.next;

			return particle;
		}

		public function set animate(value:Boolean):void
		{
			_animate = value;
			var particle:Particle = _firstParticle;
			if (particle)
				do
				{
					particle.animate = _animate;
				} while (particle = particle.next);
		}

		public function set interactive(value:Boolean):void
		{
			_interactive = value;
			var particle:Particle = _firstParticle;
			if (particle)
				do
				{
					particle.interactive = _interactive;
				} while (particle = particle.next);
		}
		
		public function getParticleByID(id:String):Particle
		{
			var particle:Particle = _firstParticle;
			if (particle)
				do
				{
					if(particle.id == id)
						return particle;
				} while (particle = particle.next);
			return null;
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			for each (var _particle:Particle in lists)
				_particle.destroy();

			_firstParticle = null;
			_lastParticle = null;
			lists = null;

			super.destroy();
		}
	}
}