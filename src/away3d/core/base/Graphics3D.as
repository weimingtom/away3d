package away3d.core.base
{
	import away3d.materials.WireColorMaterial;
	
	public class Graphics3D
	{
		private var _geometry:Geometry;
		private var _currentFace:Face;
		private var _currentMaterial:WireColorMaterial;
		private var _faces:Array = [];
		private var _materials:Array = [];
		private var _lastPointWasIrrelevant:Boolean = false;
		private var _zOffset:Number = 0;
		
		public function set geometry(value:Geometry):void
		{
			_geometry = value;
		}
		
		public function moveTo(x:Number, y:Number):void
		{
			//trace("Graphics3D.as - M(" + x + ", " + y + ");");
			
			if(x == 0 && y == 0)
			{	
				_lastPointWasIrrelevant = true;
				return;
			}
			else
				_lastPointWasIrrelevant = false;
			
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
		
		public function beginFill(color:int = -1, alpha:Number = -1):void
		{
			//trace("Graphics3D.as - beginFill(" + color + ", " + alpha + ");");
			
			evaluateNewFace();
			
			_currentMaterial.color = color;
			_currentMaterial.alpha = alpha;
		}
		
		public function lineStyle(thickness:Number = -1, color:int = -1, alpha:Number = -1):void
		{
			//trace("Graphics3D.as - lineStyle(" + thickness + ", " + color + ", " + alpha + ");");
			
			if(_lastPointWasIrrelevant)
				return;
			
			evaluateNewMaterial();
			
			_currentMaterial.width = thickness;
			_currentMaterial.wirecolor = color;
			_currentMaterial.wirealpha = alpha;
		}
		
		public function endFill():void
		{
			
		}
		
		public function clear():void
		{
			for each(var face:Face in _geometry.faces)
				_geometry.removeFace(face);
				
			_faces = [];
			_materials = [];
		}
		
		public function apply():void
		{
			//trace("Graphics3D.as - APPLYING FACES.");
			
			for(var i:uint; i<_faces.length; i++)
			{
				var face:Face = _faces[i];
				var material:WireColorMaterial = _materials[i];
				
				face.material = material;
				
				if(face.v0 && face.v1 && face.v2)
					_geometry.addFace(face);
			}
		}
		
		private function evaluateNewFace():void
		{
			//trace("Graphics3D.as - NEW FACE.");
			
			_currentFace = new Face();
			_faces.push(_currentFace);
		}
		
		private function evaluateNewMaterial():void
		{
			_currentMaterial = new WireColorMaterial();
			_materials.push(_currentMaterial);
		}
	}
}