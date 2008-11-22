package away3d.core.render;

	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
	import away3d.core.light.*;
	import away3d.core.stats.*;
	import away3d.core.traverse.*;
	import away3d.materials.*;
	
	import flash.utils.*;
    
    /** 
    * Default renderer for a view.
    * Contains the main render loop for rendering a scene to a view,
    * which resolves the projection, culls any drawing primitives that are occluded or outside the viewport,
    * and then z-sorts and renders them to screen.
    */
    class BasicRenderer implements IRenderer, implements IPrimitiveConsumer {
    	public var filters(getFilters, setFilters) : Array<Dynamic>;
    	
    	var _filters:Array<Dynamic>;
    	var _primitive:DrawPrimitive;
        var _primitives:Array<Dynamic> ;
        var _view:View3D;
        var _scene:Scene3D;
        var _camera:Camera3D;
        var _clip:Clipping;
        var _blockers:Array<Dynamic> ;
		var _filter:IPrimitiveFilter;
		var _blocker:Blocker;
		/**
		 * Defines the array of filters to be used on the drawing primitives.
		 */
		public function getFilters():Array<Dynamic>{
			return _filters.slice(0, _filters.length - 1);
		}
		
		public function setFilters(val:Array<Dynamic>):Array<Dynamic>{
			_filters = val;
			_filters.push(new ZSortFilter());
			return val;
		}
		
		/**
		 * Creates a new <code>BasicRenderer</code> object.
		 *
		 * @param	filters	[optional]	An array of filters to use on projected drawing primitives before rendering them to screen.
		 */
        public function new(filters:Array<Dynamic>)
        {
            
            _primitives = [];
            _blockers = [];
            _filters = filters;
            _filters.push(new ZSortFilter());
        }
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):Bool
        {
            if (!_clip.check(pri))
            	return false;
            
            for (_blocker in _blockers) {
                if (_blocker.screenZ > pri.minZ)
                    continue;
                if (_blocker.block(pri))
                    return false;
            }
            
            _primitives.push(pri);
            
            return true;
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array<Dynamic>
        {
            return _primitives;
        }
        
        public function clear(view:View3D):Void
        {
        	_primitives = [];
        	_scene = view.scene;
        	_camera = view.camera;
        	_clip = view.clip;
        	_blockers = view.blockerarray.list();
        }
        
        public function render(view:View3D):Void
        {
        	
        	//filter primitives array
			for each (_filter in _filters)
        		_primitives = _filter.filter(_primitives, _scene, _camera, _clip);
        	
    		// render all primitives
            for each (_primitive in _primitives)
                _primitive.render();
        }
        
		/**
		 * @inheritDoc
		 */
        public function toString():String
        {
            return "Basic [" + _filters.join("+") + "]";
        }
        
        public function clone():IPrimitiveConsumer
        {
        	var renderer:BasicRenderer = new BasicRenderer();
        	renderer.filters = filters;
        	return renderer;
        }
    }
