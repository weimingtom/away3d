package away3d.parsers.ttf.table
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class GlyfTable
	{
		private var _rangeArray:Array;
		private var _data:ByteArray;
		private var _locaOffsets:Array;
		private var _offset:uint;
		private var _currentGlyfNumberOfEntries:uint;
		private var _currentChar:String;
		private var _glyfs:Dictionary = new Dictionary();
		private var _queuedControlPoint:Object;
		private var _midPoint:Object;
		private var _metrics:Array;
		
		public function GlyfTable(data:ByteArray, offset:int, numGlyfs:uint, locaOffsets:Array, mappings:Array, rangeArray:Array, metrics:Array)
		{
			_offset = offset;
			_rangeArray = rangeArray;
			_data = data;
			_locaOffsets = locaOffsets;
			_metrics = metrics;
			
			//Sweep all glyfs.
			for(var i:uint; i < numGlyfs; i++)
			{
				try
				{
					//See what character this glyf corresponds to.
					_currentChar = mappings[i].char;
					
					//Verify if this char is intended for parsing.
					if(checkExistsInArray(_currentChar, _rangeArray) != -1)
						obtainGlyfData(i);
				}
				catch(err:Error)
				{
					//Means that there is no character mapping info for this glyf.
					
					/*
						This is a possible extension for the parser. CmapTable is in charge of making these mappings,
						and for now it is just mapping mac type 0 characters.
						If this wants to be avoided, CmapTable has to be extended in order to obtain all
						the character mapping information on the ttf file, which should include characters in
						different languages, etc.
					*/
				}
			}
		}
		
		public function get glyfs():Dictionary
		{
			return _glyfs;
		}
		
		private function obtainGlyfData(i:uint):void
		{
			//Check to see if there is any info in the glyf.
			var length:uint = _locaOffsets[i + 1] - _locaOffsets[i];
			if(length > 0)
			{
				//Place pointer.
				_data.position = _offset + _locaOffsets[i];
				
				//General data.
				var numberOfContours:int = _data.readShort();
				var xMin:int = _data.readShort();
		        var yMin:int = _data.readShort();
		        var xMax:int = _data.readShort();
		        var yMax:int = _data.readShort();
		        
		        //Check number of contours, if positive its a simple glyf, if negative its compound.
		        if(numberOfContours >= 0) //SIMPLE.
		        {
		        	var contourEndPointIndices:Array = findContourEndPointIndices(numberOfContours);
		        	
		        	//Debug...
		        	var str:String = "";
		        	for(var j:uint; j<contourEndPointIndices.length; j++)
		        		str += " " + contourEndPointIndices[j];
		        	
		        	var instructions:Array = findInstructions();
		        	var flags:Array = findFlags();
		        	var xCoords:Array = findXCoords(flags, i);
		        	var yCoords:Array = findYCoords(flags, yMax - yMin);
		        	var pointArray:Array = buildGlyfMotifs(xCoords, yCoords, flags, contourEndPointIndices);
		        	buildGlyf(pointArray, xMax, xMin, yMax, yMin, i);
		        }
		        else //COMPOUND.
		        {
		        	//Not implemented yet.
		        }
			}
		}
		
		private function buildGlyf(pointArray:Array, xMax:int, xMin:int, yMax:int, yMin:int, index:uint):void
		{
			//Get the penpoint horizontal advance for this glyf. 
			var advanceWidth:Number;
			if(index < _metrics.length)
	            advanceWidth = _metrics[index].advanceWidth >> 16;
	        else
	            advanceWidth = _metrics[_metrics.length - 1] >> 16;
			
			glyfs[_currentChar] = {instructions:pointArray, width:advanceWidth, height:yMax - yMin};
		}
		
		private function buildGlyfMotifs(xCoords:Array, yCoords:Array, flags:Array, contourEndPointIndices:Array):Array
		{
			var i:uint;
			var j:uint;
			var arr:Array = [];
			var p1OnCurve:Boolean;
		    var p2OnCurve:Boolean;
		    var currentPoint:uint;
			var contourStartPoint:uint;
			var contourEndPoint:uint
			
			for(i = 0; i<contourEndPointIndices.length; i++) //Sweep contours.
			{	
				//Remember initial point of contour (used to close the contour).
				contourStartPoint = currentPoint;
				
				//Remember contour end point.
				contourEndPoint = contourEndPointIndices[i];
				
				//Implicit first moveTo of contour.
				arr.push({type:0, x:xCoords[contourStartPoint], y:yCoords[contourStartPoint]});
	        	
	        	for(j = 0; j < contourEndPoint - contourStartPoint; j++) //Sweep points in contour.
				{
					analizePath(currentPoint, currentPoint + 1, arr, flags, xCoords, yCoords, String(currentPoint), String(j));
		        	currentPoint++;
				}
				
				//There is an implicit point here in which the contour closes.
        		analizePath(contourEndPoint, contourStartPoint, arr, flags, xCoords, yCoords, "implicitClosePath", "implicitClosePath");
        		currentPoint++;
			}
	        
	        return arr;
		}
		
		private function analizePath(p1:uint, p2:Number, arr:Array, flags:Array, xCoords:Array, yCoords:Array, pathMarker1:String, pathMarker2:String):void
		{
			var p1OnCurve:Boolean = flags[p1] & 0x01 != 0 ? true : false;
	        var p2OnCurve:Boolean = flags[p2] & 0x01 != 0 ? true : false;
			
			//React to last test.
        	if(p1OnCurve && p2OnCurve) //Both points are on the curve, so it's got to be a line.
        		arr.push({type:1, x:xCoords[p2], y:yCoords[p2]});
        	else if(!p1OnCurve && !p2OnCurve)
        	{
        		//Neither is on the curve, so there is an implicit point here.
        		//The implicit point is generated, used as an endPoint and the queuedControlPoint is used as the
        		//control point for the curve.
        		_midPoint = findMidPoint(xCoords[p1], yCoords[p1], xCoords[p2], yCoords[p2]);
        		arr.push({type:2, cx:_queuedControlPoint.x, cy:_queuedControlPoint.y, x:_midPoint.x, y:_midPoint.y});
        		_queuedControlPoint = {x:xCoords[p2], y:yCoords[p2]};
        	}
        	else if(p1OnCurve && !p2OnCurve)
        	{
        		//The second point is going to be a control point.
        		_queuedControlPoint = {x:xCoords[p2], y:yCoords[p2]};
        	}
        	else if(!p1OnCurve && p2OnCurve) //A curve is closing.
        		arr.push({type:2, cx:_queuedControlPoint.x, cy:_queuedControlPoint.y, x:xCoords[p2], y:yCoords[p2]});
		}
		
		private function findXCoords(flags:Array, index:uint):Array
		{
			var arr:Array = [];
			var x:int = 0;
            for(var i:uint; i < _currentGlyfNumberOfEntries; i++)
	        {
	            if((flags[i] & 0x10) != 0)
	            {
	                if((flags[i] & 0x02) != 0)
	                    x += _data.readUnsignedByte();
	            }
	            else 
	            {
	                if((flags[i] & 0x02) != 0)
	                    x += -(_data.readUnsignedByte());
	                else
	                    x += _data.readShort();
	            }
	            arr.push(x);
	        }
			return arr;
		}
		
		private function findYCoords(flags:Array, yOffset:Number):Array
		{
			var arr:Array = [];
			var y:int = 0;
	        for(var i:uint; i < _currentGlyfNumberOfEntries; i++)
	        {
	            if((flags[i] & 0x20) != 0)
	            {
	                if((flags[i] & 0x04) != 0)
	                    y += _data.readUnsignedByte();
	            }
	            else
	            {
	                if((flags[i] & 0x04) != 0)
	                    y += -(_data.readUnsignedByte());
	                else
	                    y += _data.readShort();
	            }
	            arr.push(y /* + yOffset */);
	        }
			return arr;
		}
		
		private function findFlags():Array
		{
			var arr:Array = [];
			var i:uint;
			var j:uint;
			for(i = 0; i < _currentGlyfNumberOfEntries; i++)
            {
                arr[i] = _data.readByte();
                if((arr[i] & 0x08) != 0)
                {
                    var repeats:int = _data.readByte();
                    for(j = 1; j <= repeats; j++)
                        arr[i + j] = arr[i];
                    i += repeats;
                }
            }
            
            return arr;
		}
		
		private function findInstructions():Array
		{
			var instructionCount:int = _data.readShort();
	        var arr:Array = [];
	        for(var i:uint; i < instructionCount; i++)
	            arr.push(_data.readUnsignedByte());
	            
	        return arr;
		}
		
		private function findContourEndPointIndices(numberOfContours:Number):Array
		{
			var arr:Array = [];
			for(var i:uint; i < numberOfContours; i++)
	            arr.push(_data.readShort());
	        
	        _currentGlyfNumberOfEntries = arr[numberOfContours - 1] + 1;
	  		
	  		return arr;
		}
		
		private function checkExistsInArray(value:*, array:Array):int
		{
			var existsInIndex:int = -1;
			for(var i:uint; i < array.length; i++)
			{
				if(array[i] == value)
				{
					existsInIndex = i;
					i = 999999999;
				}
			}
			return existsInIndex;
		}
		
		private function findMidPoint(x1:Number, y1:Number, x2:Number, y2:Number):Object
		{
			var mX:Number = (x1 + x2)/2;
			var mY:Number = (y1 + y2)/2;
			return {x:mX, y:mY};
		}
	}
}