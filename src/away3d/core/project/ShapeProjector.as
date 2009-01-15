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
	
	public class ShapeProjector extends AbstractProjector implements IPrimitiveProvider
	{
		private var _mesh:Mesh;
		private var _shape:Shape3D;
		private var _drawShape:DrawShape;
		private var _vertex:Vertex;
		private var _screenVertex:ScreenVertex;
		private var _screenVertices:Array;
		private var _shapeMaterial:IShapeMaterial;
		
		public function ShapeProjector(mesh:Mesh):void
		{
			this.source = _mesh;
			
			_vertex = new Vertex();
			_screenVertex = new ScreenVertex();
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
			mainLoop: for(i = 0; i<_mesh.shapes.length; i++)
			{
				_shape = _mesh.shapes[i];
				
				if(!(_drawShape = primitiveDictionary[_shape]))
					_drawShape = primitiveDictionary[_shape] = new DrawShape();
            	else
            		_drawShape.screenVertices = [];
				
				for(j = 0; j < _shape.vertices.length; j++)
				{
					_vertex = _shape.vertices[j];
					
					if(!(_screenVertex = primitiveDictionary[_vertex]))
						_screenVertex = primitiveDictionary[_vertex] = new ScreenVertex(); 
					
					view.camera.project(viewTransform, _vertex, _screenVertex);
					_drawShape.screenVertices.push(_screenVertex);
					
					//check every ScreenVertex is visible
					//Commented because it causes all glyfs in a TextField3D to dissapear when going to the right... weird.
					//What determines when a ScreenVertex is visible?
					/* if(!_screenVertex.visible)
						break mainLoop; */
				}
				
				if(_shape.material != null)
					_drawShape.material = _shape.material;
				else
					_drawShape.material = IShapeMaterial(_mesh.material);
				
				_drawShape.drawingCommands = _shape.drawingCommands;
				_drawShape.source = _mesh;
				_drawShape.view = view;
	            _drawShape.shape = _shape;
				
				if(_shape.layerOffset != 0)
					_drawShape.layerOffset = _shape.layerOffset;
				else
					_drawShape.layerOffset = _mesh.layerOffset;
				
				_drawShape.calc();
				
				if(!_mesh.bothsides)
				{
					_drawShape.calculateContourOrientation();
					if(!_drawShape.contourOrientation)
						continue;
				}
				
				if(_drawShape.maxZ < 0)
					continue;
				
				//do not draw material if visible is false
				if(_drawShape.material != null && !_drawShape.material.visible)
                    _drawShape.material = null;
                    
                if(_mesh.pushback)
                    _drawShape.screenZ = _drawShape.maxZ;
				
                if(_mesh.pushfront)
                    _drawShape.screenZ = _drawShape.minZ;
                	
                consumer.primitive(_drawShape);
			}
		}
		
		public function clone():IPrimitiveProvider
		{
			return new ShapeProjector(_mesh);
		}
	}
}