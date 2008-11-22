package away3d.materials;

    
    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.utils.*;
    
    import flash.display.*;
	
    /**
    * Interface for materials that use uv texture coordinates
    */
    interface IUVMaterial implements IMaterial{
        /**
        * Returns the width of the bitmapData being used as the material texture.
        */
        function width():Float;
        
        /**
        * Returns the height of the bitmapData being used as the material texture.
        */
        function height():Float;
        
        /**
        * Returns the bitmapData object being used as the material texture.
        */
        function bitmap():BitmapData;
        
        /**
        * Returns the argb value of the bitmapData pixel at the given u v coordinate.
        * 
        * @param	u	The u (horizontal) texture coordinate.
        * @param	v	The v (verical) texture coordinate.
        * @return		The argb pixel value.
        */
        function getPixel32(u:Float, v:Float):UInt;
		
		function getFaceVO(face:Face, source:Object3D, ?view:View3D = null):FaceVO;
		
		function removeFaceDictionary():Void;
		
		/**
		 * Default method for adding a materialResize event listener
		 * 
		 * @param	listener		The listener function
		 */
        function addOnMaterialResize(listener:Dynamic):Void;
		
		/**
		 * Default method for removing a materialResize event listener
		 * 
		 * @param	listener		The listener function
		 */
        function removeOnMaterialResize(listener:Dynamic):Void;
    }
