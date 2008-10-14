package away3d.materials
{
	import away3d.core.draw.DrawShape;
	
	/* Li */
	/**
    * Interface for materials that are capable of drawing vector shapes.
    */
	public interface IShapeMaterial extends IMaterial
	{
		/**
    	 * Sends data from the material coupled with data from the <code>DrawShape</code> primitive to the render session.
    	 */
		function renderShape(shp:DrawShape):void;
	}
}