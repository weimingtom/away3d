/*
nochump.util.zip.ZipConstants
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
	
	class ZipConstants  {
		
		/* The local file header */
		
		
		/* The local file header */
		internal inline static var LOCSIG:UInt = 0x04034b50;	// "PK\003\004"
		internal inline static var LOCHDR:UInt = 30;	// LOC header size
		internal inline static var LOCVER:UInt = 4;	// version needed to extract
		//internal static const LOCFLG:uint = 6; // general purpose bit flag
		//internal static const LOCHOW:uint = 8; // compression method
		//internal static const LOCTIM:uint = 10; // modification time
		//internal static const LOCCRC:uint = 14; // uncompressed file crc-32 value
		//internal static const LOCSIZ:uint = 18; // compressed size
		//internal static const LOCLEN:uint = 22; // uncompressed size
		internal inline static var LOCNAM:UInt = 26; // filename length
		//internal static const LOCEXT:uint = 28; // extra field length
		
		/* The Data descriptor */
		internal inline static var EXTSIG:UInt = 0x08074b50;	// "PK\007\008"
		internal inline static var EXTHDR:UInt = 16;	// EXT header size
		//internal static const EXTCRC:uint = 4; // uncompressed file crc-32 value
		//internal static const EXTSIZ:uint = 8; // compressed size
		//internal static const EXTLEN:uint = 12; // uncompressed size
		
		/* The central directory file header */
		internal inline static var CENSIG:UInt = 0x02014b50;	// "PK\001\002"
		internal inline static var CENHDR:UInt = 46;	// CEN header size
		//internal static const CENVEM:uint = 4; // version made by
		internal inline static var CENVER:UInt = 6; // version needed to extract
		//internal static const CENFLG:uint = 8; // encrypt, decrypt flags
		//internal static const CENHOW:uint = 10; // compression method
		//internal static const CENTIM:uint = 12; // modification time
		//internal static const CENCRC:uint = 16; // uncompressed file crc-32 value
		//internal static const CENSIZ:uint = 20; // compressed size
		//internal static const CENLEN:uint = 24; // uncompressed size
		internal inline static var CENNAM:UInt = 28; // filename length
		//internal static const CENEXT:uint = 30; // extra field length
		//internal static const CENCOM:uint = 32; // comment length
		//internal static const CENDSK:uint = 34; // disk number start
		//internal static const CENATT:uint = 36; // internal file attributes
		//internal static const CENATX:uint = 38; // external file attributes
		internal inline static var CENOFF:UInt = 42; // LOC header offset
		
		/* The entries in the end of central directory */
		internal inline static var ENDSIG:UInt = 0x06054b50;	// "PK\005\006"
		internal inline static var ENDHDR:UInt = 22; // END header size
		//internal static const ENDSUB:uint = 8; // number of entries on this disk
		internal inline static var ENDTOT:UInt = 10;	// total number of entries
		//internal static const ENDSIZ:uint = 12; // central directory size in bytes
		internal inline static var ENDOFF:UInt = 16; // offset of first CEN header
		//internal static const ENDCOM:uint = 20; // zip file comment length
		
		/* Compression methods */
		internal inline static var STORED:UInt = 0;
		internal inline static var DEFLATED:UInt = 8;
		
	}

