package away3d.materials;

	import away3d.core.utils.*;
	import away3d.materials.shaders.*;
	
	import flash.display.*;
	
	/**
	 * Bitmap material with cached environment shading.
	 */
	class EnviroBitmapMaterialCache extends BitmapMaterialContainer {
		public var bitmap(getBitmap, null) : BitmapData
		;
		public var enviroMap(getEnviroMap, null) : BitmapData
		;
		public var mode(getMode, setMode) : String;
		public var reflectiveness(getReflectiveness, setReflectiveness) : Float;
		
		var _mode:String;
		var _reflectiveness:Float;	
		var _bitmapMaterial:BitmapMaterial;
		var _enviroShader:EnviroShader;
		
		/**
		 * Setting for possible mapping methods.
		 */
		public function getMode():String{
			return _mode;
		}
        
		public function setMode(val:String):String{
			_mode = val;
			_enviroShader.mode = val;
			return val;
		}
				
		/**
		 * Coefficient for the reflectiveness of the material.
		 */
		public function getReflectiveness():Float{
			return _reflectiveness;
		}
        
		public function setReflectiveness(val:Float):Float{
			_reflectiveness = val;
			_enviroShader.reflectiveness = val;
			return val;
		}
		
        /**
        * Returns the bitmapData object being used as the material environment map.
        */
		public function getEnviroMap():BitmapData
		{
			return _enviroShader.bitmap;
		}
        
        /**
        * Returns the bitmapData object being used as the material texture.
        */
		public override function getBitmap():BitmapData
		{
			return _bitmapMaterial.bitmap;
		}
		
		/**
		 * Creates a new <code>EnviroBitmapMaterialCache</code> object.
		 * 
		 * @param	bitmap				The bitmapData object to be used as the material's texture.
		 * @param	enviroMap			The bitmapData object to be used as the material's environment map.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
		public function new(bitmap:BitmapData, enviroMap:BitmapData, ?init:Dynamic=null)
		{
			ini = Init.parse(init);
			
			_mode = ini.getString("mode", "linear");
			_reflectiveness = ini.getNumber("reflectiveness", 0.5, {min:0, max:1});
			
			//create new materials
			_bitmapMaterial = new BitmapMaterial(bitmap, ini);
			_enviroShader = new EnviroShader(enviroMap, {mode:_mode, reflectiveness:_reflectiveness});
			
			//add to materials array
			materials = new Array();
			materials.push(_bitmapMaterial);
			materials.push(_enviroShader);
			
			super(bitmap.width, bitmap.height);
		}
		
	}
