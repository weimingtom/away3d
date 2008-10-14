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
		private var _vertex1:Vertex;
		private var _vertex2:Vertex;
		private var _screenVertex1:ScreenVertex;
		private var _screenVertex2:ScreenVertex;
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
			var j:uint;
			var currentVertex:uint;
			for(i = 0; i<_mesh.shapes.length; i++)
			{
				currentVertex = 0;	
				_shape = _mesh.shapes[i];
				_drawShape = new DrawShape();
				trace("Vertices: " + _shape.vertices.length);
				for(j = 0; j<_shape.drawingCommands.length; j++)
				{
					trace("Current vertex: " + currentVertex);
					_command = _shape.drawingCommands[j];
					
					_vertex1 = _shape.vertices[currentVertex];
					_screenVertex1 = new ScreenVertex();
					view.camera.project(viewTransform, _vertex1, _screenVertex1);
					currentVertex++
					
					switch(_command)
					{
						case 0:
							_drawShape.addMoveTo(_screenVertex1);
							break;
						case 1:
							_drawShape.addLineTo(_screenVertex1);
							break;
						case 2:
						
							_vertex2 = _shape.vertices[currentVertex];
							_screenVertex2 = new ScreenVertex();
							view.camera.project(viewTransform, _vertex2, _screenVertex2);
							currentVertex++;
							
							//_drawShape.addLineTo(_screenVertex1);
							//_drawShape.addLineTo(_screenVertex2);
							
							_drawShape.addCurveTo(_screenVertex1, _screenVertex2); 
							
							break;
					}
				}
				
				_drawShape.material = _shape.material;
				_drawShape.source = _mesh;
				
				if(_drawShape.maxZ < 0)
					continue;
				
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