package away3dlite.containers
{
	import away3dlite.arcane;
	import away3dlite.cameras.Camera3D;
	import away3dlite.core.base.IRenderableList;
	import away3dlite.core.base.Object3D;
	import away3dlite.core.base.Particle;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix3D;

	use namespace arcane;

	/**
	 * Particles
	 * @author katopz
	 */
	public class Particles extends Object3D implements IRenderableList
	{
		private var _interactive:Boolean;
		private var _animate:Boolean;
		public var isDirty:Boolean;

		// linklist
		private var _firstParticle:Particle;
		private var _lastParticle:Particle;

		// still need array for sortOn
		private var _children:Array;

		public function get children():Array
		{
			return _children;
		}

		// bitmap
		private var _bitmap:Bitmap;

		public function get bitmap():Bitmap
		{
			return _bitmap;
		}

		public function set bitmap(value:Bitmap):void
		{
			_bitmap = value;

			if (_bitmap)
				_bitmapData = _bitmap.bitmapData;
			else
				_bitmapData = null;

			if (!_firstParticle)
				return;

			var particle:Particle = _firstParticle;
			if (particle)
				do
				{
					// bitmap dirty
					if (particle.bitmapData != _bitmapData)
						particle.bitmapData = _bitmapData;
				} while (particle = particle.next);
		}

		protected var _bitmapData:BitmapData;

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
					if (particle.graphics != value.graphics)
						particle.graphics = value.graphics;
				} while (particle = particle.next);
		}

		public function Particles()
		{

		}

		arcane override function updateScene(val:Scene3D):void
		{
			_scene = val;
		}

		/** @private */
		arcane override function project(camera:Camera3D, parentSceneMatrix3D:Matrix3D = null):void
		{
			super.project(camera, parentSceneMatrix3D);

			if (_bitmapData)
				_bitmapData.fillRect(_bitmapData.rect, 0x00000000);

			// by pass
			var _transform_matrix3D:Matrix3D = transform.matrix3D;
			var _particle:Particle = _firstParticle;
			if (_particle)
				do
					_particle.update(_viewMatrix3D, _transform_matrix3D);
				while (_particle = _particle.next);

			if (_scene && (_animate || isDirty))
			{
				_scene.isDirty = true;
				isDirty = false;
			}
		}

		public function addParticle(particle:Particle):Particle
		{
			// add to lists
			if (!_children)
				_children = [];

			_children.push(particle);

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
			particle.bitmapData = _bitmapData;

			// update position
			forceUpdate(particle);

			return particle;
		}

		public function removeParticle(particle:Particle):Particle
		{
			if (!_children)
				return null;

			_children.splice(_children.indexOf(particle), 1);
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
					if (particle.id == id)
						return particle;
				} while (particle = particle.next);
			return null;
		}

		public function forceUpdate(particle:Particle):void
		{
			particle.update(_viewMatrix3D, transform.matrix3D);
		}

		override public function destroy():void
		{
			if (_isDestroyed)
				return;

			for each (var particle:Particle in _children)
			{
				removeParticle(particle);
				particle.destroy();
			}

			_firstParticle = null;
			_lastParticle = null;
			_children = null;

			super.destroy();
		}
	}
}