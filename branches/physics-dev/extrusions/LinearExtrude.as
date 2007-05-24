
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
	
	
	public class LinearExtrude extends Mesh3D
	{
		static public var DEFAULT_SEGMENTS:Number = 5;
		
		function LinearExtrude(material:IMaterial, shape:Vertices3D, vector:Number3D, init:Object = null)
		{
			super( material, init );
			
			buildExtrusion( shape, vector );
		}
		
		private function buildExtrusion( shape:Vertices3D, vector:Number3D):void
		{
			var i:Number, j:Number, k:Number;
	
			var iVer:Number = DEFAULT_SEGMENTS;
			var aVtc:Array = new Array();
			for (j=0;j<=iVer;j++) { // vertical
				var aRow:Array = new Array();
				var oVtx:Vertex3D;
				var fXAdd:Number = vector.x*j/iVer;
				var fYAdd:Number = vector.y*j/iVer;
				var fZAdd:Number = vector.z*j/iVer;
				var iHor:Number = shape.vertices.length;
				var oVertices:Array = shape.vertices;
				for (i=0;i<iHor;i++) { // horizontal
					oVtx = new Vertex3D(oVertices[i].x + fXAdd, oVertices[i].y + fYAdd, oVertices[i].z + fZAdd);
					vertices.push(oVtx);
					//}
					aRow.push(oVtx);
				}
				aVtc.push(aRow);
			}
			var iVerNum:int = aVtc.length;
	
			var aP4uv:NumberUV, aP1uv:NumberUV, aP2uv:NumberUV, aP3uv:NumberUV;
			var aP1:Vertex3D, aP2:Vertex3D, aP3:Vertex3D, aP4:Vertex3D;
	
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
					var fJ0:Number = j/(iVerNum - 1);
					var fJ1:Number = (j-1)/(iVerNum - 1);
					var fI0:Number = iWrapped/iHorNum;
					var fI1:Number = (iWrapped-1)/iHorNum;
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