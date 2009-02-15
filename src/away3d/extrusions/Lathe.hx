package away3d.extrusions;

import flash.geom.Point;
import away3d.core.utils.ValueObject;
import away3d.core.base.Face;
import away3d.core.base.Mesh;
import away3d.core.utils.Init;
import away3d.core.math.Number3D;
import away3d.core.base.UV;
import away3d.core.base.Vertex;


class Lathe extends Mesh  {
	
	private var varr:Array<Dynamic>;
	private var varr2:Array<Dynamic>;
	private var uvarr:Array<Dynamic>;
	

	public function new(aPoints:Array<Dynamic>, ?init:Dynamic=null) {
		this.varr = new Array<Dynamic>();
		this.varr2 = new Array<Dynamic>();
		this.uvarr = new Array<Dynamic>();
		
		
		if (init.material != null) {
			init.materials = {defaultmaterial:init.material};
		}
		if (init.material == null && init.materials != null) {
			init.material = init.materials.defaultmaterial;
		}
		super(init);
		var axis:String = ini.getString("axis", "y");
		var rotations:Float = ini.getNumber("rotations", 1, {min:0.01});
		var subdivision:Int = ini.getInt("subdivision", 2, {min:2});
		var offsetradius:Int = Std.int(ini.getNumber("offsetradius", 0));
		var scaling:Float = ini.getNumber("scaling", 1);
		var omat:Dynamic = ini.getObject("materials", null);
		var omit:String = ini.getString("omit", "");
		var tweek:Dynamic = ini.getObject("tweek", null);
		var thickness:Float = ini.getNumber("thickness", 0, {min:0});
		var coverall:Bool = ini.getBoolean("coverall", true);
		var recenter:Bool = ini.getBoolean("recenter", false);
		var flip:Bool = ini.getBoolean("flip", false);
		if (scaling != 1) {
			var i:Int = 0;
			while (i < aPoints.length) {
				aPoints[i].x *= scaling;
				aPoints[i].y *= scaling;
				aPoints[i].z *= scaling;
				
				// update loop variables
				i++;
			}

		}
		if (aPoints.length > 1) {
			tweek = (tweek == null) ? {x:0, y:0, z:0, radius:0, rotation:0} : tweek;
			if (thickness != 0) {
				var prop1:String;
				var prop2:String;
				var prop3:String;
				switch (axis) {
					case "x" :
						prop1 = "x";
						prop2 = "z";
						prop3 = "y";
					case "y" :
						prop1 = "y";
						prop2 = "x";
						prop3 = "z";
					case "z" :
						prop1 = "z";
						prop2 = "y";
						prop3 = "x";
					

				}
				var Lines:Array<Dynamic> = buildThicknessPoints(aPoints, thickness, prop1, prop2);
				generateWithThickness(aPoints, Lines, axis, prop1, prop2, prop3, offsetradius, rotations, subdivision, tweek, coverall, omat, omit, flip);
			} else {
				generate(aPoints, axis, offsetradius, rotations, subdivision, tweek, coverall, flip);
			}
		} else {
			trace("Lathe error: at least 2 number3D are required!");
		}
		varr = null;
		varr2 = null;
		uvarr = null;
		if (recenter) {
			applyPosition((this.minX + this.maxX) * .5, (this.minY + this.maxY) * .5, (this.minZ + this.maxZ) * .5);
		} else {
			x = aPoints[0].x;
			y = aPoints[0].y;
			z = aPoints[0].z;
		}
		type = "Lathe";
		url = "Extrude";
	}

