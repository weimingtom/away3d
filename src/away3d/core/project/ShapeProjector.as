package away3d.core.project
{
	import away3d.containers.View3D;
	import away3d.core.base.Mesh;
	import away3d.core.base.Shape3D;
	import away3d.core.base.Vertex;
	import away3d.core.draw.DrawShape;
	import away3d.core.draw.IPrimitiveConsumer;
	import away3d.core.draw.IPrimitiveProvider;
	import away3d.core.draw.ScreenVertex;
	import away3d.core.math.Matrix3D;
	import away3d.core.utils.Debug;
	import away3d.materials.IShapeMaterial;
	
	/* Li */
	public class ShapeProjector extends AbstractProjector implements IPrimitiveProvider
	{
		private var _mesh:Mesh;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _shapeMaterial:IShapeMaterial;
		private var _drawShape:DrawShape;
		private var _command:uint;
		private var _shape:Shape3D;
		
		//Why dont other projectors have a constructor?
		//Or, how do projectors know their source, that is, their _mesh?
		public function ShapeProjector(mesh:Mesh):void
		{
			this.source = _mesh;
		}
		
		public override function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):void
		{
			super.primitives(view, viewTransform, consumer);
			
			_mesh = source as Mesh;
			
			if(!_mesh)
				Debug.error("ShapeProjector must process a Mesh object");
			
			_shapeMaterial = _mesh.material as IShapeMaterial;
			
			if(!_shapeMaterial && _mesh.material)
				Debug.error("ShapeProjector mesh material must be an IShapeMaterial");
			
			var i:uint;
			for each(_shape in _mesh.shapes)
			{
				if(_drawShape == null)
	            	_drawShape = new DrawShape();
	            else
	            	_drawShape.clear();
				
				_drawShape.source = _mesh;
				
				for(i = 0; i<_shape.drawingCommands.length; i++)
				{
					_command = _shape.drawingCommands[i];
					
					_vertex = _mesh.vertices[i];
					
					_screenVertex = new ScreenVertex();
					view.camera.project(viewTransform, _vertex, _screenVertex);
					
					switch(_command)
					{
						case 0:
							_drawShape.addDrawingCommand(0);
							_drawShape.addScreenVertex(_screenVertex);
							break;
						case 1:
							_drawShape.addDrawingCommand(1);
							_drawShape.addScreenVertex(_screenVertex);
							break;
						case 2:
							_drawShape.addDrawingCommand(2);
							_drawShape.addScreenVertex(_screenVertex);
							_drawShape.addScreenVertex(_screenVertex);
							break;
					}
				}
				
				if(_drawShape.maxZ < 0)
					continue;
					
				_drawShape.material = _shape.material;
				
				if(_drawShape.material != null && !_drawShape.material.visible)
                    _drawShape.material = null;
                    
               	if(_mesh.outline == null && _drawShape.material == null)
                	continue;
                	
                consumer.primitive(_drawShape);
			}
		}
		
		public function clone():IPrimitiveProvider
		{
			return new ShapeProjector(_mesh);
		}
	}
}