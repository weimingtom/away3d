package away3d.core.draw
{
	import away3d.cameras.*;
	import away3d.containers.*;
	import away3d.core.block.*;
	import away3d.core.clip.*;
	import away3d.core.filter.*;
	import away3d.core.render.*;

    /**
    * Array for storing drawing primitives.
    */
    public class PrimitiveArray implements IPrimitiveConsumer
    {
    	private var _primitive:DrawPrimitive;
        private var _primitives:Array = [];
        private var _view:View3D;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _clip:Clipping;
        private var _blockers:Array;
		private var _filter:IPrimitiveFilter;
		
		/**
		 * Defines the view to be used with the consumer.
		 */
		public function get view():View3D
		{
			return _view;
		}
		
		public function set view(val:View3D):void
		{
			_view = val;
			_scene = val.scene;
			_camera = val.camera;
			_clip = val.clip;
		}
		
		/**
		 * Defines the array of blocker primitives to be used on the drawing primitives.
		 */
		public function get blockers():Array
		{
			return _blockers;
		}
		
		public function set blockers(val:Array):void
		{
			_blockers = val;
		}
        
		/**
		 * @inheritDoc
		 */
        public function primitive(pri:DrawPrimitive):void
        {
            if (_clip.check(pri))
            {
                var blockercount:int = _blockers.length;
                var i:int = 0;
                while (i < blockercount)
                {          
                    var blocker:Blocker = _blockers[i];
                    if (blocker.screenZ > pri.minZ)
                        break;
                    if (blocker.block(pri))
                        return;
                    i++;
                }
                _primitives.push(pri);
            }
        }
		
		public function filter(filters:Array):void
		{
			for each (_filter in filters)
        		_primitives = _filter.filter(_primitives, _scene, _camera, _clip);
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
        
        public function clear():void
        {
        	_primitives = [];
        }
        
        public function clone():IPrimitiveConsumer
        {
        	var priarray:PrimitiveArray = new PrimitiveArray();
        	priarray.blockers = blockers;
        	return priarray;
        }
        
        public function render():void
        {
    		// render all primitives
            for each (_primitive in _primitives)
                _primitive.render();
        }
    }
}
