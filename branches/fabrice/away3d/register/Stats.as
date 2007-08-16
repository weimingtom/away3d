package away3d.register{	import flash.ui.ContextMenu;    import flash.ui.ContextMenuItem;    import flash.ui.ContextMenuBuiltInItems;    import flash.events.ContextMenuEvent;	import flash.display.Sprite;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.TextFieldAutoSize;	import flash.display.Stage;	import flash.geom.Matrix;	import flash.geom.Rectangle;	import flash.geom.Point;	import flash.geom.ColorTransform;	import flash.net.navigateToURL;    import flash.net.URLRequest;	import flash.events.MouseEvent;    import flash.events.Event;    import flash.filters.DropShadowFilter;	import flash.display.Loader;	import flash.display.Graphics;	import flash.system.System;	import flash.utils.*;	import away3d.register.MCClassManager;	import away3d.register.RenderEvent;		public class Stats extends Sprite	{		public static var instance:Stats=new Stats();		private static var oStats:Object=new Object  ;		private static var totalFaces:int=0;		private static var meshes:int=0;		private static var aTypes:Array = new Array();		private static var contextmenu:ContextMenu;		public static var scopeMenu:Sprite = null;		public static var scopeMenuRegion:Sprite = null;		public static var displayMenu:Sprite = null;		public static var stage:Stage;		private static var lastrender:int;		private static var fpsLabel:TextField;		private static var perfLabel:TextField;		private static var ramLabel:TextField;		private static var swfframerateLabel:TextField;		private static var avfpsLabel:TextField;		private static var peakLabel:TextField;		private static var faceLabel:TextField;		private static var faceRenderLabel:TextField;		private static var meshLabel:TextField;		private static var fpstotal:int = 0;		private static var refreshes:int = 0;		private static var bestfps:int = 0;		private static var lowestfps:int = 999;		private static var bar:Sprite;		private static var barwidth:int = 0;		public static var closebtn:Sprite;		public static var cambtn:Sprite;		private static var maxminbtn:Sprite;		private static var barscale:int = 0;		private static var stageframerate:Number;		private static var showCam:Boolean;		private static var camLabel:TextField;		private static var camMenu:Sprite;		private static var camProp:Array;		//		private static const VERSION:String = "1";		private static const REVISION:String = "0.0.1";		private static const APPLICATION_NAME:String = "Away3D.com";				function Stats()		{						}				public function generateMenu(scope:Sprite, stage:Stage, stageframerate:Number = 0):void		{			Stats.scopeMenu = scope;			Stats.contextmenu = new ContextMenu();			Stats.stageframerate = (stageframerate == 0)? 30 : stageframerate;			Stats.stage = stage;			var menutitle:String = Stats.APPLICATION_NAME+"\tv" + Stats.VERSION+"."+Stats.REVISION;			var menu:ContextMenuItem = new ContextMenuItem(menutitle, true, true, true);			var menu2:ContextMenuItem = new ContextMenuItem("Away3D Project stats", true, true, true);			var menu3:ContextMenuItem = new ContextMenuItem(" ");			Stats.contextmenu.customItems = [menu2, menu, menu3];			menu.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, Stats.instance.visiteWebsite);			menu2.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, Stats.instance.displayStats);			Stats.scopeMenu.contextMenu = Stats.contextmenu;			         }		//Redirect to site		public function visiteWebsite(e:ContextMenuEvent):void 		{			var url:String = "http://www.away3d.com";            var request:URLRequest = new URLRequest(url);            try {              				navigateToURL(request);            } catch (e:Error) {            }		}		//Displays stats        public function displayStats(e:ContextMenuEvent):void		{			 if(!Stats.displayMenu){				Stats.instance.generateSprite();				Stats.instance.addEventMouse();				Stats.instance.applyShadow();			 }        }		//Mouse Events		private function addEventMouse():void		{  			Stats.scopeMenu.addEventListener(MouseEvent.MOUSE_DOWN, Stats.instance.onCheckMouse);		}				private function closeStats():void		{ 			MCClassManager.getMCClass("BasicRenderer").removeEventListener("RENDER", Stats.instance.updateFPS);			Stats.scopeMenu.removeEventListener(MouseEvent.MOUSE_DOWN, Stats.instance.onCheckMouse);			Stats.scopeMenu.removeChild(Stats.displayMenu);			Stats.displayMenu = null;		}				private function onCheckMouse(me:MouseEvent):void		{ 			var x:Number = Stats.displayMenu.mouseX;			var y:Number = Stats.displayMenu.mouseY;			var pt:Point = new Point(x,y);			var rectcam:Rectangle = new Rectangle(206,3,18,18);			var rectclose:Rectangle = new Rectangle(227,3,18,18);			 			if(rectcam.containsPoint(pt)){				Stats.showCam = (!Stats.showCam)? true : false;				if(Stats.showCam){					Stats.instance.showFieldCam();				} else{					Stats.instance.hideFieldCam();				}			} else if(rectclose.containsPoint(pt)){				Stats.instance.closeStats();			} else{				Stats.displayMenu.startDrag();				Stats.scopeMenu.addEventListener(MouseEvent.MOUSE_UP, Stats.instance.mouseReleased);			}		}		private function mouseReleased(event:MouseEvent):void {			Stats.displayMenu.stopDrag();			Stats.scopeMenu.removeEventListener(MouseEvent.MOUSE_UP, Stats.instance.mouseReleased);		}				//drawing the stats container		private function generateSprite():void		{  		  			Stats.displayMenu = new Sprite();			 						var myMatrix:Matrix = new Matrix();    		myMatrix.rotate(90 * Math.PI/180); 			Stats.displayMenu.graphics.beginGradientFill("linear", [0x333366, 0xCCCCCC], [1,1], [0,255], myMatrix, "pad", "rgb", 0);			Stats.displayMenu.graphics.drawRect(0, 0, 250, 86);						Stats.displayMenu.graphics.beginFill(0x565758);			Stats.displayMenu.graphics.drawRect(3, 3, 244, 20);			 			Stats.scopeMenu.addChild(Stats.displayMenu);			 			Stats.displayMenu.x -= Stats.displayMenu.width*.5;			Stats.displayMenu.y -= Stats.displayMenu.height*.5;						// generate closebtn			Stats.closebtn = new Sprite();			Stats.closebtn.graphics.beginFill(0x333333);			Stats.closebtn.graphics.drawRect(0, 0, 18, 18);			var cross = new Sprite();			cross.graphics.beginFill(0x666666);			cross.graphics.drawRect(2, 7, 14, 4);			cross.graphics.endFill();			cross.graphics.beginFill(0x666666);			cross.graphics.drawRect(7, 2, 4, 14);			cross.graphics.endFill();			cross.rotation = 45;			cross.x+=9;			cross.y-=4;			Stats.closebtn.addChild(cross);			Stats.displayMenu.addChild(Stats.closebtn);			Stats.closebtn.x = 226;			Stats.closebtn.y = 3;						// generate cam btn			Stats.cambtn = new Sprite();			var cam:Graphics = Stats.cambtn.graphics;			cam.beginFill(0x333333);			cam.drawRect(0, 0, 18, 18);			cam.endFill();			cam.beginFill(0xCCCCCC);			cam.drawRect(2, 6, 8, 6);			cam.moveTo(9,9);			cam.lineTo(16,2);			cam.lineTo(16,16);			cam.lineTo(9,9);			cam.endFill();			 			Stats.displayMenu.addChild(Stats.cambtn);			Stats.cambtn.x = 205;			Stats.cambtn.y = 3;						// generate bar			Stats.displayMenu.graphics.beginGradientFill("linear", [0xFF0000, 0x00FF00], [1,1], [0,255], myMatrix, "pad", "rgb", 0);			Stats.displayMenu.graphics.drawRect(3, 22, 244, 4);			Stats.bar = new Sprite();			Stats.bar.graphics.beginFill(0xFFCC00);			Stats.bar.graphics.drawRect(0, 0, 244, 4);			Stats.displayMenu.addChild(Stats.bar);			Stats.bar.x = 3;			Stats.bar.y = 22;			Stats.barwidth = 244;			Stats.barscale = int(Stats.barwidth/Stats.stageframerate);			// load picto			Stats.instance.loadPicto();						// generate textfields			// title			var titleField:TextField = new TextField();			titleField.defaultTextFormat = new TextFormat("Verdana", 10, 0xFFFFFF, true, null,null,null,null,"left");			titleField.text = "AWAY3D PROJECT STATS";			titleField.height = 20;			titleField.width = 200;			titleField.x = 22;			titleField.y = 3;			Stats.displayMenu.addChild(titleField);						// fps			var fpst:TextField = new TextField();			fpst.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			fpst.text = "FPS:";			Stats.fpsLabel = new TextField();			Stats.fpsLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(fpst);			Stats.displayMenu.addChild(Stats.fpsLabel);			fpst.x = 3;			fpst.y = Stats.fpsLabel.y = 30;			fpst.autoSize = "left";			Stats.fpsLabel.x = fpst.x+fpst.width-2;						//average perf			var afpst:TextField = new TextField();			afpst.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			afpst.text = "AFPS:";			Stats.avfpsLabel = new TextField();			Stats.avfpsLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(afpst);			Stats.displayMenu.addChild(Stats.avfpsLabel);			afpst.x = 52;			afpst.y = Stats.avfpsLabel.y = Stats.fpsLabel.y;			afpst.autoSize = "left";			Stats.avfpsLabel.x = afpst.x+afpst.width-2;						//peaks			var peakfps:TextField = new TextField();			peakfps.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			peakfps.text = "Peak:";			Stats.peakLabel = new TextField();			Stats.peakLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(peakfps);			Stats.displayMenu.addChild(Stats.peakLabel);			peakfps.x = 107;			peakfps.y = Stats.peakLabel.y = Stats.avfpsLabel.y;			peakfps.autoSize = "left";			Stats.peakLabel.x = peakfps.x+peakfps.width-2;						//MS			var pfps:TextField = new TextField();			pfps.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			pfps.text = "MS:";			Stats.perfLabel = new TextField();			Stats.perfLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(pfps);			Stats.displayMenu.addChild(Stats.perfLabel);			pfps.x = 177;			pfps.y = Stats.perfLabel.y = Stats.fpsLabel.y;			pfps.autoSize = "left";			Stats.perfLabel.x = pfps.x+pfps.width-2;			 			//ram usage			var ram:TextField = new TextField();			ram.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			ram.text = "RAM:";			Stats.ramLabel = new TextField();			Stats.ramLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(ram);			Stats.displayMenu.addChild(Stats.ramLabel);			ram.x = 3;			ram.y = Stats.ramLabel.y = 46;			ram.autoSize = "left";			Stats.ramLabel.x = ram.x+ram.width-2;						//meshes count			var meshc:TextField = new TextField();			meshc.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			meshc.text = "MESHES:";			Stats.meshLabel = new TextField();			Stats.meshLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(meshc);			Stats.displayMenu.addChild(Stats.meshLabel);			meshc.x = 70;			meshc.y = Stats.meshLabel.y = Stats.ramLabel.y;			meshc.autoSize = "left";			Stats.meshLabel.x = meshc.x+meshc.width-2;						//faces			var faces:TextField = new TextField();			faces.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			faces.text = "FACES:";			Stats.faceLabel = new TextField();			Stats.faceLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(faces);			Stats.displayMenu.addChild(Stats.faceLabel);			faces.x = 3;			faces.y = Stats.faceLabel.y = 62;			faces.autoSize = "left";			Stats.faceLabel.x = faces.x+faces.width-2;						//shown faces			var facesrender:TextField = new TextField();			facesrender.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			facesrender.text = "RFACES:";			Stats.faceRenderLabel = new TextField();			Stats.faceRenderLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(facesrender);			Stats.displayMenu.addChild(Stats.faceRenderLabel);			facesrender.x = 95;			facesrender.y = Stats.faceRenderLabel.y = Stats.faceLabel.y;			facesrender.autoSize = "left";			Stats.faceRenderLabel.x = facesrender.x+facesrender.width-2;						//swf framerate			var rate:TextField = new TextField();			rate.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000, true);			rate.text = "SWF FR:";			Stats.swfframerateLabel = new TextField();			Stats.swfframerateLabel.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			Stats.displayMenu.addChild(rate);			Stats.displayMenu.addChild(Stats.swfframerateLabel);			rate.x = 170;			rate.y = Stats.swfframerateLabel.y = Stats.faceRenderLabel.y;			rate.autoSize = "left";			Stats.swfframerateLabel.x = rate.x+rate.width-2;									/* for later			//geometrie details			var statsField:TextField = new TextField();			statsField.x = 10;			statsField.y = 75;			statsField.defaultTextFormat = new TextFormat("Verdana", 10, 0x000000);			statsField.autoSize = "left";			statsField.text = stats;			statsField.height = 15;			statsField.width = 200;			Stats.displayMenu.addChild(statsField);			*/						// ok lets fill some info here			MCClassManager.getMCClass("BasicRenderer").addEventListener("RENDER", Stats.instance.updateFPS); 			 		}				private function updateFPS(e:RenderEvent):void		{			var now:int = getTimer();			var perf:int = now - Stats.lastrender;			Stats.lastrender = now;						if (perf < 1000) {				var fps:int = int(1000 / (perf+0.001));				Stats.fpstotal += fps;				Stats.refreshes ++;				var average:int = fpstotal/refreshes;				Stats.bestfps = (fps>Stats.bestfps)? fps : Stats.bestfps;				Stats.lowestfps = (fps<Stats.lowestfps)? fps : Stats.lowestfps;				var w:int = Stats.barscale*fps;				Stats.bar.width = (w<=Stats.barwidth)? w : Stats.barwidth;							}						//color			var procent:int = (Stats.bar.width/Stats.barwidth)*100;			var r:int = (255/100)*procent;			var g:int = 255-((255/100)*procent);			var b:int = 0;			Stats.bar.transform.colorTransform = new ColorTransform(r, g, b, 1, r, g, b, 0);						if(Stats.showCam){				Stats.camLabel.htmlText = "";				for(var i:int;i<Stats.camProp.length;i++){					var ret:String = (i%2 == 0)? "<br>" : ", ";					Stats.camLabel.htmlText += "<b>"+Stats.camProp[i]+":</b>  "+e.oData.camera[Stats.camProp[i]]+ret;				}			} else{				Stats.avfpsLabel.text = ""+average;				Stats.ramLabel.text = ""+int(System.totalMemory/1024/1024)+"MB";				Stats.peakLabel.text = Stats.lowestfps+"/"+Stats.bestfps;				Stats.fpsLabel.text = "" + fps; 				Stats.perfLabel.text = "" + perf;				Stats.faceLabel.text = ""+Stats.totalFaces;				Stats.faceRenderLabel.text = ""+e.oData.totalfaces;				Stats.meshLabel.text = ""+Stats.meshes;				Stats.swfframerateLabel.text = ""+Stats.stageframerate;			}					}		//cam info		private function showFieldCam():void		{			if(Stats.camMenu == null){				Stats.instance.createCamMenu();			} else{				Stats.displayMenu.addChild(Stats.camMenu);				Stats.camMenu.y = 26;			}		}				private function hideFieldCam():void		{				if(Stats.camMenu != null){				Stats.displayMenu.removeChild(Stats.camMenu);			}		}				private function createCamMenu():void		{				Stats.camMenu = new Sprite();			var myMatrix:Matrix = new Matrix();    		myMatrix.rotate(90 * Math.PI/180);			Stats.camMenu.graphics.beginGradientFill("linear", [0x333366, 0xCCCCCC], [1,1], [0,255], myMatrix, "pad", "rgb", 0);			Stats.camMenu.graphics.drawRect(0, 0, 250, 165);			Stats.displayMenu.addChild(Stats.camMenu);			Stats.camMenu.y = 26;			Stats.camLabel = new TextField();			Stats.camLabel.height = 140;			Stats.camLabel.width = 240;			Stats.camLabel.multiline = true;			var tf:TextFormat = new TextFormat("Verdana", 10, 0x000000);			tf.leading = 2;			Stats.camLabel.defaultTextFormat = tf;			Stats.camLabel.wordWrap = true;			Stats.camMenu.addChild(Stats.camLabel);			Stats.camLabel.x = Stats.camLabel.y = 3;			Stats.camProp = ["x","y","z","zoom","focus","distance","panangle","tiltangle","targetpanangle","targettiltangle","mintiltangle","maxtiltangle","steps","target"];		}		//		private function loadPicto():void		{			var ldr:Loader = new Loader();			ldr.load(new URLRequest("http://www.away3d.com/awaygraphics/awaylogo_icon.swf"));			Stats.displayMenu.addChild(ldr);			ldr.x = ldr.y = 4;		}				private function applyShadow():void		{			var shadowfilter:DropShadowFilter = new DropShadowFilter(10, 45, 0x333333, .7, 5, 5, 1, 2, false, false, false);			Stats.displayMenu.filters = [shadowfilter];		}		// registration faces and types		public function register(type:String=null,facecount:int=0,url:String=""):void		{			if (type != null && facecount != 0) {				Stats.aTypes.push({type:type,facecount:facecount,url:(url == "")? "internal" : url});				Stats.totalFaces += facecount;				Stats.meshes += 1;			}		}		public function get stats():String		{ 			var stats:String= "- TOTAL FACES: "+Stats.totalFaces+"\n";			stats += "- TOTAL MESHES: "+Stats.meshes+"\n\n";			stats += "GEOMETRIE: "+"\n";			for (var i:int = 0;i<Stats.aTypes.length;i++){				stats += "   - "+Stats.aTypes[i].type+" , faces: "+Stats.aTypes[i].facecount+", url: "+Stats.aTypes[i].url+"\n";			}			stats += "\nAWAY3D VERSION "+Stats.VERSION+"."+Stats.REVISION;			return stats;		}	}}