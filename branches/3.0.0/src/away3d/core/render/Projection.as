package away3d.core.render
{
    import away3d.core.math.*;

    /**
    * Data object for camera transform, focus and zoom properties.
    */
    public class Projection
    {
    	/**
    	 * Defines the current view transform matrix that resolves the transformation tree.
    	 */
        public var view:Matrix3D;
        
        /**
        * Defines the focus for the camera object being used by the view.
        */
        public var focus:Number;
                
        /**
        * Defines the zoom for the camera object being used by the view.
        */
        public var zoom:Number;
        
        /**
        * Defines the unique timestamp for the view render.
        */
        public var time:int;
		
		/**
		 * Creates a new <code>Projection</code> object.
		 */
        public function Projection()
        {
        }
    }
}
