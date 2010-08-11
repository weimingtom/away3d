package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.containers.Particles;
	import away3dlite.core.IDestroyable;
	import away3dlite.materials.ParticleMaterial;

	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;

	use namespace arcane;

	/**
	 * Particle
	 * @author katopz
	 */
	public class Particle implements IRenderable, IDestroyable
	{
		/** @private */
		protected var _isDestroyed:Boolean;

		protected var _position:Vector3D;

		public function get position():Vector3D
		{
			return _position;
		}

		public function get x():Number
		{
			return _position.x;
		}

		public function set x(value:Number):void
		{
			_position.x = value;
		}

		public function get y():Number
		{
			return _position.y;
		}

		public function set y(value:Number):void
		{
			_position.y = value;
		}

		public function get z():Number
		{
			return _position.z;
		}

		public function set z(value:Number):void
		{
			_position.z = value;
		}

		public var id:String;
		public var visible:Boolean = true;
		protected var _isClip:Boolean = false;

		public function get isClip():Boolean
		{
			return _isClip;
		}

		public var animate:Boolean = false;
		public var interactive:Boolean = false;
		public var smooth:Boolean = true;

		public var isHit:Boolean;

		private var _screenZ:Number;

		public function get screenZ():Number
		{
			return _screenZ;
		}

		// link list
		public var next:Particle;
		public var prev:Particle;

		public var parent:Particles;
		public var graphics:Graphics;
		public var bitmapData:BitmapData;

		// effect
		public var colorTransform:ColorTransform;
		public var blendMode:String;
		public var filters:Array;

		// position
		private var _tranformedPosition:Vector3D;

		public function get transformPosition():Vector3D
		{
			return _tranformedPosition;
		}

		private var _matrix:Matrix;
		private var _center:Point;

		private var _tempBitmapData:BitmapData;
		private var _material_bitmapData:BitmapData;
		private var _material_width:Number;
		private var _material_height:Number;

		private var _scale:Number = 1;
		private var _point:Point = new Point();
		private var _point0:Point = new Point();
		private var _rect:Rectangle = new Rectangle();

		public var material:ParticleMaterial;

		public function Particle(material:ParticleMaterial, x:Number = 0, y:Number = 0, z:Number = 0, smooth:Boolean = true)
		{
			_position = new Vector3D(x, y, z);

			this.material = material;
			this.smooth = smooth;

			updateMaterial();
		}

		private function updateMaterial():void
		{
			_material_bitmapData = material.bitmapData;
			_material_width = material.width;
			_material_height = material.height;
			_rect = material.rect;

			_tempBitmapData = new BitmapData(_material_width, _material_height, true, 0x00000000);
			_tempBitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);

			_matrix = new Matrix();
			_center = new Point(_material_width * _scale * .5, _material_height * _scale * .5);

			material.isDirty = false;

			if (parent)
				parent.isDirty = true;
		}

		public function update(viewMatrix3D:Matrix3D, transformMatrix3D:Matrix3D = null):void
		{
			// dirty
			if (material.isDirty)
				updateMaterial();

			// bypass
			var Utils3D_projectVector:Function = Utils3D.projectVector;

			// update position
			_tranformedPosition = Utils3D_projectVector(viewMatrix3D, Utils3D_projectVector(transformMatrix3D, _position));
			_screenZ = _tranformedPosition.w;

			// clip?
			_isClip = _screenZ < 0;

			// animate?
			if (animate)
				material.updateAnimation();
		}

		protected function drawBitmapdata(x:Number, y:Number, zoom:Number, focus:Number):void
		{
			_scale = zoom / (1 + _tranformedPosition.w / focus);

			// align center, TODO : scale rect
			_center.x = _material_width * _scale * .5;
			_center.y = _material_height * _scale * .5;

			_point.x = _tranformedPosition.x - _center.x + x;
			_point.y = _tranformedPosition.y - _center.y + y;

			// effect
			if (colorTransform || blendMode || filters)
			{
				if (animate)
					_tempBitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);

				_matrix.a = _matrix.d = _scale;
				_matrix.tx = _point.x;
				_matrix.ty = _point.y;

				if (filters && filters.length > 0)
					for each (var filter:BitmapFilter in filters)
						_tempBitmapData.applyFilter(_tempBitmapData, _tempBitmapData.rect, _point0, filter);

				if (colorTransform || blendMode)
					bitmapData.draw(_tempBitmapData, _matrix, colorTransform, blendMode);
			}
			else
			{
				bitmapData.copyPixels(_material_bitmapData, _rect, _point, null, null, true);
			}
		}

		public function render(x:Number, y:Number, graphics:Graphics, zoom:Number, focus:Number):void
		{
			if (!visible || isClip)
				return;

			// draw to bitmap?
			if (bitmapData)
			{
				drawBitmapdata(x, y, zoom, focus);
				return;
			}

			// or draw to parent or child canvas?
			if (!this.graphics)
				this.graphics = graphics;

			// animate?
			if (animate)
			{
				_tempBitmapData.fillRect(_tempBitmapData.rect, 0x00000000);
				_tempBitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);
			}
			else if (_tempBitmapData != _material_bitmapData)
			{
				_tempBitmapData = _material_bitmapData;
			}

			_scale = zoom / (1 + _screenZ / focus);

			// align center
			_center.x = _material_width * _scale * .5;
			_center.y = _material_height * _scale * .5;

			_matrix.a = _matrix.d = _scale;
			_matrix.tx = _tranformedPosition.x - _center.x;
			_matrix.ty = _tranformedPosition.y - _center.y;

			// draw
			graphics.beginBitmapFill(_tempBitmapData, _matrix, false, smooth);
			graphics.drawRect(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2);

			// interactive
			if (interactive)
				isHit = new Rectangle(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2).contains(parent.mouseX, parent.mouseY);
		}

		public function get destroyed():Boolean
		{
			return _isDestroyed;
		}

		public function destroy():void
		{
			_isDestroyed = true;

			next = null;
			prev = null;

			parent = null;

			if (graphics)
				graphics.clear();
			graphics = null;

			if (bitmapData)
				bitmapData.dispose();
			bitmapData = null;

			colorTransform = null;
			blendMode = null;
			filters = null;
			_tranformedPosition = null;
			_matrix = null;
			_center = null;

			if (_tempBitmapData)
				_tempBitmapData.dispose();
			_tempBitmapData = null;

			if (_material_bitmapData)
				_material_bitmapData.dispose();
			_material_bitmapData = null;

			_point = null;
			_point0 = null;
			_rect = null;

			if (material)
				material.destroy();
			material = null;
		}
	}
}