package away3d.loaders
{
    import away3d.core.material.*;
    import away3d.core.mesh.Face;
    import away3d.loaders.data.MaterialData;
    import away3d.loaders.utils.TextureLoadQueue;
    import away3d.loaders.utils.TextureLoader;
    
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
    
    /** Set of the named materials */
    public dynamic class MaterialLibrary extends Dictionary
    {
    	public var length:int = 0;
    	public var texturePath:String;
    	public var autoLoadTextures:Boolean;
    	public var loadRequired:Boolean;
    	
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
    	
    	private var _materialData:MaterialData;
    	private var _image:TextureLoader;
    	private var _face:Face;
    	
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
						_materialData.textureBitmap = new BitmapData(_image.width, _image.height);
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
