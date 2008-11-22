package away3d.core.project;

	import away3d.blockers.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.block.*;
	import away3d.core.draw.*;
	import away3d.core.math.*;
	import away3d.core.utils.*;
	import away3d.materials.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	class ConvexBlockProjector extends AbstractProjector, implements IBlockerProvider, implements IPrimitiveProvider {
		
		var _convexBlock:ConvexBlock;
		var _vertices:Array<Dynamic>;
		var _displayObject:DisplayObject;
		var _segmentMaterial:ISegmentMaterial;
		var _vertex:Vertex;
		var _screenVertex:ScreenVertex;
		var _convexBlocker:ConvexBlocker;
        var _points:Array<Dynamic>;
        var _base:ScreenVertex;
        var _s:String;
        var _p:String;
        
        function cross(a:ScreenVertex, b:ScreenVertex, c:ScreenVertex):Float
        {
            return (b.x - a.x)*(c.y - a.y) - (c.x - a.x)*(b.y - a.y);
        }
        
		/**
		 * @inheritDoc
		 * 
    	 * @see	away3d.core.traverse.BlockerTraverser
    	 * @see	away3d.core.block.Blocker
		 */
        public function blockers(view:View3D, viewTransform:Matrix3D, consumer:IBlockerConsumer):Void
        {
			if (!(primitiveDictionary = viewDictionary[view]))
				primitiveDictionary = viewDictionary[view] = new Dictionary(true);
			
        	_convexBlock = cast( source, ConvexBlock);
			
			if (!_convexBlock)
				Debug.error("FaceProjector must process a Mesh object");
			
			_vertices = _convexBlock.vertices;
			
            if (!(_convexBlocker = primitiveDictionary[source]))
				_convexBlocker = primitiveDictionary[source] = new ConvexBlocker();
            
        	if (_vertices.length < 3)
                return;
			
			_points = [];
			_base = null;
			_s = "";
			_p = "";
			
            for (_vertex in _vertices)
            {
                _s += _vertex.toString() + "\n";
				
				if (!(_screenVertex = primitiveDictionary[_vertex]))
					_screenVertex = primitiveDictionary[_vertex] = new ScreenVertex();
				
                view.camera.project(viewTransform, _vertex, _screenVertex);

                if (_base == null)
                    _base = _screenVertex;
                else
                if (_base.y > _screenVertex.y)
                    _base = _screenVertex;
                else
                if (_base.y == _screenVertex.y)
                    if (_base.x > _screenVertex.x)
                        _base = _screenVertex;

                _points.push(_screenVertex);
                _p += _screenVertex.toString() + "\n";
            }

//            throw new Error(s + p);

            for each (_screenVertex in _points)
                _screenVertex.num = (_screenVertex.x - _base.x) / (_screenVertex.y - _base.y);
            
            _base.num = -Infinity;

            _points.sortOn("num", Array.NUMERIC);
            
            var result:Array<Dynamic> = [_points[0], _points[1]];
            var o:Float;

            for (i in 2..._points.length)
            {
                o = cross(result[result.length-2], result[result.length-1], _points[i]);
                while (o > 0)
                {
                    result.pop();
                    if (result.length == 2)
                        break;
                    o = cross(result[result.length-2], result[result.length-1], _points[i]);
                }
                result.push(_points[i]);
            }
            o = cross(result[result.length-2], result[result.length-1], result[0]);
            if (o > 0)
                result.pop();
			
			_convexBlocker.source = _convexBlock;
			_convexBlocker.vertices = result;
			_convexBlocker.calc();
			
            consumer.blocker(_convexBlocker);
 		}
 		
		public override function primitives(view:View3D, viewTransform:Matrix3D, consumer:IPrimitiveConsumer):Void
		{
			super.primitives(view, viewTransform, consumer);
			
			_convexBlock = cast( source, ConvexBlock);
			
			if (!_convexBlock)
				Debug.error("ConvexBlockProjector must process a ConvexBlock object");
			
        	if (_convexBlock.debug)
                consumer.primitive(_convexBlocker);
		}
		
		public function clone():IPrimitiveProvider
		{
			return new ConvexBlockProjector();
		}
	}
