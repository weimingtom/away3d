package away3dlite.materials
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	/**
	 * Base particle dof material class.
	 */
	public class ParticleDofMaterial
	{
		private var _currentFrame		: int = 0;
		private var _totalFrames		: int = 0;
		private var _dofBlurMultiplier	: Number;
		private var _dofBlurQuality		: int;
		public var framesDof			: Vector.<Vector.<BitmapData>>;
		public var quality				: int;
		public var dofLevel				: int;	// levels of dof = 0 means sharp 1 = 1 * _dofBlurMultiplier, etc.
		public var dofNearScreenZ		: int;  // dof start range
		public var dofFarScreenZ		: int;  // dof end range
		public var dofRangePerLevel		: int;	// calculate lenght of each dof level based on near - far / doflevel
		/**
		 * Creates a new <code>ParticleDofMaterial</code> object.
		 * Depth of field based on X levels
		 */
		public function ParticleDofMaterial(dofLevel:int = 6, dofBlurMultiplier:Number = 2 , dofBlurQuality:int = 1, dofNearScreenZ:int = 1000, dofFarScreenZ:int = 4000)
		{
			this.dofLevel = dofLevel;
			this.dofFarScreenZ = dofFarScreenZ;
			this.dofNearScreenZ = dofNearScreenZ;
			this.dofRangePerLevel = int(Math.abs((this.dofFarScreenZ - this.dofNearScreenZ)/this.dofLevel));
			this._dofBlurMultiplier  = dofBlurMultiplier;
			this._dofBlurQuality = dofBlurQuality;
			framesDof = new Vector.<Vector.<BitmapData>>;
		}
		
		// TODO add MovieClip
		public function addFrame(bitmapData:BitmapData, smooth:Boolean = true):void
		{
			var frameDof:Vector.<BitmapData> = new Vector.<BitmapData>;
			_totalFrames ++;
			
			var _bitmapData:BitmapData;
			
			// making dof levels			
			for (var i:int = 0; i < dofLevel; i++)
			{
				var s:Number = i*_dofBlurMultiplier;
				_bitmapData = new BitmapData(bitmapData.width+s,bitmapData.height+s, true, 0x00);
				
				var mat:Matrix = new Matrix();
				mat.tx = s/2;
				mat.ty = s/2;
				_bitmapData.draw(bitmapData, mat, null, null, new Rectangle(0, 0, _bitmapData.width, _bitmapData.height), smooth);
				_bitmapData.applyFilter(_bitmapData,_bitmapData.rect,new Point(0,0), new BlurFilter(s,s,_dofBlurQuality));

				// for testing
//				_bitmapData.colorTransform(_bitmapData.rect,new ColorTransform(1,1,1,1-((i+1)*0.2)));

				frameDof.push(_bitmapData);
			}
			framesDof.fixed = false;
			framesDof.push(frameDof);
			framesDof.fixed = true;
		}
	}
}