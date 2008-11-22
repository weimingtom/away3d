package away3d.materials;

    import away3d.containers.*;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.events.*;
	
	use namespace arcane;
	
    /**
    * Material for solid color drawing
    */
    class ColorMaterial extends EventDispatcher, implements ITriangleMaterial, implements IFogMaterial {
		public var alpha(getAlpha, setAlpha) : Float
        ;
		public var color(getColor, setColor) : UInt
        ;
		public var visible(getVisible, null) : Bool
        ;
		/** @private */
        
		/** @private */
        arcane function notifyMaterialUpdate():Void
        {
            if (!hasEventListener(MaterialEvent.MATERIAL_UPDATED))
                return;
			
            if (_materialupdated == null)
                _materialupdated = new MaterialEvent(MaterialEvent.MATERIAL_UPDATED, this);
                
            dispatchEvent(_materialupdated);
        }
        
    	var _color:UInt;
    	var _alpha:Float;
    	var _faceDirty:Bool;
    	var _materialupdated:MaterialEvent;
    	
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		var ini:Init;
		
		/**
		 * 24 bit color value representing the material color
		 */
        public function setColor(val:UInt):UInt
        {
        	if (_color == val)
        		return;
        	
        	_color = val;
        	
        	_faceDirty = true;
        	return val;
        }
        
        public function getColor():UInt
        {
        	return _color;
        }
        
		/**
		 * @inheritDoc
		 */
        public function setAlpha(val:Float):Float
        {
        	if (_alpha == val)
        		return;
        	
        	_alpha = val;
        	
        	_faceDirty = true;
        	return val;
        }
        
        public function getAlpha():Float
        {
        	return _alpha;
        }
        
		/**
		 * @inheritDoc
		 */
        public function getVisible():Bool
        {
            return (alpha > 0);
        }
    	
		/**
		 * Creates a new <code>ColorMaterial</code> object.
		 * 
		 * @param	color				A string, hex value or colorname representing the color of the material.
		 * @param	init	[optional]	An initialisation object for specifying default instance properties.
		 */
        public function new(?color:Dynamic = null, ?init:Dynamic = null)
        {
            if (color == null)
                color = "random";

            this.color = Cast.trycolor(color);

            ini = Init.parse(init);
            
            _alpha = ini.getNumber("alpha", 1, {min:0, max:1});
        }
        
		/**
		 * @inheritDoc
		 */
        public function updateMaterial(source:Object3D, view:View3D):Void
        {
        	if (_faceDirty) {
        		_faceDirty = false;
        		notifyMaterialUpdate();
        	}
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderTriangle(tri:DrawTriangle):Void
        {
            tri.source.session.renderTriangleColor(color, _alpha, tri.v0, tri.v1, tri.v2);
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderFog(fog:DrawFog):Void
        {
            fog.source.session.renderFogColor(fog.clip, color, _alpha);
        }
        
		/**
		 * @inheritDoc
		 */
        public function clone():IFogMaterial
        {
        	return new ColorMaterial(color, {alpha:alpha});
        }
        
		/**
		 * @inheritDoc
		 */
        public function addOnMaterialUpdate(listener:Dynamic):Void
        {
        	addEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false, 0, true);
        }
        
		/**
		 * @inheritDoc
		 */
        public function removeOnMaterialUpdate(listener:Dynamic):Void
        {
        	removeEventListener(MaterialEvent.MATERIAL_UPDATED, listener, false);
        }
    }
