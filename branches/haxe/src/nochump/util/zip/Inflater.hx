package nochump.util.zip;

import away3d.haxeutils.Error;
import flash.events.EventDispatcher;
import flash.events.TimerEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.Timer;


// [Event(name="entryParseError", type="nochump.util.zip.ZipErrorEvent")]

// [Event(name="entryParsed", type="nochump.util.zip.ZipEvent")]

// [Event(name="progress", type="flash.events.ProgressEvent")]

/**
 * Inflater is used to decompress data that has been compressed according 
 * to the "deflate" standard described in rfc1950.
 *
 * The usage is as following.  First you have to set some input with
 * <code>setInput()</code>, then inflate() it.
 * 
 * This implementation is a port of Puff by Mark Addler that comes with
 * the zlip data compression library.  It is not the fastest routine as
 * he intended it for learning purposes, his actual optimized inflater code
 * is very different.  I went with this approach basically because I got a
 * headache looking at the optimized inflater code and porting this
 * was a breeze.  The speed should be adequate but there is plenty of room
 * for improvements here.
 * 
 * @author dchang
 */
class Inflater extends EventDispatcher  {
	
	// maximum bits in a code
	private static inline var MAXBITS:Int = 15;
	// maximum number of literal/length codes
	private static inline var MAXLCODES:Int = 286;
	// maximum number of distance codes
	private static inline var MAXDCODES:Int = 30;
	// maximum codes lengths to read
	private static inline var MAXCODES:Int = MAXLCODES + MAXDCODES;
	// number of fixed literal/length codes
	private static inline var FIXLCODES:Int = 288;
	// Size base for length codes 257..285
	private static inline var LENS:Array<Dynamic> = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258];
	// Extra bits for length codes 257..285
	private static inline var LEXT:Array<Dynamic> = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0];
	// Offset base for distance codes 0..29
	private static inline var DISTS:Array<Dynamic> = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577];
	// Extra bits for distance codes 0..29
	private static inline var DEXT:Array<Dynamic> = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13];
	// Duration between parsing of each chunk of data
	private static inline var TIMER_INTERVAL:Int = 20;
	// input buffer
	private var inbuf:ByteArray;
	// current buffer being decoded
	private var currentBuf:ByteArray;
	// bytes read so far
	private var incnt:Int;
	// bit buffer
	private var bitbuf:Int;
	// number of bits in bit buffer
	private var bitcnt:Int;
	// Huffman code decoding tables
	private var lencode:Dynamic;
	private var distcode:Dynamic;
	private var inflateTimer:Timer;
	

	/**
	 * Sets the input.
	 * 
	 * @param buf the input.
	 */
	public function setInput(buf:ByteArray):Void {
		
		inbuf = buf;
		inbuf.endian = Endian.LITTLE_ENDIAN;
		if ((inflateTimer != null)) {
			inflateTimer.stop();
			inflateTimer.removeEventListener(TimerEvent.TIMER, inflateNextChunk);
		}
		inflateTimer = new Timer(TIMER_INTERVAL);
		inflateTimer.addEventListener(TimerEvent.TIMER, inflateNextChunk);
	}

	/**
	 * Inflates the compressed stream to the output buffer.
	 * 
	 * @param buf the output buffer.
	 */
	public function inflate(buf:ByteArray):Int {
		
		incnt = bitbuf = bitcnt = 0;
		var err:Int = 0;
		// process blocks until last block or error
		// one if last block
		// block type 0..3
		//trace('	block type ' + type);
		// uncompressed block
		// compressed block
		// decode data until end-of-block code
		// return with error
		do {
			var last:Int = bits(1);
			var type:Int = bits(2);
			if (type == 0) {
				stored(buf);
			} else if (type == 3) {
				throw new Error('invalid block type (type == 3)', -1);
			} else {
				lencode = {count:[], symbol:[]};
				distcode = {count:[], symbol:[]};
				if (type == 1) {
					constructFixedTables();
				} else if (type == 2) {
					err = constructDynamicTables();
				}
				if (err != 0) {
					return err;
				}
				err = codes(buf);
			}
			if (err != 0) {
				break;
			}
		} while (last == 0);

		return err;
	}

	public function queuedInflate(buf:ByteArray):Void {
		
		incnt = bitbuf = bitcnt = 0;
		currentBuf = buf;
		inflateTimer.start();
	}

	private function inflateNextChunk(event:TimerEvent):Void {
		
		var err:Int = 0;
		// one if last block
		var last:Int = bits(1);
		// block type 0..3
		var type:Int = bits(2);
		//trace('	block type ' + type);
		// uncompressed block
		if (type == 0) {
			stored(currentBuf);
		} else if (type == 3) {
			throw new Error('invalid block type (type == 3)', -1);
		} else {
			lencode = {count:[], symbol:[]};
			distcode = {count:[], symbol:[]};
			if (type == 1) {
				constructFixedTables();
			} else if (type == 2) {
				err = constructDynamicTables();
			}
			if (err != 0) {
				inflateTimer.stop();
				dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, false, false, err));
			}
			// decode data until end-of-block code
			err = codes(currentBuf);
		}
		if (err != 0) {
			inflateTimer.stop();
			dispatchEvent(new ZipErrorEvent(ZipErrorEvent.PARSE_ERROR, false, false, err));
		}
		if ((last > 0)) {
			inflateTimer.stop();
			dispatchEvent(new ZipEvent(ZipEvent.ENTRY_PARSED, false, false, currentBuf));
		}
		dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, incnt, currentBuf.length));
	}

	private function bits(need:Int):Int {
		// bit accumulator (can use up to 20 bits)
		// load at least need bits into val
		
		var val:Int = bitbuf;
		while (bitcnt < need) {
			if (incnt == inbuf.length) {
				throw new Error('available inflate data did not terminate', 2);
			}
			// load eight bits
			val |= Reflect.field(inbuf, incnt++) << bitcnt;
			bitcnt += 8;
		}

		// drop need bits and update buffer, always zero to seven bits left
		bitbuf = val >> need;
		bitcnt -= need;
		// return need bits, zeroing the bits above that
		return val & ((1 << need) - 1);
	}

	private function construct(h:Dynamic, length:Array<Dynamic>, n:Int):Int {
		// offsets in symbol table for each length
		
		var offs:Array<Dynamic> = [];
		// count number of codes of each length
		var len:Int = 0;
		while (len <= MAXBITS) {
			h.count[len] = 0;
			
			// update loop variables
			len++;
		}

		// assumes lengths are within bounds
		var symbol:Int = 0;
		while (symbol < n) {
			h.count[length[symbol]]++;
			
			// update loop variables
			symbol++;
		}

		// no codes! complete, but decode() will fail
		if (h.count[0] == n) {
			return 0;
		}
		// check for an over-subscribed or incomplete set of lengths
		// one possible code of zero length
		var left:Int = 1;
		len = 1;
		while (len <= MAXBITS) {
			left <<= 1;
			// deduct count from possible codes
			left -= h.count[len];
			// over-subscribed--return negative
			if (left < 0) {
				return left;
			}
			// left > 0 means incomplete
			
			
			// update loop variables
			len++;
		}

		// generate offsets into symbol table for each length for sorting
		offs[1] = 0;
		len = 1;
		while (len < MAXBITS) {
			offs[len + 1] = offs[len] + h.count[len];
			
			// update loop variables
			len++;
		}

		// put symbols in table sorted by length, by symbol order within each length
		symbol = 0;
		while (symbol < n) {
			if (length[symbol] != 0) {
				h.symbol[offs[length[symbol]]++] = symbol;
			}
			
			// update loop variables
			symbol++;
		}

		// return zero for complete set, positive for incomplete set
		return left;
	}

	private function decode(h:Dynamic):Int {
		// len bits being decoded
		
		var code:Int = 0;
		// first code of length len
		var first:Int = 0;
		// index of first code of length len in symbol table
		var index:Int = 0;
		// current number of bits in code
		var len:Int = 1;
		while (len <= MAXBITS) {
			code |= bits(1);
			// number of codes of length len
			var count:Int = h.count[len];
			// if length len, return symbol
			if (code < first + count) {
				return h.symbol[index + (code - first)];
			}
			// else update for next length
			index += count;
			first += count;
			first <<= 1;
			code <<= 1;
			
			// update loop variables
			len++;
		}

		// ran out of codes
		return -9;
	}

	private function codes(buf:ByteArray):Int {
		// decode literals and length/distance pairs
		// invalid symbol
		// literal: symbol is the byte
		// length
		// get and compute length
		// length for copy
		// get and check distance
		// invalid symbol
		// distance for copy
		// copy length bytes from distance bytes back
		// end of block symbol
		
		do {
			var symbol:Int = decode(lencode);
			if (symbol < 0) {
				return symbol;
			}
			if (symbol < 256) {
				Reflect.setField(buf, buf.length, symbol);
			} else if (symbol > 256) {
				symbol -= 257;
				if (symbol >= 29) {
					throw new Error("invalid literal/length or distance code in fixed or dynamic block", -9);
				}
				var len:Int = LENS[symbol] + bits(LEXT[symbol]);
				symbol = decode(distcode);
				if (symbol < 0) {
					return symbol;
				}
				var dist:Int = DISTS[symbol] + bits(DEXT[symbol]);
				if (dist > buf.length) {
					throw new Error("distance is too far back in fixed or dynamic block", -10);
				}
				while ((len-- > 0)) {
					Reflect.setField(buf, buf.length, Reflect.field(buf, buf.length - dist));
				}

			}
		} while (symbol != 256);

		// done with a valid fixed or dynamic block
		return 0;
	}

	private function stored(buf:ByteArray):Void {
		// discard leftover bits from current byte (assumes s->bitcnt < 8)
		
		bitbuf = 0;
		bitcnt = 0;
		// get length and check against its one's complement
		if (incnt + 4 > inbuf.length) {
			throw new Error('available inflate data did not terminate', 2);
		}
		// length of stored block
		var len:Int = Reflect.field(inbuf, incnt++);
		len |= Reflect.field(inbuf, incnt++) << 8;
		if (Reflect.field(inbuf, incnt++) != (~len & 0xff) || Reflect.field(inbuf, incnt++) != ((~len >> 8) & 0xff)) {
			throw new Error("stored block length did not match one's complement", -2);
		}
		if (incnt + len > inbuf.length) {
			throw new Error('available inflate data did not terminate', 2);
		}
		// copy len bytes from in to out
		while ((len-- > 0)) {
			Reflect.setField(buf, buf.length, Reflect.field(inbuf, incnt++));
		}

	}

	private function constructFixedTables():Void {
		
		var lengths:Array<Dynamic> = [];
		// literal/length table
		var symbol:Int = 0;
		while (symbol < 144) {
			lengths[symbol] = 8;
			
			// update loop variables
			symbol++;
		}

		;
		while (symbol < 256) {
			lengths[symbol] = 9;
			
			// update loop variables
			symbol++;
		}

		;
		while (symbol < 280) {
			lengths[symbol] = 7;
			
			// update loop variables
			symbol++;
		}

		;
		while (symbol < FIXLCODES) {
			lengths[symbol] = 8;
			
			// update loop variables
			symbol++;
		}

		construct(lencode, lengths, FIXLCODES);
		// distance table
		symbol = 0;
		while (symbol < MAXDCODES) {
			lengths[symbol] = 5;
			
			// update loop variables
			symbol++;
		}

		construct(distcode, lengths, MAXDCODES);
	}

	private function constructDynamicTables():Int {
		// descriptor code lengths
		
		var lengths:Array<Dynamic> = [];
		// permutation of code length codes
		var order:Array<Dynamic> = [16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15];
		// get number of lengths in each table, check lengths
		var nlen:Int = bits(5) + 257;
		var ndist:Int = bits(5) + 1;
		// number of lengths in descriptor
		var ncode:Int = bits(4) + 4;
		if (nlen > MAXLCODES || ndist > MAXDCODES) {
			throw new Error("dynamic block code description: too many length or distance codes", -3);
		}
		// read code length code lengths (really), missing lengths are zero
		var index:Int = 0;
		while (index < ncode) {
			lengths[order[index]] = bits(3);
			
			// update loop variables
			index++;
		}

		;
		while (index < 19) {
			lengths[order[index]] = 0;
			
			// update loop variables
			index++;
		}

		// build huffman table for code lengths codes (use lencode temporarily)
		var err:Int = construct(lencode, lengths, 19);
		if (err != 0) {
			throw new Error("dynamic block code description: code lengths codes incomplete", -4);
		}
		// read length/literal and distance code length tables
		index = 0;
		while (index < nlen + ndist) {
			var symbol:Int;
			var len:Int;
			symbol = decode(lencode);
			// length in 0..15
			if (symbol < 16) {
				lengths[index++] = symbol;
			} else {
				len = 0;
				// repeat last length 3..6 times
				if (symbol == 16) {
					if (index == 0) {
						throw new Error("dynamic block code description: repeat lengths with no first length", -5);
					}
					// last length
					len = lengths[index - 1];
					symbol = 3 + bits(2);
				} else // repeat zero 3..10 times
if (symbol == 17) {
					symbol = 3 + bits(3);
				} else {
					// == 18, repeat zero 11..138 times
					symbol = 11 + bits(7);
				}
				if (index + symbol > nlen + ndist) {
					throw new Error("dynamic block code description: repeat more than specified lengths", -6);
				}
				// repeat last or zero symbol times
				while ((symbol-- > 0)) {
					lengths[index++] = len;
				}

			}
		}

		// build huffman table for literal/length codes
		err = construct(lencode, lengths, nlen);
		// only allow incomplete codes if just one code
		if (err < 0 || (err > 0 && nlen - lencode.count[0] != 1)) {
			throw new Error("dynamic block code description: invalid literal/length code lengths", -7);
		}
		// build huffman table for distance codes
		err = construct(distcode, lengths.slice(nlen), ndist);
		// only allow incomplete codes if just one code
		if (err < 0 || (err > 0 && ndist - distcode.count[0] != 1)) {
			throw new Error("dynamic block code description: invalid distance code lengths", -8);
		}
		return err;
	}

	// autogenerated
	public function new () {
		super();
		
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
	}

	

}

