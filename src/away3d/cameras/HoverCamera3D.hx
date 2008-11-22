package away3d.cameras;

    import away3d.core.base.*;
    import away3d.core.utils.*;
	
    /**
    * Extended camera used to hover round a specified target object.
    * 
    * @see	away3d.containers.View3D
    */
    class HoverCamera3D extends TargetCamera3D {
        
        inline static var toRADIANS:Int = Math.PI / 180;
        
    	/**
    	 * Fractional difference in distance between the horizontal camera orientation and vertical camera orientation. Defaults to 2.
    	 * 
    	 * @see	#distance
    	 */
        public var yfactor:Int ;

        /**
        * Distance between the camera and the specified target. Defaults to 800.
        */
        public var distance:Int ;
        
        public var wrappanangle:Bool;
        /**
        * Rotation of the camera in degrees around the y axis. Defaults to 0.
        */
        public var panangle:Int ;
        
        /**
        * Elevation angle of the camera in degrees. Defaults to 90.
        */
        public var tiltangle:Int ;
        
        /**
        * Target value for the <code>panangle</code>. Defaults to 0.
        * 
        * @see	#panangle
        */
        public var targetpanangle:Int ;
        
        /**
        * Target value for the <code>tiltangle</code>. Defaults to 90.
        * 
        * @see	#tiltangle
        */
        public var targettiltangle:Int ;
                
        /**
        * Minimum bounds for the <code>tiltangle</code>. Defaults to 0.
        * 
        * @see	#tiltangle
        */
        public var mintiltangle:Int ;
                
        /**
        * Maximum bounds for the <code>tiltangle</code>. Defaults to 90.
        * 
        * @see	#tiltangle
        */
        public var maxtiltangle:Int ;
        
        /**
        * Fractional step taken each time the <code>hover()</code> method is called. Defaults to 8.
        * 
        * Affects the speed at which the <code>tiltangle</code> and <code>panangle</code> resolve to their targets.
        * 
        * @see	#tiltangle
        * @see	#panangle
        */
        public var steps:Int ;
    	
	    /**
	    * Creates a new <code>HoverCamera3D</code> object.
	    * 
	    * @param	init	[optional]	An initialisation object for specifying default instance properties.
	    */
        public function new(?init:Dynamic = null)
        {
            
            yfactor = 2;
            distance = 800;
            panangle = 0;
            tiltangle = 90;
            targetpanangle = 0;
            targettiltangle = 90;
            mintiltangle = 0;
            maxtiltangle = 90;
            steps = 8;
            super(init);

            yfactor = ini.getNumber("yfactor", yfactor);
			distance = ini.getNumber("distance", distance);
			wrappanangle = ini.getBoolean("wrappanangle", false);
			panangle = ini.getNumber("panangle", panangle);
			tiltangle = ini.getNumber("tiltangle", tiltangle);
			targetpanangle = ini.getNumber("targetpanangle", targetpanangle);
			targettiltangle = ini.getNumber("targettiltangle", targettiltangle);
			mintiltangle = ini.getNumber("mintiltangle", mintiltangle);
			maxtiltangle = ini.getNumber("maxtiltangle", maxtiltangle);
			steps = ini.getNumber("steps", steps);
			
            update();
        }
        
        /**
        * Updates the <code>tiltangle</code> and <code>panangle</code> values, then calls <code>update()</code>.
        * 
        * Values are calculated using the defined <code>targettiltangle</code>, <code>targetpanangle</code> and <code>steps</code> variables.
        * 
        * @return		True if the camera position was updated, otherwise false.
        * 
        * @see	#tiltangle
        * @see	#panangle
        * @see	#targettiltangle
        * @see	#targetpanangle
        * @see	#steps
        * @see	#update()
        */
        public function hover():Bool
        {
            if ((targettiltangle == tiltangle) && (targetpanangle == panangle))
                return update();

            targettiltangle = Math.max(mintiltangle, Math.min(maxtiltangle, targettiltangle));
            
            if (wrappanangle) {
	            if (targetpanangle < 0)
	            	targetpanangle = (targetpanangle % 360) + 360;
	            else
	            	targetpanangle = targetpanangle % 360;
	            
	            if (targetpanangle - panangle < -180)
	            	targetpanangle += 360;
	            else if (targetpanangle - panangle > 180)
	            	targetpanangle -= 360;
            }
            
            tiltangle += (targettiltangle - tiltangle) / (steps + 1);
            panangle += (targetpanangle - panangle) / (steps + 1);

            if ((Math.abs(targettiltangle - tiltangle) < 0.01) && (Math.abs(targetpanangle - panangle) < 0.01))
            {
                tiltangle = targettiltangle;
                panangle = targetpanangle;
            }
			
            return update();
        }

        /**
        * Updates the camera position.
        * 
        * Position is calculated using the current values of <code>tiltangle</code>, <code>panangle</code>, <code>distance</code> and <code>yfactor</code>.
        * 
        * @return		True if the camera position was updated, otherwise false.
        * 
        * @see	#tiltangle
        * @see	#panangle
        * @see	#distance
        * @see	#yfactor
        */
        public function update():Bool
        {
            var gx:Int = distance * Math.sin(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS);
            var gz:Int = distance * Math.cos(panangle * toRADIANS) * Math.cos(tiltangle * toRADIANS);
            var gy:Int = distance * Math.sin(tiltangle * toRADIANS) * yfactor;
			
            if ((x == gx) && (y == gy) && (z == gz))
                return false;
			
            x = gx;
            y = gy;
            z = gz;
			
            return true;
        }
    }
