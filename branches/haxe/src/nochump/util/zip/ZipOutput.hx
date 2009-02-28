package nochump.util.zip;

import away3d.haxeutils.Error;
import flash.utils.Dictionary;
import flash.utils.Endian;
import flash.utils.ByteArray;


class ZipOutput  {
	public var size(getSize, null) : Int;
	public var byteArray(getByteArray, null) : ByteArray;
	public var comment(null, setComment) : String;
	
	private var _entry:ZipEntry;
	private var _entries:Array<Dynamic>;
	private var _names:Dictionary;
	private var _def:Deflater;
	private var _crc:CRC32;
	private var _buf:ByteArray;
	private var _comment:String;
	

	public function new() {
		this._entries = [];
		this._names = new Dictionary();
		this._def = new Deflater();
		this._crc = new CRC32();
		this._buf = new ByteArray();
		this._comment = "";
		
		OPPOSITE_OR[X | X] = N;
		OPPOSITE_OR[XY | X] = Y;
		OPPOSITE_OR[XZ | X] = Z;
		OPPOSITE_OR[XYZ | X] = YZ;
		OPPOSITE_OR[Y | Y] = N;
		OPPOSITE_OR[XY | Y] = X;
		OPPOSITE_OR[XYZ | Y] = XZ;
		OPPOSITE_OR[YZ | Y] = Z;
		OPPOSITE_OR[Z | Z] = N;
		OPPOSITE_OR[XZ | Z] = X;
		OPPOSITE_OR[XYZ | Z] = XY;
		OPPOSITE_OR[YZ | Z] = Y;
		SCALINGS[1] = [1, 1, 1];
		SCALINGS[2] = [-1, 1, 1];
		SCALINGS[4] = [-1, 1, -1];
		SCALINGS[8] = [1, 1, -1];
		SCALINGS[16] = [1, -1, 1];
		SCALINGS[32] = [-1, -1, 1];
		SCALINGS[64] = [-1, -1, -1];
		SCALINGS[128] = [1, -1, -1];
		
		_buf.endian = Endian.LITTLE_ENDIAN;
	}

	/**
	 * Returns the number of entries in this zip file.
	 */
	public function getSize():Int {
		
		return _entries.length;
	}

	/**
	 * Returns the byte array of the finished zip.
	 */
	public function getByteArray():ByteArray {
		
		_buf.position = 0;
		return _buf;
	}

	/**
	 *
	 */
	public function setComment(value:String):String {
		
		_comment = value;
		return value;
	}

	public function putNextEntry(e:ZipEntry):Void {
		
		if (_entry != null) {
			closeEntry();
		}
		// TODO:
		if (e.dostime == 0) {
			e.time = new Date().time;
		}
		// use default method
		if (e.method == -1) {
			e.method = ZipConstants.DEFLATED;
		}
		switch (e.method) {
			case ZipConstants.DEFLATED :
				if (e.size == -1 || e.compressedSize == -1 || e.crc == 0) {
					e.flag = 8;
				} else if (e.size != -1 && e.compressedSize != -1 && e.crc != 0) {
					e.flag = 0;
				} else {
					throw new ZipError("DEFLATED entry missing size, compressed size, or crc-32");
				}
				e.version = 20;
			case ZipConstants.STORED :
				// compressed size, uncompressed size, and crc-32 must all be
				// set for entries using STORED compression method
				if (e.size == -1) {
					e.size = e.compressedSize;
				} else if (e.compressedSize == -1) {
					e.compressedSize = e.size;
				} else if (e.size != e.compressedSize) {
					throw new ZipError("STORED entry where compressed != uncompressed size");
				}
				if (e.size == -1 || e.crc == 0) {
					throw new ZipError("STORED entry missing size, compressed size, or crc-32");
				}
				e.version = 10;
				e.flag = 0;
			default :
				throw new ZipError("unsupported compression method");
			

		}
		e.offset = _buf.position;
		if (_names[untyped e.name] != null) {
			throw new ZipError("duplicate entry: " + e.name);
		} else {
			_names[untyped e.name] = e;
		}
		writeLOC(e);
		_entries.push(e);
		_entry = e;
	}

	public function write(b:ByteArray):Void {
		
		if (_entry == null) {
			throw new ZipError("no current ZIP entry");
		}
		//*
		switch (_entry.method) {
			case ZipConstants.DEFLATED :
				//super.write(b, off, len);
				var cb:ByteArray = new ByteArray();
				_def.setInput(b);
				_def.deflate(cb);
				_buf.writeBytes(cb);
			case ZipConstants.STORED :
				// TODO:
				//if (written - locoff > _entry.size) {
				//	throw new ZipError("attempt to write past end of STORED entry");
				//}
				//out.write(b, off, len);
				_buf.writeBytes(b);
			default :
				throw new Error("invalid compression method");
			

		}
		/**/
		_crc.update(b);
	}

