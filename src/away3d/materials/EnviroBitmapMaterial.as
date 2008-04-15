package away3d.materials
{
	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	import flash.utils.*;
	
	public class EnviroBitmapMaterial extends CompositeMaterial
	{
		internal var _enviroMap:BitmapData;
		internal var _mode:String;
		internal var _reflectiveness:Number;
		
		public var bitmapMaterial:BitmapMaterial;
		public var enviroShader:EnviroShader;
		
		public function set reflectiveness(val:Number):void
		{
			_reflectiveness = val
			enviroShader.reflectiveness = val;
		}
		
		public function get reflectiveness():Number
		{
			return _reflectiveness;
		}
		
		public function EnviroBitmapMaterial(bitmap:BitmapData, init:Object=null)
		{
			init = Init.parse(init);
			
			_enviroMap = init.getBitmap("enviroMap");
			_mode = init.getString("mode", "linear");
			_reflectiveness = init.getNumber("reflectiveness", 0.5, {min:0, max:1});
			
			//create new materials
			bitmapMaterial = new BitmapMaterial(bitmap, init);
			enviroShader = new EnviroShader(_enviroMap, {mode:_mode, reflectiveness:_reflectiveness});
			
			//add to materials array
			materials = new Array();
			materials.push(bitmapMaterial);
			materials.push(enviroShader);
			
			super(init);
		}
		
	}
}