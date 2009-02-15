package nochump.util.zip;

import flash.utils.Endian;
import flash.utils.ByteArray;


/**
 * This is the Deflater class.  The deflater class compresses input
 * with the deflate algorithm described in RFC 1951.  It uses the
 * ByteArray compress method to deflate.
 * 
 * @author David Chang
 */
class Deflater  {
	
	private var buf:ByteArray;
	private var compressed:Bool;
	private var totalIn:Int;
	private var totalOut:Int;
	

	/**
	 * Creates a new deflater.
	 */
	public function new() {
		
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
		
		reset();
	}

	/** 
	 * Resets the deflater.  The deflater acts afterwards as if it was
	 * just created.
	 */
	public function reset():Void {
		
		buf = new ByteArray();
		//buf.endian = Endian.LITTLE_ENDIAN;
		compressed = false;
		totalOut = totalIn = 0;
	}

	/**
	 * Sets the data which should be compressed next.
	 * 
	 * @param input the buffer containing the input data.
	 */
	public function setInput(input:ByteArray):Void {
		
		buf.writeBytes(input);
		totalIn = buf.length;
	}

	/**
	 * Deflates the current input block to the given array.
	 * 
	 * @param output the buffer where to write the compressed data.
	 */
	public function deflate(output:ByteArray):Int {
		
		if (!compressed) {
			buf.compress();
			compressed = true;
		}
		// remove 2-byte header and last 4-byte addler32 checksum
		output.writeBytes(buf, 2, buf.length - 6);
		totalOut = output.length;
		return 0;
	}

	/**
	 * Gets the number of input bytes.
	 */
	public function getBytesRead():Int {
		
		return totalIn;
	}

	/**
	 * Gets the number of output bytes.
	 */
	public function getBytesWritten():Int {
		
		return totalOut;
	}

}