	private function generateWithThickness(points:Array<Dynamic>, Lines:Array<Dynamic>, axis:String, prop1:String, prop2:String, prop3:String, offsetradius:Float, rotations:Float, subdivision:Float, tweek:Dynamic, coverall:Bool, ?oMat:Dynamic=null, ?omit:String="", ?flip:Bool=false):Void {
		
		var i:Int;
		var j:Int;
		var aListsides:Array<Dynamic> = ["top", "bottom", "right", "left", "front", "back"];
		var oRenderside:Dynamic = {};
		i = 0;
		while (i < aListsides.length) {
			Reflect.setField(oRenderside, aListsides[i], (omit.indexOf(aListsides[i]) == -1));
			
			// update loop variables
			i++;
		}

		var oPoints:Dynamic;
		var vector:Dynamic;
		var vector2:Dynamic;
		var vector3:Dynamic;
		var vector4:Dynamic;
		var aPointlist1:Array<Dynamic> = new Array<Dynamic>();
		var aPointlist2:Array<Dynamic> = new Array<Dynamic>();
		i = 0;
		while (i < Lines.length) {
			oPoints = Lines[i];
			vector = {};
			vector2 = {};
			if (i == 0) {
				Reflect.setField(vector, prop1, oPoints.pt2.x.toFixed(4));
				Reflect.setField(vector, prop2, oPoints.pt2.y.toFixed(4));
				Reflect.setField(vector, prop3, points[0][prop3]);
				aPointlist1.push(new Number3D());
				Reflect.setField(vector2, prop1, oPoints.pt1.x.toFixed(4));
				Reflect.setField(vector2, prop2, oPoints.pt1.y.toFixed(4));
				Reflect.setField(vector2, prop3, points[0][prop3]);
				aPointlist2.push(new Number3D());
				if (Lines.length == 1) {
					vector3 = {};
					vector4 = {};
					Reflect.setField(vector3, prop1, oPoints.pt4.x.toFixed(4));
					Reflect.setField(vector3, prop2, oPoints.pt4.y.toFixed(4));
					Reflect.setField(vector3, prop3, points[0][prop3]);
					aPointlist1.push(new Number3D());
					Reflect.setField(vector4, prop1, oPoints.pt3.x.toFixed(4));
					Reflect.setField(vector4, prop2, oPoints.pt3.y.toFixed(4));
					Reflect.setField(vector4, prop3, points[0][prop3]);
					aPointlist2.push(new Number3D());
				}
			} else if (i == Lines.length - 1) {
				Reflect.setField(vector, prop1, oPoints.pt2.x);
				Reflect.setField(vector, prop2, oPoints.pt2.y);
				Reflect.setField(vector, prop3, points[i][prop3]);
				aPointlist1.push(new Number3D());
				Reflect.setField(vector2, prop1, oPoints.pt1.x);
				Reflect.setField(vector2, prop2, oPoints.pt1.y);
				Reflect.setField(vector2, prop3, points[i][prop3]);
				aPointlist2.push(new Number3D());
				vector3 = {};
				vector4 = {};
				Reflect.setField(vector3, prop1, oPoints.pt4.x);
				Reflect.setField(vector3, prop2, oPoints.pt4.y);
				Reflect.setField(vector3, prop3, points[i][prop3]);
				aPointlist1.push(new Number3D());
				Reflect.setField(vector4, prop1, oPoints.pt3.x);
				Reflect.setField(vector4, prop2, oPoints.pt3.y);
				Reflect.setField(vector4, prop3, points[i][prop3]);
				aPointlist2.push(new Number3D());
			} else {
				Reflect.setField(vector, prop1, oPoints.pt2.x);
				Reflect.setField(vector, prop2, oPoints.pt2.y);
				Reflect.setField(vector, prop3, points[i][prop3]);
				aPointlist1.push(new Number3D());
				Reflect.setField(vector2, prop1, oPoints.pt1.x);
				Reflect.setField(vector2, prop2, oPoints.pt1.y);
				Reflect.setField(vector2, prop3, points[i][prop3]);
				aPointlist2.push(new Number3D());
			}
			
			// update loop variables
			i++;
		}

		var mf:Dynamic;
		var mb:Dynamic;
		var mt:Dynamic;
		var mbo:Dynamic;
		var mr:Dynamic;
		var ml:Dynamic;
		if (oMat != null) {
			mf = (oMat.front != null) ? oMat.front : null;
			mb = (oMat.back != null) ? oMat.back : null;
			mt = (oMat.top != null) ? oMat.top : null;
			mbo = (oMat.bottom != null) ? oMat.bottom : null;
			mr = (oMat.right != null) ? oMat.right : null;
			ml = (oMat.left != null) ? oMat.left : null;
		}
		varr = new Array<Dynamic>();
		generate(aPointlist1, axis, offsetradius, rotations, subdivision, tweek, coverall, false, mf, oRenderside.front, flip);
		varr2 = new Array<Dynamic>();
		varr2 = varr2.concat(varr);
		varr = new Array<Dynamic>();
		generate(aPointlist2, axis, offsetradius, rotations, subdivision, tweek, coverall, true, mb, oRenderside.back, flip);
		if (rotations != 1) {
			closeSides(points.length, subdivision, rotations, coverall, mr, ml, oRenderside, flip);
		}
		closeTopBottom(points.length, subdivision, rotations, coverall, mt, mbo, oRenderside, flip);
	}

