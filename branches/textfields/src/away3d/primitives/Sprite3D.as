package away3d.primitives
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Shape3D;
	import away3d.core.project.ShapeProjector;
	import away3d.materials.ShapeMaterial;
	
	public class Sprite3D extends Mesh
	{
		public function Sprite3D(init:Object)
		{
			init.projector = new ShapeProjector(this);
			init.material = new ShapeMaterial();
			super(init);
		}
		
		public function addChild(shp:Shape3D):void
		{
			addShape(shp);
		}
		
		public function removeChild(shp:Shape3D):void
		{
			removeShape(shp);
		}
	}
}