package away3d.materials;

    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
	
	/**
	 * Color material with flat shading.
	 */
    class ShadingColorMaterial extends CenterLightingMaterial {
		public var visible(getVisible, null) : Bool
        ;
		
		var fr:Int;
		var fg:Int;
		var fb:Int;
		var sfr:Int;
		var sfg:Int;
		var sfb:Int;
		
		/**
		 * Defines a color value for ambient light.
		 */
        public var ambient:UInt;
		
		/**
		 * Defines a color value for diffuse light.
		 */
        public var diffuse:UInt;
		
		/**
		 * Defines a color value for specular light.
		 */
        public var specular:UInt;
        
        /**
        * Defines an alpha value for the texture.
        */
        public var alpha:Float;
        
        /**
        * Defines whether the resulting shaded color of the surface should be cached.
        */
        public var cache:Bool;
    	
		/**
		 * Creates a new <code>ShadingColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?color:Dynamic = null, ?init:Dynamic = null)
        {
        	if (color == null)
                color = "random";

            color = Cast.trycolor(color);
            
            super(init);
			
            ambient = ini.getColor("ambient", color);
            diffuse = ini.getColor("diffuse", color);
            specular = ini.getColor("specular", color);
            alpha = ini.getNumber("alpha", 1);
            cache = ini.getBoolean("cache", false);
        }
        
		/**
		 * @inheritDoc
		 */
        override function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Float, kag:Float, kab:Float, kdr:Float, kdg:Float, kdb:Float, ksr:Float, ksg:Float, ksb:Float):Void
        {

            fr = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr + (specular & 0xFF0000) * ksr) >> 16);
            fg = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg + (specular & 0x00FF00) * ksg) >> 8);
            fb = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb + (specular & 0x0000FF) * ksb));
            
            if (fr > 0xFF)
                fr = 0xFF;
            if (fg > 0xFF)
                fg = 0xFF;
            if (fb > 0xFF)
                fb = 0xFF;

            session.renderTriangleColor(fr << 16 | fg << 8 | fb, alpha, tri.v0, tri.v1, tri.v2);

            if (cache)
                if (tri.face != null)
                {
                    sfr = int(((ambient & 0xFF0000) * kar + (diffuse & 0xFF0000) * kdr) >> 16);
                    sfg = int(((ambient & 0x00FF00) * kag + (diffuse & 0x00FF00) * kdg) >> 8);
                    sfb = int(((ambient & 0x0000FF) * kab + (diffuse & 0x0000FF) * kdb));

                    if (sfr > 0xFF)
                        sfr = 0xFF;
                    if (sfg > 0xFF)
                        sfg = 0xFF;
                    if (sfb > 0xFF)
                        sfb = 0xFF;

                    tri.face.material = new ColorMaterial(sfr << 16 | sfg << 8 | sfb);
                }
        }
        
		/**
    	 * Indicates whether the material is visible
    	 */
        public override function getVisible():Bool
        {
            return true;
        }
 
    }
