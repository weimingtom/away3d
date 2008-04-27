package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.ColorTransform;
	import flash.utils.*;
	
	public class PhongColorMaterial extends CompositeMaterial
	{
		internal var _color:uint;
		internal var _red:Number;
		internal var _green:Number;
		internal var _blue:Number;
		
		internal var _shininess:Number;
		internal var _specular:Number;
		
		public var phongShader:CompositeMaterial;
		public var ambientShader:AmbientShader;
		public var diffusePhongShader:DiffusePhongShader;
		public var specularPhongShader:SpecularPhongShader;
		
		public function set color(val:uint):void
		{
			_color = val;
            _red = ((_color & 0xFF0000) >> 16)/255;
            _green = ((_color & 0x00FF00) >> 8)/255;
            _blue = (_color & 0x0000FF)/255;
            setColorTransform();
		}
		
		public function get color():uint
		{
			return _color;
		}
				
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
            setColorTransform();
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		public function setColorTransform():void
		{
			if (_specular) {
				colorTransform = null;
				if (_color != 0xFFFFFF)
					phongShader.colorTransform = new ColorTransform(_red, _green, _blue);
				else
					phongShader.colorTransform = null;
			} else {
				if (_color != 0xFFFFFF)
					colorTransform = new ColorTransform(_red, _green, _blue);
				else
					colorTransform = null;
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