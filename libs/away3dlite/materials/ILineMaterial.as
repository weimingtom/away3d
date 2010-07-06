package away3dlite.materials
{
	import away3dlite.core.base.Mesh;
	
	import flash.display.Graphics;
	
	/**
	 * @author katopz
	 */
	public interface ILineMaterial
	{
		function collectGraphicsPath(mesh:Mesh):void
		function drawGraphicsData(mesh:Mesh, graphic:Graphics):void
	}
}
