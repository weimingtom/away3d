package away3d.loaders.utils
{
    import away3d.materials.*;
    import away3d.core.base.*;
    import away3d.loaders.data.*;
    
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
    
    /**
    * Store for all materials associated with an externally loaded file.
    */
    public dynamic class MaterialLibrary extends Dictionary
    {
    	private var _materialData:MaterialData;
    	private var _image:TextureLoader;
    	private var _face:Face;
    	private var length:int = 0;
    	
    	/**
    	 * The root directory path to the texture files.
    	 */
    	public var texturePath:String;
    	
    	/**
    	 * Determines whether textures should be loaded automatically.
    	 */
    	public var autoLoadTextures:Boolean;
    	
    	/**
    	 * Flag to determine if any of the contained textures require a file load.
    	 */
    	public var loadRequired:Boolean;
    	
    	/**
    	 * Adds a material name reference to the library.
    	 */
        public function addMaterial(name:String):MaterialData
        {
        	//return if material already exists
        	if (this[name])
        		return this[name];
        	
        	length++;
        	
        	var materialData:MaterialData = new MaterialData();
            this[materialData.name = name] = materialData;
            return materialData;
        }
    	
    	/**
    	 * Called after all textures have been loaded from the <code>TextureLoader</code> class.
    	 * 
    	 * @see away3d.loaders.utils.TextureLoader
    	 */
    	public function texturesLoaded(loadQueue:TextureLoadQueue):void
    	{
    		loadRequired = false;
    		
			var images:Array = loadQueue.images;
			
			for each (_materialData in this)
			{
				for each (_image in images)
				{
					if (texturePath + _materialData.textureFileName == _image.filename)
					{
						_materialData.textureBitmap = new BitmapData(_image.width, _image.height, true);
						_materialData.textureBitmap.draw(_image);
						_materialData.material = new BitmapMaterial(_materialData.textureBitmap);
						for each(_face in _materialData.faces)
						{
							_face.material = _materialData.material;
						}
					}
				}
			}
    	}
    }
}
