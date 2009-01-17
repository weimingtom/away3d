package away3d.primitives
{
	import away3d.core.base.DrawingCommand;
	import away3d.core.base.Mesh;
	import away3d.core.base.Shape3D;
	import away3d.core.project.ShapeProjector;
	import away3d.materials.ColorMaterial;
	import away3d.materials.IShapeMaterial;
	
	public class Sprite3D extends Mesh
	{
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Private  variables.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		private var _extrudeMaterial:IShapeMaterial;
		private var _cullingTolerance:Number = 0;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Constructor.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function Sprite3D(init:Object = null)
		{
			if(init == null)
				init = new Object();
				
			init.projector = new ShapeProjector(this);
			
			super(init);
			
			//this.bothsides = true;
			
			extrudeMaterial = IShapeMaterial(ini.getMaterial("extrudeMaterial")); 
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Setters & getters.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function get cullingTolerance():Number
		{
			return _cullingTolerance;
		}
		public function set cullingTolerance(value:Number):void
		{
			_cullingTolerance = Math.abs(value);
			
			for each(var shp:Shape3D in shapes)
			{
				shp.cullingTolerance = _cullingTolerance;
			}
		}
		
		public function set extrudeMaterial(value:IShapeMaterial):void
		{
			_extrudeMaterial = value;
		}
		public function get extrudeMaterial():IShapeMaterial
		{
			return _extrudeMaterial;
		}
		
		public function centerShapes():void
		{
			for each(var shp:Shape3D in this.shapes)
			{
				shp.centerVertices();
			}
		}
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//Public methods.
		////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function extrude(value:Number):void
		{	
			var i:uint;
			var j:uint;
			var k:uint;
			var aX:Number = 0;
			var aY:Number = 0;
			var bX:Number = 0;
			var bY:Number = 0;
			var currentVertex:uint = 0;
			var memX:Number = 0;
			var memY:Number = 0;
			var lastX:Number = 0;
			var lastY:Number = 0;
			var addQueue:Array = [];
			var shape:Shape3D;
			var instruction:String;
			var tempFrontArr:Array;
			var tempBackArr:Array;
			for(i = 0; i<shapes.length; i++)
			{
				shape = shapes[i];
				
				tempFrontArr = [];
				tempBackArr = [];
				
				for(j = 0; j<shape.vertices.length; j++)
					tempFrontArr.push(shape.vertices[j]);
				
				currentVertex = 0;
				for(j = 0; j<shape.drawingCommands.length; j++)
				{
					instruction = shape.drawingCommands[j].type;
					if(instruction == DrawingCommand.MOVE)
					{
						memX = shape.vertices[currentVertex].x;
						memY = shape.vertices[currentVertex].y;
						currentVertex++;
					}
					else
					{
						var extShp:Shape3D = new Shape3D();
						extShp.layerOffset = layerOffset;
						
						if(_extrudeMaterial == null)
							extShp.material = new ColorMaterial(0x000000);
						else
							extShp.material = _extrudeMaterial; 
						
						extShp.graphicsMoveTo(memX, memY, 0);
						tempFrontArr.push(extShp.lastCreatedVertex);
						extShp.graphicsLineTo(memX, memY, 0);
						tempBackArr.push(extShp.lastCreatedVertex);
						
						aX = shape.vertices[currentVertex].x;
						aY = shape.vertices[currentVertex].y;
						lastX = aX;
						lastY = aY;
						currentVertex++;
						
						switch(instruction)
						{	
							case DrawingCommand.LINE:
								extShp.graphicsLineTo(aX, aY, 0);
								tempBackArr.push(extShp.lastCreatedVertex);
								break;
							case DrawingCommand.CURVE:
								bX = shape.vertices[currentVertex].x;
								bY = shape.vertices[currentVertex].y;
								lastX = bX;
								lastY = bY;
								currentVertex++;
								extShp.graphicsCurveTo(aX, aY, 0, bX, bY, 0);
								tempBackArr.push(extShp.previousCreatedVertex);
								tempBackArr.push(extShp.lastCreatedVertex);
								break;
						}
						
						extShp.graphicsLineTo(lastX, lastY, 0);
						tempFrontArr.push(extShp.lastCreatedVertex);
						
						switch(instruction)
						{	
							case DrawingCommand.LINE:
								extShp.graphicsLineTo(aX, aY, 0);
								tempFrontArr.push(extShp.lastCreatedVertex);
								break;
							case DrawingCommand.CURVE:
								extShp.graphicsCurveTo(aX, aY, 0, memX, memY, 0);
								tempFrontArr.push(extShp.previousCreatedVertex);
								tempFrontArr.push(extShp.lastCreatedVertex);
								break;
						}
						
						memX = lastX;
						memY = lastY;
						
						extShp.calculateOrientationYZ();
						
						addQueue.push(extShp);
					}
				}
				
				shape.extrusionFrontVertices = tempFrontArr;
				shape.extrusionBackVertices = tempBackArr;
				shape.extrusionDepth = value;
				
				var backShape:Shape3D = new Shape3D();
				backShape.material = shape.material;
				for each(var command:DrawingCommand in shape.drawingCommands)
				{
					switch(command.type)
					{
						case DrawingCommand.MOVE:
							backShape.graphicsMoveTo(command.p2.x, command.p2.y, command.p2.z - value);
							break;
						case DrawingCommand.LINE:
							backShape.graphicsLineTo(command.p2.x, command.p2.y, command.p2.z - value);
							break;
						case DrawingCommand.CURVE:
							backShape.graphicsCurveTo(command.p1.x, command.p1.y, command.p1.z - value, command.p2.x, command.p2.y, command.p2.z - value);
							break;
					}
				}
				
				backShape.contourOrientation = -shape.contourOrientation;
				
				addQueue.push(backShape);
			}
			
			for(i = 0; i<addQueue.length; i++)
				addChild(addQueue[i]);
		}
		
		public function addChild(shp:Shape3D):void
		{
			shp.cullingTolerance = _cullingTolerance;
			
			if(shp.contourOrientation == 0)
				shp.calculateOrientationXY();
			
			addShape(shp);
		}
		
		public function removeChild(shp:Shape3D):void
		{
			removeShape(shp);
		}
	}
}