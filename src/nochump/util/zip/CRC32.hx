/*
nochump.util.zip.CRC32
Copyright (C) 2007 David Chang (dchang@nochump.com)

This file is part of nochump.util.zip.

nochump.util.zip is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

nochump.util.zip is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
*/
package nochump.util.zip; 
	
	import flash.utils.ByteArray;
	
	/**
	 * Computes CRC32 data checksum of a data stream.
	 * The actual CRC32 algorithm is described in RFC 1952
	 * (GZIP file format specification version 4.3).
	 * 
	 * @author David Chang
	 * @date January 2, 2007.
	 */
	class CRC32  {
		
		/** The crc data checksum so far. */
		
		
		/** The crc data checksum so far. */
		var crc:UInt;
		
		/** The fast CRC table. Computed once when the CRC32 class is loaded. */
		static var crcTable:Array<Dynamic> = makeCrcTable();
		
		/** Make the table for a fast CRC. */
		static function makeCrcTable():Array<Dynamic> {
			var crcTable:Array<Dynamic> = new Array(256);
			for (n in 0...256) {
				var c:UInt = n;
				var k:Int = 8;
				while (--k >= 0) {
					if((c & 1) != 0) c = 0xedb88320 ^ (c >>> 1);
					else c = c >>> 1;
					;
				}
				crcTable[n] = c;
			}
			return crcTable;
		}
		
		/**
		 * Returns the CRC32 data checksum computed so far.
		 */
		public function getValue():UInt {
			return crc & 0xffffffff;
		}
		
		/**
		 * Resets the CRC32 data checksum as if no update was ever called.
		 */
		public function reset():Void {
			crc = 0;
		}
		
		/**
		 * Adds the complete byte array to the data checksum.
		 * 
		 * @param buf the buffer which contains the data
		 */
		public function update(buf:ByteArray):Void {
			var off:UInt = 0;
			var len:UInt = buf.length;
			var c:UInt = ~crc;
			while(--len >= 0) c = crcTable[(c ^ buf[off++]) & 0xff] ^ (c >>> 8);
			crc = ~c;
		}
		
	}
	
