package away3d.sprites;

    import away3d.containers.*;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.project.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    
    import flash.display.BitmapData;
    import flash.utils.Dictionary;
	
	/**
	 * Spherical billboard (always facing the camera) sprite object that uses an array of bitmapData objects defined with viewing direction vectors.
	 * Draws 2d directional image dependent on viewing angle inline with z-sorted triangles in a scene.
	 */
    class DirSprite2D extends Object3D {
        public var bitmaps(getBitmaps, null) : Dictionary
    	;
        public var vertices(getVertices, null) : Array<Dynamic>
    	;
        
        var _vertices:Array<Dynamic> ;
        var _bitmaps:Dictionary ;
        
        /**
        * Defines the overall scaling of the sprite object
        */
        public var scaling:Float;
        
        /**
        * Defines the overall 2d rotation of the sprite object
        */
        public var rotation:Float;
		
    	/**
    	 * Defines whether the texture bitmap is smoothed (bilinearly filtered) when drawn to screen
    	 */
        public var smooth:Bool;
        
        /**
        * An optional offset value added to the z depth used to sort the sprite
        */
        public var deltaZ:Float;
    	
    	public function getVertices():Array<Dynamic>
    	{
    		return _vertices;
    	}
    	
    	public function getBitmaps():Dictionary
    	{
    		return _bitmaps;
    	}
    	
		/**
		 * Creates a new <code>DirSprite2D</code> object.
		 * 
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?init:Dynamic = null)
        {
            
            _vertices = [];
            _bitmaps = new Dictionary(true);
            super(init);
    
            scaling = ini.getNumber("scaling", 1, {min:0});
            rotation = ini.getNumber("rotation", 0);
            smooth = ini.getBoolean("smooth", false);
            deltaZ = ini.getNumber("deltaZ", 0);

            var btmps:Array<Dynamic> = ini.getArray("bitmaps");
            for (btmp in btmps)
            {
                btmp = Init.parse(btmp);
                var x:Int = btmp.getNumber("x", 0);
                var y:Int = btmp.getNumber("y", 0);
                var z:Int = btmp.getNumber("z", 0);
                var b:BitmapData = btmp.getBitmap("bitmap");
                add(x, y, z, b);
            }
            
            projector = cast( ini.getObject("projector", IPrimitiveProvider), IPrimitiveProvider);
            
            if (!projector)
            	projector = new DirSpriteProjector();
        }
		
		/**
		 * Adds a new bitmap definition to the array of directional textures.
		 * 
		 * @param		x			The x coordinate of the directional texture.
		 * @param		y			The y coordinate of the directional texture.
		 * @param		z			The z coordinate of the directional texture.
		 * @param		bitmap		The bitmapData object to be used as the directional texture.
		 */
        public function add(x:Float, y:Float, z:Float, bitmap:BitmapData):Void
        {
            if (bitmap)
            for each (var v:Vertex in _vertices)
                if ((v.x == x) && (v.y == y) && (v.z == z))
                {
                    Debug.warning("Same base point for two bitmaps: "+v);
                    return;
                }

            var vertex:Vertex = new Vertex(x, y, z);
            _vertices.push(vertex);
            _bitmaps[vertex] = bitmap;
        }
    }
