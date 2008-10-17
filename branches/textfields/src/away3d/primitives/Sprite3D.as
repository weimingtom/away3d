package away3d.primitives
{
	import away3d.core.base.Mesh;
	import away3d.core.base.Shape3D;
	import away3d.core.project.ShapeProjector;
	import away3d.materials.ShapeMaterial;
	
	public class Sprite3D extends Mesh
	{
		public function Sprite3D()
		{
			var proj:ShapeProjector = new ShapeProjector(this);
			var mat:ShapeMaterial = new ShapeMaterial();
			
			super({projector:proj, material:mat});
		}
		
		public function addChild(shp:Shape3D):void
		{
			addShape(shp);
		}
	}
}