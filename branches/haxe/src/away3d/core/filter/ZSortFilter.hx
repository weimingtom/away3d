package away3d.core.filter;

	import away3d.cameras.*;
    import away3d.containers.*;
    import away3d.core.clip.*;
    import away3d.core.render.*;

    /**
    * Sorts drawing primitives by z coordinate.
    */
    class ZSortFilter implements IPrimitiveFilter {
        
		/**
		 * @inheritDoc
		 */
        
        
		/**
		 * @inheritDoc
		 */
        public function filter(primitives:Array<Dynamic>, scene:Scene3D, camera:Camera3D, clip:Clipping):Array<Dynamic>
        {
            primitives.sortOn("screenZ", Array.DESCENDING | Array.NUMERIC);
            return primitives;
        }
		
		/**
		 * Used to trace the values of a filter.
		 * 
		 * @return A string representation of the filter object.
		 */
        public function toString():String
        {
            return "ZSort";
        }
    }
