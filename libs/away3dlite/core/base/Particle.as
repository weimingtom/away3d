package away3dlite.core.base
{
	import away3dlite.arcane;
	import away3dlite.containers.Particles;
	import away3dlite.materials.ParticleMaterial;
	
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.filters.BitmapFilter;
	import flash.geom.ColorTransform;
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
		public var visible:Boolean = true;
		public var animate:Boolean = false;
		public var interactive:Boolean = false;
		public var smooth:Boolean = true;
		
		public var isHit:Boolean;
		
		public var screenZ:Number;
		
		// link list
		public var next:Particle;
		public var prev:Particle;
		
		public var parent:Particles;
		public var layer:Sprite;
		
		// effect
		public var colorTransform:ColorTransform;
		public var blendMode:String;
		public var filters:Array;

		// projected position
		private var _position:Vector3D;

		private var _matrix:Matrix;
		private var _center:Point;

		private var _bitmapData:BitmapData;
		private var _material_bitmapData:BitmapData;
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

			_material_bitmapData = material.bitmapData;
			_material_width = material.width;
			_material_height = material.height;
			_rect = material.rect;
			
			_bitmapData = new BitmapData(_material_width, _material_height, true, 0x00000000);
			_bitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);

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
			if(!visible)
				return;
			
			_scale = zoom / (1 + screenZ / focus);

			// align center, TODO : scale rect
			_center.x = _material_width * _scale * .5;
			_center.y = _material_height * _scale * .5;
			
			_point.x = position.x - _center.x + x;
			_point.y = position.y - _center.y + y;

			// effect
			if(colorTransform || blendMode || filters)
			{
				if (animate)
					_bitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);
				
				_matrix.a = _matrix.d = _scale;
				_matrix.tx = _point.x;
				_matrix.ty = _point.y;
				
				if(filters && filters.length>0)
					for each(var filter:BitmapFilter in filters)
						_bitmapData.applyFilter(_bitmapData, _bitmapData.rect, _point0, filter);
								
				if(colorTransform || blendMode)
					bitmapData.draw(_bitmapData, _matrix, colorTransform, blendMode);
			}else{
				bitmapData.copyPixels(_material_bitmapData, _rect, _point, null, null, true);
			}
		}
		
		public function drawGraphics(x:Number, y:Number, graphics:Graphics, zoom:Number, focus:Number):void
		{
			if(!visible)
				return;
				
			// draw to view or layer
			if (layer)
				graphics = layer.graphics;

			// animate?
			if (animate)
			{
				_bitmapData.fillRect(_bitmapData.rect, 0x00000000);
				_bitmapData.copyPixels(_material_bitmapData, _rect, _point0, null, null, true);
			}

			_scale = zoom / (1 + screenZ / focus);

			// align center
			_center.x = _material_width * _scale * .5;
			_center.y = _material_height * _scale * .5;
			
			_matrix.a = _matrix.d = _scale;
			_matrix.tx = position.x - _center.x;
			_matrix.ty = position.y - _center.y;

			// draw
			graphics.beginBitmapFill(_bitmapData, _matrix, false, smooth);
			graphics.drawRect(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2);
			
			// interactive
			if(interactive)
				isHit = new Rectangle(_matrix.tx, _matrix.ty, _center.x * 2, _center.y * 2).contains(parent.mouseX, parent.mouseY);
		}
	}
}