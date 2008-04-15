package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.geom.Matrix;
	import flash.utils.*;
	
	public class Dot3MovieMaterial extends CompositeMaterial
	{
		internal var _shininess:Number;
		internal var _specular:Number;
		internal var _normalMap:BitmapData;
		
		public var movieMaterial:MovieMaterial;
		public var phongShader:CompositeMaterial;
		public var ambientShader:AmbientShader;
		public var diffuseDot3Shader:DiffuseDot3Shader;
		public var specularPhongShader:SpecularPhongShader;
		
		public function set shininess(val:Number):void
		{
			_shininess = val;
            specularPhongShader.shininess = val;
		}
		
		public function get shininess():Number
		{
			return _specular;
		}
		
		public function set specular(val:Number):void
		{
			_specular = val;
            //specularPhongShader.specular = val;
		}
		
		public function get specular():Number
		{
			return _specular;
		}
		
		public function get normalMap():BitmapData
		{
			return _normalMap;
		}
		
		public function Dot3MovieMaterial(movie:Sprite, init:Object=null)
		{
			init = Init.parse(init);
			
			_shininess = init.getNumber("shininess", 20);
			_specular = init.getNumber("specular", 0.7);
			_normalMap = init.getBitmap("normalMap");
			
			if (!_normalMap) {
				_normalMap = new BitmapData(movie.width, movie.height, true, 0);
				var matrix:Matrix = new Matrix();
				matrix.tx = -movie.getBounds(movie).left;
				matrix.ty = -movie.getBounds(movie).top;
				_normalMap.draw(movie, matrix);
			}
			//create new materials
			movieMaterial = new MovieMaterial(movie, init);
			phongShader = new CompositeMaterial({blendMode:BlendMode.MULTIPLY})
			phongShader.materials.push(ambientShader = new AmbientShader({blendMode:BlendMode.ADD}));
			phongShader.materials.push(diffuseDot3Shader = new DiffuseDot3Shader(_normalMap, {blendMode:BlendMode.ADD}));
			
			//add to materials array
			materials = new Array();
			materials.push(movieMaterial);
			materials.push(phongShader);
			//materials.push(specularPhongShader = new SpecularPhongShader({shininess:_shininess, specular:_specular, blendMode:BlendMode.ADD}));
			
			super(init);
		}
		
	}
}