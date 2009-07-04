package away3d.core.base
{
	import away3d.materials.WireColorMaterial;
	
	public class Graphics3D
	{
		private var _geometry:Geometry;
		private var _currentFace:Face;
		private var _currentMaterial:WireColorMaterial;
		private var _zOffset:Number = 0;
		
		public function set geometry(value:Geometry):void
		{
			_geometry = value;
		}
		
		public function lineStyle(thickness:Number = -1, color:int = -1, alpha:Number = -1):void
		{
			//trace("Graphics3D.as - lineStyle(" + thickness + ", " + color + ", " + alpha + ");");
			
			// Outlines are ignored for now...
		}
		
		public function beginFill(color:int = -1, alpha:Number = -1):void
		{
			//trace("Graphics3D.as - beginFill(" + color + ", " + alpha + ");");
			
			_currentMaterial = new WireColorMaterial();
			_currentMaterial.wirealpha = 0;
			
			if(color != -1)
				_currentMaterial.color = color;
				
			if(alpha != -1)
				_currentMaterial.alpha = alpha;
		}
		
		public function endFill():void
		{
			//trace("Graphics3D.as - endFill().");
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			//trace("Graphics3D.as - M(" + x + ", " + y + ");");
			
			_currentFace.moveTo(new Vertex(x, -y, _zOffset));
		}
		
		public function lineTo(x:Number, y:Number):void
		{
			//trace("Graphics3D.as - L(" + x + ", " + y + ");");
			
			_currentFace.lineTo(new Vertex(x, -y, _zOffset));
		}
		
		public function curveTo(cx:Number, cy:Number, ax:Number, ay:Number):void
		{
			//trace("Graphics3D.as - C(" + cx + ", " + cy + ", " + ax + ", " + ay + ");");
			
			_currentFace.curveTo(new Vertex(cx, -cy, _zOffset), new Vertex(ax, -ay, _zOffset));
		}
		
		public function clear():void
		{
			//trace("Graphics3D.as - clear().");
			
			for each(var face:Face in _geometry.faces)
				_geometry.removeFace(face);
		}
		
		public function startNewShape():void
		{
			//trace("Graphics3D.as - startNewShape().");
			
			_currentFace = new Face();
			_currentFace.material = _currentMaterial;
			_geometry.addFace(_currentFace);
		}
	}
}