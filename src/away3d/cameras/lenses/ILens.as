package away3d.cameras.lenses
{
	import away3d.containers.*;
	import away3d.core.base.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.math.*;
	
	public interface ILens
	{
		function setView(val:View3D):void
		
		function getFrustum(node:Object3D, viewTransform:MatrixAway3D):Frustum;
		
		function getFOV():Number;
		
		function getZoom():Number;
        
       /**
        * Projects the vertex to the screen space of the view.
        */
        function project(viewTransform:MatrixAway3D, vertex:Vertex):ScreenVertex;
	}
}