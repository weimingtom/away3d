package away3d.core.render
{
	import away3d.arcane;
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.draw.*;
	import away3d.core.filter.*;
    
    use namespace arcane;
    
   /** 
    * BSP renderer for a view.
    * Should not be used directly, it's used automatically in the BSPTree class
    */
    public class BSPRenderer implements IRenderer, IPrimitiveConsumer
    {
        private var _primitives:Array = new Array();
        private var _primitive:DrawPrimitive
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _screenClipping:Clipping;
        private var _blockers:Array;
        
		/**
		 * Creates a new <code>BSPRenderer</code> object.
		 *
		 */
        public function BSPRenderer()
        {
        }
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):Boolean
        {
        	if (!_screenClipping.checkPrimitive(pri))
        		return false;
        	
           /*  for each (var _blocker:Blocker in _blockers) {
                if (_blocker.screenZ > pri.minZ)
                    continue;
                if (_blocker.block(pri))
                    return false;
            } */
            
            _primitives.push(pri);
            
            return true;
        }
		
		/**
		 * A list of primitives that have been clipped and blocked.
		 * 
		 * @return	An array containing the primitives to be rendered.
		 */
        public function list():Array
        {
            return _primitives;
        }
        
        public function clear(view:View3D):void
        {
        	_primitives.length = 0;
        	_scene = view.scene;
        	_camera = view.camera;
        	_screenClipping = view.screenClipping;
        	_blockers = view.blockerarray.list();
        }
        
        public function render(view:View3D):void
        {
    		// render all primitives
            for each (_primitive in _primitives)
                _primitive.render();
        }
        
		/**
		 * @inheritDoc
		 */
        public function toString():String
        {
            return "BSPRenderer";
        }
        
        public function clone():IPrimitiveConsumer
        {
        	return new BSPRenderer();
        }
    }
}
