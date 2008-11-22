package away3d.core.project;

	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.ISegmentMaterial;
	
	class SegmentProjector extends AbstractProjector, implements IPrimitiveProvider {
		
		var _mesh:Mesh;
		var _segmentMaterial:ISegmentMaterial;
		var _vertex:Vertex;
		var _screenVertex:ScreenVertex;
		var _segment:Segment;
		var _drawSegment:DrawSegment;
		
		public override function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void
		{
			super.primitives(view, viewTransform, consumer);
			
			_mesh = cast( source, Mesh);
			
			if (!_mesh)
				Debug.error("SegmentProjector must process a Mesh object");
			
			_segmentMaterial = cast( _mesh.material, ISegmentMaterial);
			
			if (!_segmentMaterial && _mesh.material)
				Debug.error("SegmentProjector mesh material must be an ISegmentMaterial object");
			
			for (_vertex in _mesh.vertices) {
				if (!(_screenVertex = primitiveDictionary[_vertex]))
					_screenVertex = primitiveDictionary[_vertex] = new ScreenVertex();
				
				view.camera.project(viewTransform, _vertex, _screenVertex);
			}
			
            for (_segment in _mesh.segments)
            {
            	if (!(_drawSegment = primitiveDictionary[_segment])) {
					_drawSegment = primitiveDictionary[_segment] = new DrawSegment();
	            	_drawSegment.view = view;
	            	_drawSegment.source = _mesh;
	            	_drawSegment.create = createDrawSegment;
            	}
            	
            	_drawSegment.v0 = primitiveDictionary[_segment.v0];
				_drawSegment.v1 = primitiveDictionary[_segment.v1];
    
                if (!_drawSegment.v0.visible)
                    continue;
				
                if (!_drawSegment.v1.visible)
                    continue;
				
                _drawSegment.calc();
				
                _drawSegment.material = _segment.material || _segmentMaterial;
				
                if (_drawSegment.material == null)
                    continue;
				
                if (!_drawSegment.material.visible)
                    continue;
                
                consumer.primitive(_drawSegment);
            }
		}
				
		public function clone():IPrimitiveProvider
		{
			return new SegmentProjector();
		}
	}
