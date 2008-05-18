package away3d.materials
{
    /**
    * Interface for all objects that can serve as a material
    */
    public interface IMaterial 
    {
		/**
    	 * Indicates whether the material is visible
    	 */
        function get visible():Boolean;
    }
}