	private function closeTopBottom(pointslength:Int, subdivision:Float, rotations:Float, coverall:Bool, matTop:Dynamic, matBottom:Dynamic, oRenderside:Dynamic, flip:Bool):Void {
		//add top and bottom
		
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		var facea:Vertex;
		var faceb:Vertex;
		var facec:Vertex;
		var faced:Vertex;
		var index:Int = 0;
		var i:Int;
		var j:Int;
		var a:Float;
		var b:Float;
		var total:Int = varr.length - (pointslength + 1);
		var inc:Int = pointslength;
		i = 0;
		while (i < total) {
			if (i != 0) {
				if (coverall) {
					a = i / total;
					b = (i + inc) / total;
					uva = new UV();
					uvb = new UV();
					uvc = new UV();
					uvd = new UV();
				} else {
					uva = new UV();
					//topleft
					uvb = new UV();
					//topright
					uvc = new UV();
					//downright
					uvd = new UV();
				}
				if (oRenderside.top) {
					facea = new Vertex();
					faceb = new Vertex();
					facec = new Vertex();
					faced = new Vertex();
					if (flip) {
						addFace(new Face());
						addFace(new Face());
					} else {
						addFace(new Face());
						addFace(new Face());
					}
				}
				if (oRenderside.bottom) {
					j = i + inc - 1;
					facea = new Vertex();
					faceb = new Vertex();
					facec = new Vertex();
					faced = new Vertex();
					if (flip) {
						addFace(new Face());
						addFace(new Face());
					} else {
						addFace(new Face());
						addFace(new Face());
					}
				}
			}
			index += pointslength;
			
			// update loop variables
			i += inc;
		}

	}

	private function closeSides(pointcount:Int, subdivision:Float, rotations:Float, coverall:Bool, matRight:Dynamic, matLeft:Dynamic, oRenderside:Dynamic, flip:Bool):Void {
		
		var uva:UV;
		var uvb:UV;
		var uvc:UV;
		var uvd:UV;
		var facea:Vertex;
		var faceb:Vertex;
		var facec:Vertex;
		var faced:Vertex;
		var offset:Float = varr.length - pointcount;
		var i:Int;
		var j:Int;
		var a:Float;
		var b:Float;
		var iter:Int = pointcount - 1;
		var step:Float = 1 / iter;
		i = 0;
		while (i < iter) {
			if (coverall) {
				a = i / iter;
				b = a + step;
				uva = new UV();
				uvb = new UV();
				uvc = new UV();
				uvd = new UV();
			} else {
				uva = new UV();
				uvb = new UV();
				uvc = new UV();
				uvd = new UV();
			}
			if (oRenderside.left) {
				facea = new Vertex();
				faceb = new Vertex();
				facec = new Vertex();
				faced = new Vertex();
				if (flip) {
					addFace(new Face());
					addFace(new Face());
				} else {
					addFace(new Face());
					addFace(new Face());
				}
			}
			if (oRenderside.right) {
				j = Std.int(offset + i);
				facea = new Vertex();
				faceb = new Vertex();
				facec = new Vertex();
				faced = new Vertex();
				if (flip) {
					addFace(new Face());
					addFace(new Face());
				} else {
					addFace(new Face());
					addFace(new Face());
				}
			}
			
			// update loop variables
			i++;
		}

	}

