package away3d.materials;

    import away3d.containers.*;
    import away3d.arcane;
    import away3d.core.base.*;
    import away3d.core.draw.*;
    import away3d.core.light.*;
    import away3d.core.math.*;
    import away3d.core.render.*;
    import away3d.core.utils.*;
    import away3d.events.*;
    
    import flash.display.*;
    import flash.events.*;

	use namespace arcane;
	
    /**
    * Abstract class for materials that calculate lighting for the face's center
    * Not intended for direct use - use <code>ShadingColorMaterial</code> or <code>WhiteShadingBitmapMaterial</code>.
    */
    class CenterLightingMaterial extends EventDispatcher, implements ITriangleMaterial {
        public var visible(getVisible, null) : Bool
        ;
        /** @private */
        
        /** @private */
        arcane var v0:ScreenVertex;
        /** @private */
        arcane var v1:ScreenVertex;
        /** @private */
        arcane var v2:ScreenVertex;
        /** @private */
        arcane var session:AbstractRenderSession;
		
		var point:PointLight;
		var directional:DirectionalLight;
		var global:AmbientLight;
        var focus:Float;
        var zoom:Float;
        var v0z:Float;
        var v0p:Float;
        var v0x:Float;
        var v0y:Float;
        var v1z:Float;
        var v1p:Float;
        var v1x:Float;
        var v1y:Float;
        var v2z:Float;
        var v2p:Float;
        var v2x:Float;
        var v2y:Float;
        var d1x:Float;
        var d1y:Float;
        var d1z:Float;
        var d2x:Float;
        var d2y:Float;
        var d2z:Float;
        var pa:Float;
        var pb:Float;
        var pc:Float;
        var pdd:Float;
        var c0x:Float;
        var c0y:Float;
        var c0z:Float;
        var kar:Float;
        var kag:Float;
        var kab:Float;
        var kdr:Float;
        var kdg:Float;
        var kdb:Float;
        var ksr:Float;
        var ksg:Float;
        var ksb:Float;
        var red:Float;
        var green:Float;
        var blue:Float;
        var dfx:Float;
        var dfy:Float;
        var dfz:Float;
        var df:Float;
        var nx:Float;
        var ny:Float;
        var nz:Float;
        var fade:Float;
        var amb:Float;
        var nf:Float;
        var diff:Float;
        var rfx:Float;
        var rfy:Float;
        var rfz:Float;
        var spec:Float;
        var rf:Float;
        var graphics:Graphics;
        var cz:Float;
        var cx:Float;
        var cy:Float;
        var ncz:Float;
        var ncx:Float;
        var ncy:Float;
        var sum:Float;
        var ffz:Float;
        var ffx:Float;
        var ffy:Float;
        var fz:Float;
        var fx:Float;
        var fy:Float;
        var rz:Float;
        var rx:Float;
        var ry:Float;
        var draw_normal:Bool ;
        var draw_fall:Bool ;
        var draw_fall_k:Int ;
        var draw_reflect:Bool ;
        var draw_reflect_k:Int ;
        var _diffuseTransform:Matrix3D;
        var _source:Mesh;
        
        /**
        * Instance of the Init object used to hold and parse default property values
        * specified by the initialiser object in the 3d object constructor.
        */
		var ini:Init;
		
        /** @private */
        function renderTri(tri:DrawTriangle, session:AbstractRenderSession, kar:Float, kag:Float, kab:Float, kdr:Float, kdg:Float, kdb:Float, ksr:Float, ksg:Float, ksb:Float):Void
        {
            throw new Error("Not implemented");
        }
        
        /**
        * Coefficient for ambient light level
        */
        public var ambient_brightness:Int ;
        
        /**
        * Coefficient for diffuse light level
        */
        public var diffuse_brightness:Int ;
        
        /**
        * Coefficient for specular light level
        */
        public var specular_brightness:Int ;
        
        /**
        * Coefficient for shininess level
        */
        public var shininess:Int ;
		
		/**
		 * @private
		 */
        public function new(?init:Dynamic = null)
        {
            
            draw_normal = false;
            draw_fall = false;
            draw_fall_k = 1;
            draw_reflect = false;
            draw_reflect_k = 1;
            ambient_brightness = 1;
            diffuse_brightness = 1;
            specular_brightness = 1;
            shininess = 20;
            ini = Init.parse(init);

            shininess = ini.getColor("shininess", 20);
        }
        
		/**
		 * @inheritDoc
		 */
        public function updateMaterial(source:Object3D, view:View3D):Void
        {
        	for (directional in source.lightarray.directionals) {
        		if (!directional.diffuseTransform[source] || view.scene.updatedObjects[source]) {
        			directional.setDiffuseTransform(source);
        		}
        	}
        }
        
		/**
		 * @inheritDoc
		 */
        public function renderTriangle(tri:DrawTriangle):Void
        {
        	session = tri.source.session;
            v0 = tri.v0;
            v1 = tri.v1;
            v2 = tri.v2;
            focus = tri.view.camera.focus;
            zoom = tri.view.camera.zoom;

            v0z = v0.z;
            v0p = (1 + v0z / focus) / zoom;
            v0x = v0.x * v0p;
            v0y = v0.y * v0p;

            v1z = v1.z;
            v1p = (1 + v1z / focus) / zoom;
            v1x = v1.x * v1p;
            v1y = v1.y * v1p;

            v2z = v2.z;
            v2p = (1 + v2z / focus) / zoom;
            v2x = v2.x * v2p;
            v2y = v2.y * v2p;
            
            d1x = v1x - v0x;
            d1y = v1y - v0y;
            d1z = v1z - v0z;

            d2x = v2x - v0x;
            d2y = v2y - v0y;
            d2z = v2z - v0z;

            pa = d1y*d2z - d1z*d2y;
            pb = d1z*d2x - d1x*d2z;
            pc = d1x*d2y - d1y*d2x;
            pdd = Math.sqrt(pa*pa + pb*pb + pc*pc);
            
            pa /= pdd;
            pb /= pdd;
            pc /= pdd;

            c0x = (v0x + v1x + v2x) / 3;
            c0y = (v0y + v1y + v2y) / 3;
            c0z = (v0z + v1z + v2z) / 3;

            kar = kag = kab = kdr = kdg = kdb = ksr = ksg = ksb = 0;
			
			_source = cast( tri.source, Mesh);
			
			for (directional in tri.source.lightarray.directionals)
            {
            	_diffuseTransform = directional.diffuseTransform[_source];
            	
                red = directional.red;
                green = directional.green;
                blue = directional.blue;
				
                dfx = _diffuseTransform.szx;
				dfy = _diffuseTransform.szy;
				dfz = _diffuseTransform.szz;
                
                nx = tri.face.normal.x;
                ny = tri.face.normal.y;
                nz = tri.face.normal.z;
                
                amb = directional.ambient * ambient_brightness;
				
                kar += red * amb;
                kag += green * amb;
                kab += blue * amb;
                
                nf = dfx*nx + dfy*ny + dfz*nz;
				
                if (nf < 0)
                    continue;
				
                diff = directional.diffuse * nf * diffuse_brightness;
                
                kdr += red * diff;
                kdg += green * diff;
                kdb += blue * diff;
                
                rfx = _diffuseTransform.szx;
				rfy = _diffuseTransform.szy;
				rfz = _diffuseTransform.szz;
				
				rf = rfx*nx + rfy*ny + rfz*nz;
				
                spec = directional.specular * Math.pow(rf, shininess) * specular_brightness;
                
                ksr += red * spec;
                ksg += green * spec;
                ksb += blue * spec;
            }
            
            for (point in tri.source.lightarray.points)
            {
                red = point.red;
                green = point.green;
                blue = point.blue;

                dfx = point.x - c0x;
                dfy = point.y - c0y;
                dfz = point.z - c0z;
                df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                dfx /= df;
                dfy /= df;
                dfz /= df;
                fade = 1 / df / df;
                
                amb = point.ambient * fade * ambient_brightness;

                kar += red * amb;
                kag += green * amb;
                kab += blue * amb;
                
                nf = dfx*pa + dfy*pb + dfz*pc;

                if (nf < 0)
                    continue;

                diff = point.diffuse * fade * nf * diffuse_brightness;

                kdr += red * diff;
                kdg += green * diff;
                kdb += blue * diff;
                
                rfz = dfz - 2*nf*pc;

                if (rfz < 0)
                    continue;

                rfx = dfx - 2*nf*pa;
                rfy = dfy - 2*nf*pb;
                
                spec = point.specular * fade * Math.pow(rfz, shininess) * specular_brightness;

                ksr += red * spec;
                ksg += green * spec;
                ksb += blue * spec;
            }
			
            renderTri(tri, session, kar, kag, kab, kdr, kdg, kdb, ksr, ksg, ksb);
			
            if (draw_fall || draw_reflect || draw_normal)
            {
                graphics = session.graphics,
                cz = c0z,
                cx = c0x * zoom / (1 + cz / focus),
                cy = c0y * zoom / (1 + cz / focus);
                
                if (draw_normal)
                {
                    ncz = (c0z + 30*pc),
                    ncx = (c0x + 30*pa) * zoom * focus / (focus + ncz),
                    ncy = (c0y + 30*pb) * zoom * focus / (focus + ncz);

                    graphics.lineStyle(1, 0x000000, 1);
                    graphics.moveTo(cx, cy);
                    graphics.lineTo(ncx, ncy);
                    graphics.moveTo(cx, cy);
                    graphics.drawCircle(cx, cy, 2);
                }

                if (draw_fall || draw_reflect)
                    for (point in tri.source.lightarray.points)
                    {
                        red = point.red;
                        green = point.green;
                        blue = point.blue;
                        sum = (red + green + blue) / 0xFF;
                        red /= sum;
                        green /= sum;
                        blue /= sum;
                
                        dfx = point.x - c0x;
                        dfy = point.y - c0y;
                        dfz = point.z - c0z;
                        df = Math.sqrt(dfx*dfx + dfy*dfy + dfz*dfz);
                        dfx /= df;
                        dfy /= df;
                        dfz /= df;
                
                        nf = dfx*pa + dfy*pb + dfz*pc;
                        if (nf < 0)
                            continue;
                
                        if (draw_fall)
                        {
                            ffz = (c0z + 30*dfz*(1-draw_fall_k)),
                            ffx = (c0x + 30*dfx*(1-draw_fall_k)) * zoom * focus / (focus + ffz),
                            ffy = (c0y + 30*dfy*(1-draw_fall_k)) * zoom * focus / (focus + ffz),

                            fz = (c0z + 30*dfz),
                            fx = (c0x + 30*dfx) * zoom * focus / (focus + fz),
                            fy = (c0y + 30*dfy) * zoom * focus / (focus + fz);

                            graphics.lineStyle(1, int(red)*0x10000 + int(green)*0x100 + int(blue), 1);
                            graphics.moveTo(ffx, ffy);
                            graphics.lineTo(fx, fy);
                            graphics.moveTo(ffx, ffy);
                        }

                        if (draw_reflect)
                        {
                            rfx = dfx - 2*nf*pa;
                            rfy = dfy - 2*nf*pb;
                            rfz = dfz - 2*nf*pc;
                    
                            rz = (c0z - 30*rfz*draw_reflect_k),
                            rx = (c0x - 30*rfx*draw_reflect_k) * zoom * focus / (focus + rz),
                            ry = (c0y - 30*rfy*draw_reflect_k) * zoom * focus / (focus + rz);
                        
                            graphics.lineStyle(1, int(red*0.5)*0x10000 + int(green*0.5)*0x100 + int(blue*0.5), 1);
                            graphics.moveTo(cx, cy);
                            graphics.lineTo(rx, ry);
                            graphics.moveTo(cx, cy);
                        }
                    }
            }
        }
        
		/**
		 * @private
		 */
        public function getVisible():Bool
        {
            throw new Error("Not implemented");
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
