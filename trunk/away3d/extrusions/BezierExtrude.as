
package away3d.extrusions
{
	import away3d.objects.*;
	import away3d.shapes.*;
	import away3d.core.*;
	import away3d.core.draw.*;
	import away3d.core.geom.*;
	import away3d.core.material.*;
	import away3d.core.math.*;
	import away3d.core.proto.*;
	import away3d.core.render.*;
	
	
	public class BezierExtrude extends Mesh3D
	{
		static public var DEFAULT_SEGMENTS:Number = 20;
		
		function BezierExtrude(material:IMaterial, shape:Vertices3D, vertices:Array, init:Object = null)
		{
			super( material, init );
			
			buildExtrusion( shape, vertices );
		}
		
		private function buildExtrusion( shape:Vertices3D, vertices:Array):void
		{
			var i:Number, j:Number, k:Number;
			var iPoints:Number = vertices.length - 1;
			var iVer:Number = DEFAULT_SEGMENTS;
			var aVtc:Array = new Array();
			for (k=0;k<iPoints-2; k+=2) {
				var p0:Number3D = vertices[k];
				var p1:Number3D = vertices[k+1];
				var p2:Number3D = Number3D.sub(Number3D.scale(vertices[k+2], 2), vertices[k+3]);
				var p3:Number3D = vertices[k+2];
				
				var d2:Number3D = Number3D.scale(Number3D.sub(p1, p0), 2);
				var d1:Number3D = Number3D.sub(p2, Number3D.add(p0, d2));
				
				var d4:Number3D = Number3D.scale(Number3D.sub(p2, p1), 2);
				var d3:Number3D = Number3D.sub(p3, Number3D.add(p1, d4));
				
				var vx:Number, vy:Number, vz:Number, sx:Number, sy:Number, sz:Number;
				
				var jStart:Number = k? 1 : 0;
				for (j=jStart;j<=iVer;j++) { // vertical
					var aRow:Array = new Array();
					var a1:Number = j/iVer;
					var a2:Number = Math.pow(j/iVer, 2);
					var fDir1:Number3D = Number3D.add(Number3D.add(Number3D.scale(d1, a2), Number3D.scale(d2, a1)), p0);
					var fDir2:Number3D = Number3D.add(Number3D.add(Number3D.scale(d3, a2), Number3D.scale(d4, a1)), p1);
					var fPos:Number3D = Number3D.add(Number3D.scale(fDir1, 1 - a1), Number3D.scale(fDir2, a1));
					var iHor:Number = shape.vertices.length;
					var oVertices:Array = shape.vertices;
					shape.lookAt(Number3D.sub(fDir2,fDir1));
					var sTransform:Matrix3D = shape.transform;
					for (i=0;i<iHor;i++) { // horizontal
						vx = oVertices[i].x
						vy = oVertices[i].y
						vz = oVertices[i].z
						sx = vx * sTransform.n11 + vy * sTransform.n12 + vz * sTransform.n13 + sTransform.n14;
            			sy = vx * sTransform.n21 + vy * sTransform.n22 + vz * sTransform.n23 + sTransform.n24;
						sz = vx * sTransform.n31 + vy * sTransform.n32 + vz * sTransform.n33 + sTransform.n34;
						var oVtx:Vertex3D = new Vertex3D(sx + fPos.x, sy + fPos.y, sz + fPos.z);
						vertices.push(oVtx);
						aRow.push(oVtx);
					}
					aVtc.push(aRow);
				}
			}
			var iVerNum:int = aVtc.length;
	
			var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
			var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
			var fJ0:Number, fJ1:Number, fI0:Number, fI1:Number;
	
			for (j=1;j<iVerNum;j++) {
				var iHorNum:int = aVtc[j].length;
				var iStart:Number = (iHorNum > 2)? 0 : 1;
				for (i=iStart;i<iHorNum;i++) {
					// select vertices
					var iWrapped:Number = i==0?iHorNum:i;
					aP1 = aVtc[j][i];
					aP2 = aVtc[j][iWrapped-1];
					aP3 = aVtc[j-1][iWrapped-1];
					aP4 = aVtc[j-1][i];
					// uv
					fJ0 = j/(iVerNum - 1);
					fJ1 = (j-1)/(iVerNum - 1);
					fI0 = iWrapped/iHorNum;
					fI1 = (iWrapped-1)/iHorNum;
					aP4uv = new NumberUV(fI0,fJ1);
					aP1uv = new NumberUV(fI0,fJ0);
					aP2uv = new NumberUV(fI1,fJ0);
					aP3uv = new NumberUV(fI1,fJ1);
					// 2 faces
					faces.push( new Face3D(aP1,aP2,aP3, null, aP1uv,aP2uv,aP3uv) );
					faces.push( new Face3D(aP1,aP3,aP4, null, aP1uv,aP3uv,aP4uv) );
				}
			}
		}
	}
		
}