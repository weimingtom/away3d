package away3d.cameras.lenses;

import away3d.core.math.Matrix3D;
import away3d.core.base.Vertex;
import away3d.containers.View3D;
import away3d.core.draw.ScreenVertex;
import away3d.core.base.Object3D;
import away3d.core.geom.Frustum;


interface ILens  {
	
	function setView(val:View3D):Void;

	function getFrustum(node:Object3D, viewTransform:Matrix3D):Frustum;

	function getFOV():Float;

	function getZoom():Float;

	function project(viewTransform:Matrix3D, vertex:Vertex):ScreenVertex;

	

}

