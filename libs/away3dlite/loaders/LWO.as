package away3dlite.loaders
{
	import flash.utils.*;
	import flash.events.*;
	import flash.utils.Endian;
	import flash.utils.ByteArray;
	import we3d.material.BitmapAttributes;
	import we3d.mesh.Face;
	import we3d.mesh.Vertex;
	import we3d.mesh.UVCoord;
	import we3d.mesh.VertexMap;
	import we3d.scene.LightGlobals;
	import we3d.material.Surface;
	import we3d.material.MaterialManager;
	import we3d.scene.SceneObject;
	import we3d.loader.SceneLoader;
	import we3d.loader.ImageLoadEvent;
	import we3d.math.Vector3d;
	import we3d.filter.ZBuffer;
	
	/**
	* Load LightWave Object Files (LWO). <br/>
	* <br/>
	* Support:<br/>
	* <br/>
	* - Parse Layers into SceneObjects with hierarchies and pivot point (the objects list have to be sorted with sortHierarchy) <br/>
	* - Parse Lines, Triangles, Quads and Polygons (Subpatches will be parsed but not displayed) <br/>
	* - UV Mapping <br/>
	* <br/>
	* Supported Surface Properties: <br/>
	* <br/>
	* - Color <br/>
	* - Luminosity <br/>
	* - Diffuse <br/>
	* - Transparency <br/>
	* - Double sided <br/>
	* - Outlines/Thickness <br/>
	* - UV-Texture in the first Color Layer, the images have to be in the same directory of the lwo file <br/>
	*/
	public class LWO extends SceneLoader
	{
		public function LWOLoader () {}
		
		public var defaultSurface:Surface;
		public var lightGlobals:LightGlobals;
		
		/**
		* If true, the materials use the as3 software renderer
		*/
		public var scanline:Boolean = false;
		/**
		* If zbuffer is not null, the material support zbuffer. works only with bitmap materials
		*/
		public var zbuffer:ZBuffer = null;
		
		private var piid:int=-1; 
		private var bytes:ByteArray;
		private var tags:Array;
		private var textures:Array;
		private var currTexture:Object;
		private var currPivot:Vector3d = new Vector3d();
		private var cc:String = "us-ascii";
		private var fileVmads:Array;
		private var vmadsByName:Object;
		private var parents:Array;
		private var matmgr:MaterialManager = new MaterialManager();
		
		public function get materialManager () :MaterialManager {
			return matmgr;
		}
		
		public override function parseFile (b:ByteArray) :void {
			status = 0;
			super.init();
			
			if(defaultSurface == null) defaultSurface = new Surface();
			
			bytes = b;
			bytes.endian = Endian.BIG_ENDIAN;
			bytes.position = 8;
			textures = [];
			vmadsByName = {};
			fileVmads = [];	
			parents = [];
			
			if(bytes.readMultiByte(4, cc) != "LWO2") return;
			if(bytes.readMultiByte(4, cc) != "TAGS") return;
			var tagsize:int = bytes.readInt();
			var str:String;
			var sf:Surface;
			
			while(bytes.bytesAvailable > 0) {
				str = readString();
				if(str == "LAYR") {
					bytes.position -= 6;
					break;
				}else{
					if(str.length > 0) {
						sf = new Surface();
						sf.rasterizer = defaultRasterizer;
						fileSurfaces.push(sf);
						surfacesByName[str] = fileSurfaces[fileSurfaces.length-1];
					}
				}
			}
			
			var geomStart:int = bytes.position;
			while(parsePreChunk());
			bytes.position = geomStart;
			
			if(!this.loadResources || textures.length == 0) {
				startParse();
			}else{
				var loadimage:Boolean=false;
				var k:int;
				addEventListener(EVT_IMAGES_LOADED, allImagesLoaded);
				addEventListener(EVT_IMAGE_LOADED, imageLoaded);
				
				var L:int = images.length;
				var L2:int;
				for(var i:int=0; i<L; i++) {
					loadimage = false;
					L2 = textures.length;
					for(k=0; k<L2; k++) {
						if(textures[k].id-1 == i) {
							loadimage=true;
							break;
						}
					}
					if(loadimage) loadBitmap(i);
				}
			}
		}
		
		private function startParse () :void {
			if(blocking) {
				while(parseChunk());
				finishParse();
			}else{
				if(piid != -1) clearInterval(piid);
				piid = setInterval(parseStep, loadParseInterval);
			}
		}
		
		private function imageLoaded (e:ImageLoadEvent) :void {
			var sf:Surface;
			var imageid:int = e.imgid+1;
			var L:int = textures.length;
			var txtr:Object;
			var cm:Object;
			
			for(var i:int=0; i<L; i++) {
				txtr = textures[i];
				if(txtr.id == imageid) {
					sf = txtr.sf;
					
					cm = {};
					cm.bitmap = bitmaps[e.bmpid].bmp;
					if(scanline) cm.scanline = true;
					if(zbuffer) cm.zbuffer = zbuffer;
					
					matmgr.setupMaterial( sf, cm ); 
					
					//sf.attributes = new BitmapAttributes(bitmaps[e.bmpid].bmp);
					//sf.rasterizer = defaultTextureRasterizer;
				}
			}
		}
		
		private function allImagesLoaded (e:Event) :void {
			removeEventListener(EVT_IMAGES_LOADED, allImagesLoaded);
			removeEventListener(EVT_IMAGE_LOADED, imageLoaded);
			startParse();
		}
		
		private function parseStep () :void {
			status = int((bytes.position/bytes.length) * 100);
			for(var i:int=0; i<chunksPerFrame; i++) {
				if(!parseChunk()) {
					finishParse();
					break;
				}
			}
		}
		
		private function parseChunk () :Boolean {
			
			if(bytes.position >= bytes.length-8) {
				return false;
			}else{
				
				var id:String = bytes.readMultiByte(4, cc);
				var size:int = bytes.readUnsignedInt();
				var name:String;
				var type:String;
				var L:int;
				var i:int;
				var p:int;
				var vtxs:Array;
				
				switch(id) {
					
					case "LAYR":
					
						bytes.position += 4;
						
						currPivot.x = bytes.readFloat();
						currPivot.y = bytes.readFloat();
						currPivot.z = bytes.readFloat();
						
						name = readString();
						
						if(size-18 > name.length) {
							var par:int = bytes.readUnsignedShort();
							parents.push([fileObjects.length, par]);
						}
						
						fileObjects.push(new SceneObject());
						
						objectsByName[name] = fileObjects[fileObjects.length-1];
						currObject = fileObjects[fileObjects.length-1];
						currObject.transform.setPosition(currPivot.x*scaleX, currPivot.y*scaleY, currPivot.z*scaleZ);
						break;
						
					case "PNTS":
						
						L = (size/3/4);
						var px:Number = currPivot.x;
						var py:Number = currPivot.y;
						var pz:Number = currPivot.z;
						for(i=0; i<L; i++) {
							currObject.addPoint((bytes.readFloat()-px)*scaleX, (bytes.readFloat()-py)*scaleY, (bytes.readFloat()-pz)*scaleZ);
						}
						break;
						
					case "POLS":
						
						type = bytes.readMultiByte(4, cc);
						
						if(type == "FACE" || type == "PTCH") {
							p = 0;
							
							while(p < size-4) {
								vtxs = [];
								L = bytes.readUnsignedShort();
								p += 2;
								for(i=0; i<L; i++) {
									vtxs.push( bytes.readUnsignedShort() );
									p += 2;
								}
								currObject.addPolygon(defaultSurface, (flipped ? vtxs.reverse() : vtxs));
							}
							
						}else{
							bytes.position += size-4;
						}
						break;
						
					case "PTAG":
					
						type = bytes.readMultiByte(4, cc);
						if( type == "SURF" ) {
							p = 0;
							while(p < size-4) {
								var poly_id:int = bytes.readUnsignedShort();
								var surf_id:int = bytes.readUnsignedShort();
								var sf:Surface = this.getSurfaceAt(surf_id);
								var poly:Face = currObject.polygonAt(poly_id);
								poly.surface = this.getSurfaceAt(surf_id);
								
								if(sf.attributes is BitmapAttributes) {
									
									var k:int;
									var tex:Object;
									
									for(k=0; k<textures.length; k++) {
										if(textures[k].sfid == surf_id) {
											tex = textures[k];
											break;
										}
									}
									
									if(tex != null) {
										vtxs = poly.vtxs;
										var L2:int = vtxs.length;
										if(L2 > 2) {
											var vmid:int;
											var u:Number;
											var v:Number;
											var vid:int;
											var vstart:int;
											var vmap:VertexMap = this.getMapByName(tex.vmap);
											
											if(vmap != null) {
												for(k=0; k<3; k++) {
													vmid = currObject.getPointId(vtxs[k]);
													if(vmid >= 0) {
														vstart = vmap.getStartId( vmid );
														if(vstart != -1) {
															vid = vmap.map[vstart];
															u = vmap.map[vstart+1];
															v = vmap.map[vstart+2];
															poly.addUvCoord(u, 1-v); 
														}
													}
												}
											}
											
											vmap = this.getMadByName(tex.vmap);
											
											if(vmap != null) {
												var vmadL:int = vmap.map.length-4;
												var vpt:int;
												var pt:Vertex;
												
												for(k=0; k<vmadL; k+=4) {
													if(vmap.map[k+1] == poly_id) {
														
														vpt = vmap.map[k];
														u = vmap.map[k+2];
														v = vmap.map[k+3];
														pt = currObject.pointAt(vpt);
														
														if(pt == poly.vtxs[0]) {
															poly.uvs[0] = new UVCoord(u, 1-v);
															sf.initFace(poly);
														}else if(pt == poly.vtxs[1]) {
															poly.uvs[1] = new UVCoord(u, 1-v);
															sf.initFace(poly);
														}else if(pt == poly.vtxs[2]) {
															poly.uvs[2] = new UVCoord(u, 1-v);
															sf.initFace(poly);
														}
													}
												}
											}
										}
									}
								}
								p += 4;
							}
						}else{
							bytes.position += size-4;
						}
						break;
						
					default:
						bytes.position += size;
						break;
				}
				
				return true;
			}
		}
		
		private function parsePreChunk () :Boolean {
			
			if(bytes.position >= bytes.length-8) {
				return false;
			}else{
				
				var id:String = bytes.readMultiByte(4, cc);
				var size:int = bytes.readUnsignedInt();
				var type:String;
				var name:String;
				var p:int;
				var dim:int;
				var L:int;
				var vm:VertexMap;
				
				switch(id) {
					
					case "CLIP":
						var imgid:int = bytes.readUnsignedInt();
						type = bytes.readMultiByte(4, cc);
						
						if(type == "STIL") {
							
							var imgsize:int = bytes.readShort();
							var path:String = readString();
							var disk:int = path.indexOf(":");
							
							if(disk != -1) {
								// Absolute image path - use image name only
								var sid:int = path.lastIndexOf("/");
								if(sid != -1) {
									images.push(path.substring(sid+1, path.length));
								}else{
									images.push(path.substring(disk+1, path.length));
								}
							}else{
								images.push(path);
							}
							
							bytes.position += size-(12+path.length);
							goEven();
							
						}else{
							bytes.position += size-6;
						}
						break;
						
					case "SURF":
						name = readString();
						var pName:String = readString();
						currSurface = getSurfaceByName(name);
						parseSurface();
						break;
						
					case "VMAP":
						type = bytes.readMultiByte(4, cc);
						if( type == "TXUV" ) {
							dim = bytes.readUnsignedShort();
							if( dim == 2 ) {
								name = readString();
								L = size - (name.length+8);
								vm = new VertexMap();
								
								fileVmaps.push(vm);
								vmapsByName[name] = fileVmaps[fileVmaps.length-1];
								
								p = 0;
								while(p < L) {
									vm.addUvCoord(bytes.readUnsignedShort(), bytes.readFloat(), bytes.readFloat());
									p += 10;
								}
							}
						}else{
							bytes.position += size-4;
						}
						break;
						
					case "VMAD":
						type = bytes.readMultiByte(4, cc);
						if( type == "TXUV" ) {
							dim = bytes.readUnsignedShort();
							if( dim == 2 ) {
								name = readString();
								L = size - (name.length+8);
								vm = new VertexMap();
								vm.dim = 3;
								
								fileVmads.push(vm);
								vmadsByName[name] = fileVmads[fileVmads.length-1];
								
								p = 0;
								while(p < L) {
									vm.map.push(bytes.readUnsignedShort(), bytes.readUnsignedShort(), bytes.readFloat(), bytes.readFloat());
									p += 12;
								}
							}
						}else{
							bytes.position += size-4;
						}
						break;
						
					default:
						bytes.position += size;
						break;
				}
				return true;
			}
		}
		
		private function parseSurface () :void {
			
			var id:String;
			var size:int;
			var rv:Boolean = true;
			
			var currMaterial:Object = {};
			
			do {
				if(bytes.position > bytes.length-8) break;
				
				id = bytes.readMultiByte(4, cc);
				size = bytes.readUnsignedShort();
				
				switch( id ) {
					
					case "SURF":
						rv = false;
						bytes.position -= 6;
						break;
						
					case "BLOK":
						if(bytes.readMultiByte(4, cc) == "IMAP") {
							
							var imapSize:int = bytes.readShort();
							bytes.position+=2;
							
							if(bytes.readMultiByte(4, cc) == "CHAN") {
								var L:int = bytes.readShort();
								
								if(bytes.readMultiByte(L, cc) == "COLR") {
									bytes.position += imapSize - (8+L);
									
									do {
										
										var tid:String = bytes.readMultiByte(4, cc);
										var tsize:int = bytes.readShort();
										
										if(tid == "IMAG") {
											var sfid:int;
											for(var k2:int=0; k2<fileSurfaces.length; k2++) {
												if(fileSurfaces[k2] == currSurface) {
													sfid = k2;
													break;
												}
											}
											currTexture = {id: bytes.readShort(), sf: currSurface, sfid: sfid};
											bytes.position += tsize-2;
										}else if(tid == "SURF") {
											bytes.position -= 6;
											break;
										}else if(tid == "VMAP") {
											var vm:String = bytes.readMultiByte(tsize, cc);
											
											if(currTexture != null) {
												currTexture.vmap = vm;
												textures.push(currTexture);
											}
										}else{
											bytes.position += tsize;
										}
										
									}while (bytes.position < bytes.length-8)
								}
								else{
									bytes.position += size-(14+L);
								}
							}
						}else{
							bytes.position += size-4;
						}
						break;
						
					case "LINE":
						bytes.position += 2;
						
						if(size == 2) {
							currMaterial.lineStyle = 0;
						}else{
							currMaterial.lineStyle = bytes.readFloat();
							bytes.position += size-6;
						}
						break;
						
					case "SIDE":
						if(bytes.readShort() == 3) currSurface.hideBackfaces = false;
						break;
						
					case "TRAN":
						currMaterial.alpha = 1-bytes.readFloat();
						bytes.position += 2;
						break;
						
					case "DIFF":
						currMaterial.diffuse = bytes.readFloat();
						currMaterial.lighting = true;
						currMaterial.lightGlobals = lightGlobals;
						bytes.position += 2;
						break;
						
					case "LUMI":
						currMaterial.luminosity = bytes.readFloat();
						currMaterial.lighting = true;
						currMaterial.lightGlobals = lightGlobals;
						bytes.position += 2;
						break;
						
					case "COLR":
						var r:int = bytes.readFloat()*255;
						var g:int = bytes.readFloat()*255;
						var b:int = bytes.readFloat()*255;
						if(r>255) r=255;
						if(g>255) g=255;
						if(b>255) b=255;
						currMaterial.color = r << 16 | g << 8 | b;
						bytes.position += 2;
						break;
						
					default:
						bytes.position += size;
						break;
				}
			}while (rv)
			
			if(scanline)
				currMaterial.scanline = scanline;
			
			if(zbuffer)
				currMaterial.zbuffer = zbuffer;
			
			matmgr.setupMaterial(currSurface, currMaterial);
			
		}
		
		public function getMadByName (name:String) :VertexMap		{	return vmadsByName[name]; }
		
		private function goEven () :void {
			if(bytes.position % 2 != 0)
				bytes.position++;
		}
		
		private function readString () :String {
			var c:int;
			var str:String = "";
			while(c = bytes.readByte()) str += String.fromCharCode(c);
			goEven();
			return str;
		}
		
		private function finishParse() :void {
			
			if(parents.length > 0) {
				var L:int = parents.length;
				for(var i:int=0; i<L; i++) {
					this.fileObjects[ parents[i][0] ].parent = this.fileObjects[ parents[i][1] ];
				}
			}
			
			if(!blocking) {
				clearInterval(piid);
				piid = -1;
			}
			
			dispatchEvent(new Event(Event.COMPLETE));
			
			bytes = null;
			tags = null;
			textures = null;
			currTexture = null;
			currPivot = null;
			fileVmads = null;
			vmadsByName = null;
			parents = null;
			clearMemory();
		}
	}
	
}