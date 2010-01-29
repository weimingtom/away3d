package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.containers.View3D;
	import away3dlite.materials.ParticleMaterial;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	
	use namespace arcane;

	/**
	 * Particle
	 * @author katopz
	 */
	public final class Particle extends Vector3D
	{
		public var animated:Boolean = false;
		public var smooth:Boolean = false;

		public var screenZ:Number;
		public var next:Particle;

		public var layer:Sprite;

		// projected position
		private var _position:Vector3D;

		private var _matrix:Matrix;
		private var _center:Point;

		private var _bitmapData:BitmapData;
		private var _bitmapData_width:Number;
		private var _bitmapData_height:Number;

		private var _scale:Number = 1;

		public var material:ParticleMaterial;

		public function Particle(x:Number, y:Number, z:Number, material:ParticleMaterial, smooth:Boolean = true)
		{
			super(x, y, z);

			this.material = material;
			this.smooth = smooth;

			_bitmapData = material.bitmapData;
			_bitmapData_width = material.width;
			_bitmapData_height = material.height;

			_matrix = new Matrix();
			_center = new Point(_bitmapData.width * _scale * .5, _bitmapData.height * _scale * .5);
		}

		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(position:Vector3D):void
		{
			// position
			screenZ = position.w;
			_position = position.clone();
		}

		public function drawBitmapdata(target:Sprite, zoom:Number, focus:Number):void
		{
			// draw to view or layer
			if (layer && target != layer)
				target = layer;

			// animated?
			if (animated)
			{
				material.nextFrame();
				_bitmapData = material.bitmapData;
				_bitmapData_width = material.width;
				_bitmapData_height = material.height;
			}

			_scale = zoom / (1 + screenZ / focus);

			// align center
			_center.x = _bitmapData_width * _scale * .5;
			_center.y = _bitmapData_height * _scale * .5;
			_matrix.a = _matrix.d = _scale;
			_matrix.tx = position.x - _center.x;
			_matrix.ty = position.y - _center.y;

			// draw
			if(target is View3D && View3D(target).scene.bitmap)
			{
				View3D(target).scene.bitmap.bitmapData.copyPixels(material.bitmapData, material.bitmapData.rect, 
				new Point(_matrix.tx+target.x, _matrix.ty+target.y), null, null, true);
			}else{
				var _graphics:Graphics = Sprite(target).graphics;
				_graphics.beginBitmapFill(_bitmapData, _matrix, false, smooth);
				_graphics.drawRect(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2);
			}
		}
	}
}