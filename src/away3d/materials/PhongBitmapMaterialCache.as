package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class PhongBitmapMaterialCache extends BitmapMaterialContainer
	{
		internal var _shininess:Number;
		internal var _specular:Number;
		
		public var bitmapMaterial:BitmapMaterial;
		public var phongShader:BitmapMaterialContainer;
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
				if (specularPhongShader)
        			specularPhongShader.specular = val;
        		else
        			materials.push(specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
   			} else if (specularPhongShader)
            	materials.pop()     	
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		public function PhongBitmapMaterialCache(bitmap:BitmapData, init:Object=null)
		{
			init = Init.parse(init);
			
			//create new materials
			bitmapMaterial = new BitmapMaterial(bitmap, init);
			phongShader = new BitmapMaterialContainer(bitmap.width, bitmap.height, {blendMode:BlendMode.MULTIPLY, transparent:false})
			phongShader.materials.push(ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			phongShader.materials.push(diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			
			//add to materials array
			materials = new Array();
			materials.push(bitmapMaterial);
			materials.push(phongShader);
			
			_shininess = init.getNumber("shininess", 20);
			specular = init.getNumber("specular", 0.7, {min:0, max:1});
			
			super(bitmap.width, bitmap.height, init);
		}
		
	}
}