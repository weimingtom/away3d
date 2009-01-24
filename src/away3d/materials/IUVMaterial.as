package away3d.materials
{
    
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
	
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
		
		function getFaceMaterialVO(face:Face, source:Object3D = null, view:View3D = null):FaceMaterialVO;
		
		/**
        * Clears face value objects when material requires updating
        * 
        * @param	source		[optional]	The parent 3d object of the face.
        * @param	view		[optional]	The view rendering the draw triangle.
        * 
        * @see away3d.core.utils.FaceMaterialVO
        */
        function clearFaceDictionary(source:Object3D = null, view:View3D = null):void
		
		/**
		 * Default method for adding a materialResized event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnMaterialResize(listener:Function):void;
		
		/**
		 * Default method for removing a materialResized event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnMaterialResize(listener:Function):void;
    }
}
