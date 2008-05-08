package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.utils.*;
	
	public class PhongColorMaterial extends CompositeMaterial
	{
		
		internal var _shininess:Number;
		internal var _specular:Number;
		
		public var phongShader:CompositeMaterial;
		public var ambientShader:AmbientShader;
		public var diffusePhongShader:DiffusePhongShader;
		public var specularPhongShader:SpecularPhongShader;
				
		public function set shininess(val:Number):void
		{
			_shininess = val;
			if (specularPhongShader)
           		specularPhongShader.shininess = val;
		}
		
		public function get shininess():Number
		{
			return _shininess;
		}
		
		public function set specular(val:Number):void
		{
			_specular = val
			if (_specular) {
				specularPhongShader.shininess = _shininess;
				specularPhongShader.specular = _specular;
				materials = [phongShader, specularPhongShader];
   			} else {
   				materials = [ambientShader, diffusePhongShader];
   			}
            
			_colorTransformDirty = true;
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		internal override function setColorTransform():void
		{
			_colorTransformDirty = false;
			
			if (_specular) {
				_colorTransform = null;
				phongShader.color = _color;
				phongShader.alpha = _alpha;
			} else {
				super.setColorTransform();
			}
		}
		
		public function PhongColorMaterial(init:Object=null)
		{
			init = Init.parse(init);
			
			//create new materials
			phongShader = new CompositeMaterial();
			phongShader.materials.push(ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			phongShader.materials.push(diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			specularPhongShader = new SpecularPhongShader({blendMode:BlendMode.ADD});
			
			//add to materials array
			materials = new Array();
			
			_shininess = init.getNumber("shininess", 20);
			color = init.getColor("color", 0xFFFFFF);
			specular = init.getNumber("specular", 0.7, {min:0, max:1});
			
			super(init);
		}
		
	}
}