	// check if this method is still necessary since we're not dealing with streams
	// seems crc and whether a data descriptor i necessary is determined here
	public function closeEntry():Void {
		
		var e:ZipEntry = _entry;
		if (e != null) {
			switch (e.method) {
				case ZipConstants.DEFLATED :
					if ((e.flag & 8) == 0) {
						if (e.size != _def.getBytesRead()) {
							throw new ZipError("invalid entry size (expected " + e.size + " but got " + _def.getBytesRead() + " bytes)");
						}
						if (e.compressedSize != _def.getBytesWritten()) {
							throw new ZipError("invalid entry compressed size (expected " + e.compressedSize + " but got " + _def.getBytesWritten() + " bytes)");
						}
						if (e.crc != _crc.getValue()) {
							throw new ZipError("invalid entry CRC-32 (expected 0x" + e.crc + " but got 0x" + _crc.getValue() + ")");
						}
					} else {
						e.size = _def.getBytesRead();
						e.compressedSize = _def.getBytesWritten();
						e.crc = _crc.getValue();
						writeEXT(e);
					}
					_def.reset();
				case ZipConstants.STORED :
				default :
					// TODO:
					throw new Error("invalid compression method");
				

			}
			_crc.reset();
			_entry = null;
		}
	}

	public function finish():Void {
		
		if (_entry != null) {
			closeEntry();
		}
		if (_entries.length < 1) {
			throw new ZipError("ZIP file must have at least one entry");
		}
		var off:Int = _buf.position;
		// write central directory
		var i:Int = 0;
		while (i < _entries.length) {
			writeCEN(_entries[i]);
			
			// update loop variables
			i++;
		}

		writeEND(off, _buf.position - off);
	}

	private function writeLOC(e:ZipEntry):Void {
		
		_buf.writeUnsignedInt(ZipConstants.LOCSIG);
		_buf.writeShort(e.version);
		_buf.writeShort(e.flag);
		_buf.writeShort(e.method);
		// dostime
		_buf.writeUnsignedInt(e.dostime);
		if ((e.flag & 8) == 8) {
			_buf.writeUnsignedInt(0);
			_buf.writeUnsignedInt(0);
			_buf.writeUnsignedInt(0);
		} else {
			_buf.writeUnsignedInt(e.crc);
			// compressed size
			_buf.writeUnsignedInt(e.compressedSize);
			// uncompressed size
			_buf.writeUnsignedInt(e.size);
		}
		_buf.writeShort(e.name.length);
		_buf.writeShort(e.extra != null ? e.extra.length : 0);
		_buf.writeUTFBytes(e.name);
		if (e.extra != null) {
			_buf.writeBytes(e.extra);
		}
	}

	/*
	 * Writes extra data descriptor (EXT) for specified entry.
	 */
	private function writeEXT(e:ZipEntry):Void {
		// EXT header signature
		
		_buf.writeUnsignedInt(ZipConstants.EXTSIG);
		// crc-32
		_buf.writeUnsignedInt(e.crc);
		// compressed size
		_buf.writeUnsignedInt(e.compressedSize);
		// uncompressed size
		_buf.writeUnsignedInt(e.size);
	}

	/*
	 * Write central directory (CEN) header for specified entry.
	 * REMIND: add support for file attributes
	 */
	private function writeCEN(e:ZipEntry):Void {
		// CEN header signature
		
		_buf.writeUnsignedInt(ZipConstants.CENSIG);
		// version made by
		_buf.writeShort(e.version);
		// version needed to extract
		_buf.writeShort(e.version);
		// general purpose bit flag
		_buf.writeShort(e.flag);
		// compression method
		_buf.writeShort(e.method);
		// last modification time
		_buf.writeUnsignedInt(e.dostime);
		// crc-32
		_buf.writeUnsignedInt(e.crc);
		// compressed size
		_buf.writeUnsignedInt(e.compressedSize);
		// uncompressed size
		_buf.writeUnsignedInt(e.size);
		_buf.writeShort(e.name.length);
		_buf.writeShort(e.extra != null ? e.extra.length : 0);
		_buf.writeShort(e.comment != null ? e.comment.length : 0);
		// starting disk number
		_buf.writeShort(0);
		// internal file attributes (unused)
		_buf.writeShort(0);
		// external file attributes (unused)
		_buf.writeUnsignedInt(0);
		// relative offset of local header
		_buf.writeUnsignedInt(e.offset);
		_buf.writeUTFBytes(e.name);
		if (e.extra != null) {
			_buf.writeBytes(e.extra);
		}
		if (e.comment != null) {
			_buf.writeUTFBytes(e.comment);
		}
	}

	/*
	 * Writes end of central directory (END) header.
	 */
	private function writeEND(off:Int, len:Int):Void {
		// END record signature
		
		_buf.writeUnsignedInt(ZipConstants.ENDSIG);
		// number of this disk
		_buf.writeShort(0);
		// central directory start disk
		_buf.writeShort(0);
		// number of directory entries on disk
		_buf.writeShort(_entries.length);
		// total number of directory entries
		_buf.writeShort(_entries.length);
		// length of central directory
		_buf.writeUnsignedInt(len);
		// offset of central directory
		_buf.writeUnsignedInt(off);
		// zip file comment
		_buf.writeUTF(_comment);
	}

}

