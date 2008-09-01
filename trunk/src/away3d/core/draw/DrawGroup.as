package away3d.core.draw
{
	import away3d.cameras.*;
	import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.clip.*;
    import away3d.core.filter.*;
    import away3d.core.render.*;
	
	/**
	 * Group drawing primitive.
	 */
    public class DrawGroup extends DrawPrimitive implements IPrimitiveConsumer
    {
		private var _primitive:DrawPrimitive;
        private var _view:View3D;
        private var _scene:Scene3D;
        private var _camera:Camera3D;
        private var _clip:Clipping;
		private var _filter:IPrimitiveFilter;
		
    	/**
    	 * The primitives contained in the group.
    	 */
        public var primitives:Array;
        		
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
		 * @inheritDoc
		 */
        public override function clear():void
        {
        	primitives = [];
            minZ = Infinity;
            maxZ = -Infinity;
            minX =  100000;
            maxX = -100000;
            minY =  100000;
            maxY = -100000;
        }
		 
    	/**
    	 * Adds a drawing primitive to the primitive group
    	 *
		 * @param	pri		The drawing primitive to add.
		 */
        public function primitive(pri:DrawPrimitive):void
        {
            primitives.push(pri);

            if (minZ > pri.minZ)
                minZ = pri.minZ;
            if (maxZ < pri.maxZ)
                maxZ = pri.maxZ;

            if (minX > pri.minX)
                minX = pri.minX;
            if (maxX < pri.maxX)
                maxX = pri.maxX;

            if (minY > pri.minY)
                minY = pri.minY;
            if (maxY < pri.maxY)
                maxY = pri.maxY;

            screenZ = (maxZ + minZ) / 2;
        }
        
		/**
		 * @inheritDoc
		 */
        public override function render():void
        {
            primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            for each (var pri:DrawPrimitive in primitives)
                pri.render();
        }
		
		public function filter(filters:Array):void
		{
			for each (_filter in filters)
        		primitives = _filter.filter(primitives, _scene, _camera, _clip);
		}
		
		/**
		 * @inheritDoc
		 */
        public override function contains(x:Number, y:Number):Boolean
        {   
            for each (var pri:DrawPrimitive in primitives)
                if (pri.contains(x, y))
                    return true;

            return false;
        }
		
		public function list():Array
		{
			return primitives;
		}
        
        public function clone():IPrimitiveConsumer
        {
        	return new DrawGroup();
        }
    }
}