	private function generate(aPoints:Array<Dynamic>, axis:String, offsetradius:Float, rotations:Float, subdivision:Float, tweek:Dynamic, coverall:Bool, ?inside:Bool=false, ?mat:Dynamic=null, ?render:Bool=true, ?flip:Bool=false):Void {
		
		if (Math.isNaN(tweek.x) || !tweek.x) {
			tweek.x = 0;
		}
		if (Math.isNaN(tweek.y) || !tweek.y) {
			tweek.y = 0;
		}
		if (Math.isNaN(tweek.z) || !tweek.z) {
			tweek.z = 0;
		}
		if (Math.isNaN(tweek.radius) || !tweek.radius) {
			tweek.radius = 0;
		}
		var angle:Float = 0;
		var step:Float = 360 / subdivision;
		var j:Int;
		var tweekX:Float = 0;
		var tweekY:Float = 0;
		var tweekZ:Float = 0;
		var tweekradius:Float = 0;
		var tweekrotation:Float = 0;
		var tmpPoints:Array<Dynamic>;
		var aRads:Array<Dynamic> = new Array<Dynamic>();
		var nuv1:Float;
		var nuv2:Float;
		var i:Int = 0;
		while (i < aPoints.length) {
			varr.push(new Vertex());
			uvarr.push(new UV());
			
			// update loop variables
			i++;
		}

		//Vertex generation
		offsetradius = -offsetradius;
		var factor:Float = 0;
		i = 0;
		while (i <= subdivision * rotations) {
			tmpPoints = new Array<Dynamic>();
			tmpPoints = aPoints.concat();
			j = 0;
			while (j < tmpPoints.length) {
				factor = ((rotations - 1) / (varr.length + 1));
				if (tweek.x != 0) {
					tweekX += (tweek.x * factor) / rotations;
				}
				if (tweek.y != 0) {
					tweekY += (tweek.y * factor) / rotations;
				}
				if (tweek.z != 0) {
					tweekZ += (tweek.z * factor) / rotations;
				}
				if (tweek.radius != 0) {
					tweekradius += (tweek.radius / (varr.length + 1));
				}
				if (tweek.rotation != 0) {
					tweekrotation += 360 / (tweek.rotation * subdivision);
				}
				if (axis == "x") {
					if (i == 0) {
						aRads[j] = offsetradius - Math.abs(tmpPoints[j].z);
					}
					tmpPoints[j].z = Math.cos(-angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					tmpPoints[j].y = Math.sin(angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					if (i == 0) {
						varr[j].z += tmpPoints[j].z;
						varr[j].y += tmpPoints[j].y;
					}
				} else if (axis == "y") {
					if (i == 0) {
						aRads[j] = offsetradius - Math.abs(tmpPoints[j].x);
					}
					tmpPoints[j].x = Math.cos(-angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					tmpPoints[j].z = Math.sin(angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					if (i == 0) {
						varr[j].x = tmpPoints[j].x;
						varr[j].z = tmpPoints[j].z;
					}
				} else {
					if (i == 0) {
						aRads[j] = offsetradius - Math.abs(tmpPoints[j].y);
					}
					tmpPoints[j].x = Math.cos(-angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					tmpPoints[j].y = Math.sin(angle / 180 * Math.PI) * (aRads[j] + tweekradius);
					if (i == 0) {
						varr[j].x = tmpPoints[j].x;
						varr[j].y = tmpPoints[j].y;
					}
				}
				tmpPoints[j].x += tweekX;
				tmpPoints[j].y += tweekY;
				tmpPoints[j].z += tweekZ;
				varr.push(new Vertex());
				if (coverall) {
					nuv1 = angle / (360 * rotations);
				} else {
					nuv1 = (i % 2 == 0) ? 0 : 1;
				}
				nuv2 = 1 - (j / (tmpPoints.length - 1));
				uvarr.push(new UV());
				
				// update loop variables
				j++;
			}

			angle += step;
			
			// update loop variables
			i++;
		}

		if (render) {
			var index:Int;
			var inc:Int = aPoints.length;
			var loop:Int = varr.length - aPoints.length;
			i = 0;
			while (i < loop) {
				index = 0;
				j = 1;
				while (j < aPoints.length) {
					if (i > 0) {
						var uva:UV = uvarr[i + (index + 1)];
						var uvb:UV = uvarr[i + index];
						var uvc:UV = uvarr[i + index + aPoints.length];
						var uvd:UV = uvarr[i + index + aPoints.length + 1];
						var facea:Vertex = new Vertex();
						var faceb:Vertex = new Vertex();
						var facec:Vertex = new Vertex();
						var faced:Vertex = new Vertex();
						if (flip) {
							if (inside) {
								addFace(new Face());
								addFace(new Face());
							} else {
								addFace(new Face());
								addFace(new Face());
							}
						} else {
							if (inside) {
								addFace(new Face());
								addFace(new Face());
							} else {
								addFace(new Face());
								addFace(new Face());
							}
						}
					}
					index++;
					
					// update loop variables
					j++;
				}

				
				// update loop variables
				i += inc;
			}

		}
	}

	//
	private function buildThicknessPoints(aPoints:Array<Dynamic>, thickness:Float, prop1:String, prop2:String):Array<Dynamic> {
		
		var Anchors:Array<Dynamic> = new Array<Dynamic>();
		var Lines:Array<Dynamic> = new Array<Dynamic>();
		var i:Int;
		i = 0;
		while (i < aPoints.length - 1) {
			if (aPoints[i][prop1] == 0 && aPoints[i][prop2] == 0) {
				aPoints[i][prop1] = .0001;
			}
			if (aPoints[i + 1][prop2] != null && aPoints[i][prop2] == aPoints[i + 1][prop2]) {
				aPoints[i + 1][prop2] += .0001;
			}
			if (aPoints[i][prop1] != null && aPoints[i][prop1] == aPoints[i + 1][prop1]) {
				aPoints[i + 1][prop1] += .0001;
			}
			Anchors.push(defineAnchors(aPoints[i], aPoints[i + 1], thickness, prop1, prop2));
			
			// update loop variables
			i++;
		}

		var totallength:Int = Anchors.length;
		var oPointResult:Dynamic;
		if (totallength > 1) {
			i = 0;
			while (i < totallength) {
				if (i < totallength) {
					oPointResult = defineLines(i, totallength, Anchors[i], Anchors[i + 1], Lines);
				} else {
					oPointResult = defineLines(i, totallength, Anchors[i], Anchors[i - 1], Lines);
				}
				if (oPointResult != null) {
					Lines.push(oPointResult);
				}
				
				// update loop variables
				i++;
			}

		} else {
			Lines = [{pt1:Anchors[0].pt1, pt2:Anchors[0].pt2, pt3:Anchors[0].pt3, pt4:Anchors[0].pt4}];
		}
		return Lines;
	}

	private function defineLines(index:Int, maxindex:Int, oPoint1:Dynamic, ?oPoint2:Dynamic=null, ?Lines:Array<Dynamic>=null):Dynamic {
		
		var tmppt:Dynamic = Lines[index - 1];
		if (oPoint2 == null) {
			return {pt1:tmppt.pt3, pt2:tmppt.pt4, pt3:oPoint1.pt3, pt4:oPoint1.pt4};
		}
		var oLine1:Dynamic = buildObjectLine(oPoint1.pt1.x, oPoint1.pt1.y, oPoint1.pt3.x, oPoint1.pt3.y);
		var oLine2:Dynamic = buildObjectLine(oPoint1.pt2.x, oPoint1.pt2.y, oPoint1.pt4.x, oPoint1.pt4.y);
		var oLine3:Dynamic = buildObjectLine(oPoint2.pt1.x, oPoint2.pt1.y, oPoint2.pt3.x, oPoint2.pt3.y);
		var oLine4:Dynamic = buildObjectLine(oPoint2.pt2.x, oPoint2.pt2.y, oPoint2.pt4.x, oPoint2.pt4.y);
		var cross1:Point = lineIntersect(oLine3, oLine1);
		var cross2:Point = lineIntersect(oLine2, oLine4);
		if (cross1 != null && cross2 != null) {
			if (index == 0) {
				return {pt1:oPoint1.pt1, pt2:oPoint1.pt2, pt3:cross1, pt4:cross2};
			}
			return {pt1:tmppt.pt3, pt2:tmppt.pt4, pt3:cross1, pt4:cross2};
		} else {
			return null;
		}
		
		// autogenerated
		return null;
	}

	private function defineAnchors(base:Number3D, baseEnd:Number3D, thickness:Float, prop1:String, prop2:String):Dynamic {
		
		var angle:Float = (Math.atan2(Reflect.field(base, prop2) - Reflect.field(baseEnd, prop2), Reflect.field(base, prop1) - Reflect.field(baseEnd, prop1)) * 180) / Math.PI;
		angle -= 270;
		var angle2:Float = angle + 180;
		var pt1:Point = new Point();
		var pt2:Point = new Point();
		var pt3:Point = new Point();
		var pt4:Point = new Point();
		var radius:Float = thickness * .5;
		pt1.x = pt1.x + Math.cos(-angle / 180 * Math.PI) * radius;
		pt1.y = pt1.y + Math.sin(angle / 180 * Math.PI) * radius;
		pt2.x = pt2.x + Math.cos(-angle2 / 180 * Math.PI) * radius;
		pt2.y = pt2.y + Math.sin(angle2 / 180 * Math.PI) * radius;
		pt3.x = pt3.x + Math.cos(-angle / 180 * Math.PI) * radius;
		pt3.y = pt3.y + Math.sin(angle / 180 * Math.PI) * radius;
		pt4.x = pt4.x + Math.cos(-angle2 / 180 * Math.PI) * radius;
		pt4.y = pt4.y + Math.sin(angle2 / 180 * Math.PI) * radius;
		return {pt1:pt1, pt2:pt2, pt3:pt3, pt4:pt4};
	}

	private function buildObjectLine(origX:Float, origY:Float, endX:Float, endY:Float):Dynamic {
		
		return {ax:origX, ay:origY, bx:endX - origX, by:endY - origY};
	}

	private function lineIntersect(Line1:Dynamic, Line2:Dynamic):Point {
		
		Line1.bx = (Line1.bx == 0) ? 0.0001 : Line1.bx;
		Line2.bx = (Line2.bx == 0) ? 0.0001 : Line2.bx;
		var a1:Float = Line1.by / Line1.bx;
		var b1:Float = Line1.ay - a1 * Line1.ax;
		var a2:Float = Line2.by / Line2.bx;
		var b2:Float = Line2.ay - a2 * Line2.ax;
		var nzero:Float = ((a1 - a2) == 0) ? 0.0001 : a1 - a2;
		var ptx:Float = (b2 - b1) / (nzero);
		var pty:Float = a1 * ptx + b1;
		if (isFinite(ptx) && isFinite(pty)) {
			return new Point();
		} else {
			trace("infinity");
			return null;
		}
		
		// autogenerated
		return null;
	}

}

