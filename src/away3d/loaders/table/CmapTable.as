package away3d.loaders.table
{
	import flash.utils.ByteArray;
	
	public class CmapTable
	{
		public var mappings:Array;
		private static const macGlyphName:Array = [ //Note: Multiple character entries are for future uses.
											        ".notdef",      // 0
											        "null",         // 1
											        "CR",           // 2
											        " ",        	// 3
											        "!",       		// 4
											        "\"",     		// 5
											        "#",   			// 6
											        "$",       		// 7
											        "%",      		// 8
											        "&",    		// 9
											        "'",  			// 10
											        "(",    		// 11
											        ")",   			// 12
											        "*",     		// 13
											        "+",         	// 14
											        ",",        	// 15
											        "-",       		// 16
											        ".",       		// 17
											        "/",        	// 18
											        "0",         	// 19
											        "1",          	// 20
											        "2",          	// 21
											        "3",        	// 22
											        "4",         	// 23
											        "5",         	// 24
											        "6",          	// 25
											        "7",        	// 26
											        "8",        	// 27
											        "9",         	// 28
											        ":",        	// 29
											        ";",    		// 30
											        "<",         	// 31
											        "=",        	// 32
											        ">",      		// 33
											        "?",     		// 34
											        "@",           	// 35
											        "A",            // 36
											        "B",            // 37
											        "C",            // 38
											        "D",            // 39
											        "E",            // 40
											        "F",            // 41
											        "G",            // 42
											        "H",            // 43
											        "I",            // 44
											        "J",            // 45
											        "K",            // 46
											        "L",            // 47
											        "M",            // 48
											        "N",            // 49
											        "O",            // 50
											        "P",            // 51
											        "Q",            // 52
											        "R",            // 53
											        "S",            // 54
											        "T",            // 55
											        "U",            // 56
											        "V",            // 57
											        "W",            // 58
											        "X",            // 59
											        "Y",            // 60
											        "Z",            // 61
											        "[",  			// 62
											        "\\",    		// 63
											        "]", 			// 64
											        "^",  			// 65
											        "_",   			// 66
											        "`",        	// 67
											        "a",            // 68
											        "b",            // 69
											        "c",            // 70
											        "d",            // 71
											        "e",            // 72
											        "f",            // 73
											        "g",            // 74
											        "h",            // 75
											        "i",            // 76
											        "j",            // 77
											        "k",            // 78
											        "l",            // 79
											        "m",            // 80
											        "n",            // 81
											        "o",            // 82
											        "p",            // 83
											        "q",            // 84
											        "r",            // 85
											        "s",            // 86
											        "t",            // 87
											        "u",            // 88
											        "v",            // 89
											        "w",            // 90
											        "x",            // 91
											        "y",            // 92
											        "z",            // 93
											        "braceleft",    // 94
											        "bar",          // 95
											        "braceright",   // 96
											        "asciitilde",   // 97
											        "Adieresis",    // 98
											        "Aring",        // 99
											        "Ccedilla",     // 100
											        "Eacute",       // 101
											        "Ntilde",       // 102
											        "Odieresis",    // 103
											        "Udieresis",    // 104
											        "aacute",       // 105
											        "agrave",       // 106
											        "acircumflex",  // 107
											        "adieresis",    // 108
											        "atilde",       // 109
											        "aring",        // 110
											        "ccedilla",     // 111
											        "eacute",       // 112
											        "egrave",       // 113
											        "ecircumflex",  // 114
											        "edieresis",    // 115
											        "iacute",       // 116
											        "igrave",       // 117
											        "icircumflex",  // 118
											        "idieresis",    // 119
											        "ntilde",       // 120
											        "oacute",       // 121
											        "ograve",       // 122
											        "ocircumflex",  // 123
											        "odieresis",    // 124
											        "otilde",       // 125
											        "uacute",       // 126
											        "ugrave",       // 127
											        "ucircumflex",  // 128
											        "udieresis",    // 129
											        "dagger",       // 130
											        "degree",       // 131
											        "cent",         // 132
											        "sterling",     // 133
											        "section",      // 134
											        "bullet",       // 135
											        "paragraph",    // 136
											        "germandbls",   // 137
											        "registered",   // 138
											        "copyright",    // 139
											        "trademark",    // 140
											        "acute",        // 141
											        "dieresis",     // 142
											        "notequal",     // 143
											        "AE",           // 144
											        "Oslash",       // 145
											        "infinity",     // 146
											        "plusminus",    // 147
											        "lessequal",    // 148
											        "greaterequal", // 149
											        "yen",          // 150
													"mu",           // 151
											        "partialdiff",  // 152
											        "summation",    // 153
											        "product",      // 154
													"pi",           // 155
											        "integral'",    // 156
											        "ordfeminine",  // 157
											        "ordmasculine", // 158
													"Omega",        // 159
											        "ae",           // 160
											        "oslash",       // 161
											        "questiondown", // 162
											        "exclamdown",   // 163
											        "logicalnot",   // 164
											        "radical",      // 165
											        "florin",       // 166
											        "approxequal",  // 167
											        "increment",    // 168
											        "guillemotleft",// 169
											        "guillemotright",//170
											        "ellipsis",     // 171
											        "nbspace",      // 172
											        "Agrave",       // 173
											        "Atilde",       // 174
											        "Otilde",       // 175
											        "OE",           // 176
											        "oe",           // 177
											        "endash",       // 178
											        "emdash",       // 179
											        "quotedblleft", // 180
											        "quotedblright",// 181
											        "quoteleft",    // 182
											        "quoteright",   // 183
											        "divide",       // 184
											        "lozenge",      // 185
											        "ydieresis",    // 186
											        "Ydieresis",    // 187
											        "fraction",     // 188
											        "currency",     // 189
											        "guilsinglleft",// 190
											        "guilsinglright",//191
											        "fi",           // 192
											        "fl",           // 193
											        "daggerdbl",    // 194
											        "middot",       // 195
											        "quotesinglbase",//196
											        "quotedblbase", // 197
											        "perthousand",  // 198
											        "Acircumflex",  // 199
											        "Ecircumflex",  // 200
											        "Aacute",       // 201
											        "Edieresis",    // 202
											        "Egrave",       // 203
											        "Iacute",       // 204
											        "Icircumflex",  // 205
											        "Idieresis",    // 206
											        "Igrave",       // 207
											        "Oacute",       // 208
											        "Ocircumflex",  // 209
											        "",             // 210
											        "Ograve",       // 211
											        "Uacute",       // 212
											        "Ucircumflex",  // 213
											        "Ugrave",       // 214
											        "dotlessi",     // 215
											        "circumflex",   // 216
											        "tilde",        // 217
											        "overscore",    // 218
											        "breve",        // 219
											        "dotaccent",    // 220
											        "ring",         // 221
											        "cedilla",      // 222
											        "hungarumlaut", // 223
											        "ogonek",       // 224
											        "caron",        // 225
											        "Lslash",       // 226
											        "lslash",       // 227
											        "Scaron",       // 228
											        "scaron",       // 229
											        "Zcaron",       // 230
											        "zcaron",       // 231
											        "brokenbar",    // 232
											        "Eth",          // 233
											        "eth",          // 234
											        "Yacute",       // 235
											        "yacute",       // 236
											        "Thorn",        // 237
											        "thorn",        // 238
											        "minus",        // 239
											        "multiply",     // 240
											        "onesuperior",  // 241
											        "twosuperior",  // 242
											        "threesuperior",// 243
											        "onehalf",      // 244
											        "onequarter",   // 245
											        "threequarters",// 246
											        "franc",        // 247
											        "Gbreve",       // 248
											        "gbreve",       // 249
											        "Idot",         // 250
											        "Scedilla",     // 251
											        "scedilla",     // 252
											        "Cacute",       // 253
											        "cacute",       // 254
											        "Ccaron",       // 255
											        "ccaron",       // 256
											        ""              // 257
											    ];
		
		public function CmapTable(data:ByteArray, tableOffset:int, numGlyfs:int, range:Array)
		{
			mappings = [];
			
			//Place pointer at the table.
			data.position = tableOffset;
			
			//General info.
			var version:uint = data.readUnsignedShort();
	        var numTables:uint = data.readUnsignedShort();
	        
	        //Read encoding subtables.
	        var entries:Array = [];
	        var i:uint;
	        for(i = 0; i<numTables; i++)
	        {
	        	var platformId:uint = data.readUnsignedShort();
		        var encodingId:uint = data.readUnsignedShort();
		        var offset:int = data.readInt();
		        entries.push({platformId:platformId, encodingId:encodingId, offset:offset});
	        }
	        
	        //entries.sortOn("offset", Array.NUMERIC);
	        
	        //Look for Mac table.
	        var j:uint;
	        for(i = 0; i<numTables; i++)
	        {
	        	data.position = tableOffset + entries[i].offset;
	        	
	        	var formatType:uint = data.readUnsignedShort();
	        	var length:uint = data.readUnsignedShort();
	        	var language:uint = data.readUnsignedShort();
	        	
	        	if(formatType == 0)
	        		for (j = 0; j < 256; j++)
	        		{
	        			var glyfIndex:int = data.readUnsignedByte();
				        mappings.push({index:j, char:macGlyphName[j], glyfIndex:glyfIndex});
				        //trace(j + ", " + macGlyphName[j] + ", " + glyfIndex);
				    }
	        }
	        
	        //Throw error if mapping table couldnt be filled (Mac table not found).
		}
	}
}