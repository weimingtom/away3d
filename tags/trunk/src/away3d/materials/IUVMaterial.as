package away3d.materials
{
    
    import flash.display.BitmapData;
	
    /**
    * Interface for materials that use uv texture coordinates
    */
    public interface IUVMaterial extends IMaterial
    {
        /**
        * Returns the width of the bitmapData being used as the material texture.
        */
        function get width():Number;
        
        /**
        * Returns the height of the bitmapData being used as the material texture.
        */
        function get height():Number;
        
        /**
        * Returns the bitmapData object being used as the material texture.
        */
        function get bitmap():BitmapData;
        
        /**
        * Returns the argb value of the bitmapData pixel at the given u v coordinate.
        * 
        * @param	u	The u (horizontal) texture coordinate.
        * @param	v	The v (verical) texture coordinate.
        * @return		The argb pixel value.
        */
        function getPixel32(u:Number, v:Number):uint;
		
		/**
		 * Default method for adding a materialresize event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnResize(listener:Function):void;
		
		/**
		 * Default method for removing a materialresize event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnResize(listener:Function):void;
    }
}
