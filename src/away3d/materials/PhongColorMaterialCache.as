package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	public class PhongColorMaterialCache extends BitmapMaterialContainer
	{
		
		internal var _shininess:Number;
		internal var _specular:Number;
		
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
			_specular = val;
			if (_specular) {
				if (specularPhongShader)
        			specularPhongShader.specular = val;
        		else
        			materials.push(specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
   			} else if (specularPhongShader) {
            	materials.pop();
   			}
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		internal override function setColorTransform():void
		{
			phongShader.color = _color;
			phongShader.alpha = _alpha;
		}
		
		public function PhongColorMaterialCache(init:Object=null)
		{
			ini = Init.parse(init);
			
			//create new materials
			phongShader = new BitmapMaterialContainer(bitmap.width, bitmap.height, {transparent:false});
			phongShader.materials.push(ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			phongShader.materials.push(diffusePhongShader = new DiffusePhongShader({blendMode:BlendMode.ADD}));
			specularPhongShader = new SpecularPhongShader({blendMode:BlendMode.ADD});
			
			//add to materials array
			materials = new Array();
			materials.push(phongShader);
			
			_shininess = ini.getNumber("shininess", 20);
			specular = ini.getNumber("specular", 0.7, {min:0, max:1});
			
			super(bitmap.width, bitmap.height, ini);
		}
		
	}
}