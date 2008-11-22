package away3d.core.render;

	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
    

    /** Renderer that uses quadrant tree for storing and operating drawing primitives. Quadrant tree speeds up all proximity based calculations. */
    class QuadrantRenderer implements IPrimitiveConsumer, implements IRenderer {
        public var filters(getFilters, setFilters) : Array<Dynamic>;
        
        var _qdrntfilters:Array<Dynamic>;
        var _root:PrimitiveQuadrantTreeNode;
		var _rect:RectangleClipping;
		var _center:Array<Dynamic>;
		var _result:Array<Dynamic>;
		var _except:Object3D;
		var _minX:Float;
		var _minY:Float;
		var _maxX:Float;
		var _maxY:Float;
		var _child:DrawPrimitive;
		var _children:Array<Dynamic>;
		var i:Int;
		var _primitives:Array<Dynamic>;
        var _view:View3D;
        var _scene:Scene3D;
        var _camera:Camera3D;
        var _clip:Clipping;
        var _blockers:Array<Dynamic>;
		var _filter:IPrimitiveQuadrantFilter;
		
		function getList(node:PrimitiveQuadrantTreeNode):Void
        {
            if (node.onlysourceFlag && _except == node.onlysource)
                return;
            if (_minX < node.xdiv)
            {
                if (node.lefttopFlag && _minY < node.ydiv)
	                getList(node.lefttop);
	            
                if (node.leftbottomFlag && _maxY > node.ydiv)
                	getList(node.leftbottom);
            }
            
            if (_maxX > node.xdiv)
            {
                if (node.righttopFlag && _minY < node.ydiv)
                	getList(node.righttop);
                
                if (node.rightbottomFlag && _maxY > node.ydiv)
                	getList(node.rightbottom);
                
            }
            
            _children = node.center;
            if (_children != null) {
                i = _children.length;
                while (i--)
                {
                	_child = _children[i];
                    if ((_except == null || _child.source != _except) && _child.maxX > _minX && _child.minX < _maxX && _child.maxY > _minY && _child.minY < _maxY)
                        _result.push(_child);
                }
            }           
        }
        
        function getParent(?node:PrimitiveQuadrantTreeNode = null):Void
        {
        	node = node.parent;
        	
            if (node == null || (node.onlysourceFlag && _except == node.onlysource))
                return;

            _children = node.center;
            if (_children != null) {
                i = _children.length;
                while (i--)
                {
                	_child = _children[i];
                    if ((_except == null || _child.source != _except) && _child.maxX > _minX && _child.minX < _maxX && _child.maxY > _minY && _child.minY < _maxY)
                        _result.push(_child);
                }
            }
            getParent(node);
        }
		
		/**
		 * Defines the array of filters to be used on the drawing primitives.
		 */
		public function getFilters():Array<Dynamic>{
			return _qdrntfilters;
		}
		
		public function setFilters(val:Array<Dynamic>):Array<Dynamic>{
			_qdrntfilters = val;
			return val;
		}
		
		/**
		 * Creates a new <code>QuadrantRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function new(filters:Array<Dynamic>)
        {
            _qdrntfilters = filters;
        }
		
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):Bool
        {
            if (!_clip.check(pri))
            	return false;
            
            _root.push(pri);
            
            return true;
        }
        
        /**
        * removes a drawing primitive from the quadrant tree.
        * 
        * @param	pri	The drawing primitive to remove.
        */
        public function remove(pri:DrawPrimitive):Void
        {
        	_center = pri.quadrant.center;
        	_center.splice(_center.indexOf(pri), 1);
        }
		
		/**
		 * Returns an array containing all primiives overlapping the specifed primitive's quadrant.
		 * 
		 * @param	pri					The drawing primitive to check.
		 * @param	ex		[optional]	Excludes primitives that are children of the 3d object.
		 * @return						An array of drawing primitives.
		 */
        public function get(pri:DrawPrimitive, ex:Object3D = null):Array
        {
        	_result = [];
                    
			_minX = pri.minX;
			_minY = pri.minY;
			_maxX = pri.maxX;
			_maxY = pri.maxY;
			_except = ex;
			
            getList(pri.quadrant);
            getParent(pri.quadrant);
            return _result;
        }
        
		/**
		 * A list of primitives that have been clipped.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array
        {
            _result = [];
                    
			_minX = -1000000;
			_minY = -1000000;
			_maxX = 1000000;
			_maxY = 1000000;
			_except = null;
			
            getList(_root);
            
            return _result;
        