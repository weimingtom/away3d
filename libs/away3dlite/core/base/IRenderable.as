package away3dlite.core.base
{
	
	import flash.display.Graphics;
	import flash.geom.Vector3D;
	
	/**
	 * @author katopz
	 */
	public interface IRenderable
	{
		function get projectedPosition():Vector3D;
		function get screenZ():Number;
		function get isClip():Boolean;
		
		function render(x:Number, y:Number, graphics:Graphics, zoom:Number, focus:Number):void
	}
}