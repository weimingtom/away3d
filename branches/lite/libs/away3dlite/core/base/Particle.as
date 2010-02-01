package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.materials.ParticleMaterial;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
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
		private var _material_width:Number;
		private var _material_height:Number;

		private var _scale:Number = 1;
		private var _point:Point = new Point();
		private var _point0:Point = new Point();
		private var _rect:Rectangle = new Rectangle();

		public var material:ParticleMaterial;

		public function Particle(x:Number, y:Number, z:Number, material:ParticleMaterial, smooth:Boolean = true)
		{
			super(x, y, z);

			this.material = material;
			this.smooth = smooth;

			_bitmapData = material.bitmapData;
			_material_width = material.width;
			_material_height = material.height;
			_rect = material.rect;

			_matrix = new Matrix();
			_center = new Point(_material_width * _scale * .5, _material_height * _scale * .5);
		}

		public function get position():Vector3D
		{
			return _position;
		}

		public function set position(value:Vector3D):void
		{
			// position
			screenZ = value.w;
			_position = value.clone();
		}

		public function drawBitmapdata(x:Number, y:Number, bitmapData:BitmapData, zoom:Number, focus:Number):void
		{
			// animated?
			if (animated)
				material.nextFrame();

			_scale = zoom / (1 + screenZ / focus);

			// align center, TODO : scale rect
			//_center.x = _material_width * _scale * .5;
			//_center.y = _material_height * _scale * .5;
			
			_point.x = position.x - _center.x + x;
			_point.y = position.y - _center.y + y;

			// draw
			bitmapData.copyPixels(_bitmapData, _rect, _point, null, null, true);
		}

		public function drawGraphics(x:Number, y:Number, graphics:Graphics, zoom:Number, focus:Number):void
		{
			// draw to view or layer
			if (layer)
				graphics = layer.graphics;

			// animated?
			if (animated)
			{
				material.nextFrame();
				_bitmapData.copyPixels(material.bitmapData, material.rect, _point0, null, null, true);
			}

			_scale = zoom / (1 + screenZ / focus);

			// align center
			_center.x = _material_width * _scale * .5;
			_center.y = _material_height * _scale * .5;
			
			_matrix.a = _matrix.d = _scale;
			_matrix.tx = position.x - _material_width * _scale * .5;
			_matrix.ty = position.y - _material_height * _scale * .5;

			// draw
			graphics.beginBitmapFill(_bitmapData, _matrix, false, smooth);
			graphics.drawRect(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2);
		}
	}
}