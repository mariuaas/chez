const std = @import("std");

pub const FULL: u64 = 0xffffffffffffffff;
pub const EMPTY: u64 = 0;
pub const RANK_EVENS: u64 = 0xff00ff00ff00ff00;
pub const RANK_ODDS: u64 = 0x00ff00ff00ff00ff;
pub const FILE_EVENS: u64 = 0xaaaaaaaaaaaaaaaa;
pub const FILE_ODDS: u64 = 0x5555555555555555;
pub const RANK_1256: u64 = 0x0000ffff0000ffff;
pub const RANK_3478: u64 = 0xffff0000ffff0000;
pub const FILE_ABEF: u64 = 0x3333333333333333;
pub const FILE_CDGH: u64 = 0xcccccccccccccccc;
pub const RANK_NORTH: u64 = 0xffffffff00000000;
pub const RANK_SOUTH: u64 = 0x00000000ffffffff;
pub const FILE_WEST: u64 = 0x0f0f0f0f0f0f0f0f;
pub const FILE_EAST: u64 = 0xf0f0f0f0f0f0f0f0;
pub const EDGES: u64 = 0xff818181818181ff;
pub const EDGES_2: u64 = 0x7e424242427e00;
pub const EDGES_3: u64 = 0x3c24243c0000;
pub const CENTER: u64 = 0x1818000000;
pub const EXT_CENTER: u64 = 0x3c3c3c3c0000;
pub const DARK: u64 = 0xaa55aa55aa55aa55;
pub const LIGHT: u64 = 0x55aa55aa55aa55aa;
pub const CORNERS: u64 = 0x8100000000000081;

pub const RANK: [8]u64 = [_]u64{
    0xff,
    0xff << (1 * 8),
    0xff << (2 * 8),
    0xff << (3 * 8),
    0xff << (4 * 8),
    0xff << (5 * 8),
    0xff << (6 * 8),
    0xff << (7 * 8),
};

pub const FILE: [8]u64 = [_]u64{
    0x0101010101010101,
    0x0101010101010101 << 1,
    0x0101010101010101 << 2,
    0x0101010101010101 << 3,
    0x0101010101010101 << 4,
    0x0101010101010101 << 5,
    0x0101010101010101 << 6,
    0x0101010101010101 << 7,
};

pub const CUM_FILES: [9]u64 = [_]u64{
    0x0000000000000000,
    0x0101010101010101,
    0x0303030303030303,
    0x0707070707070707,
    0x0f0f0f0f0f0f0f0f,
    0x1f1f1f1f1f1f1f1f,
    0x3f3f3f3f3f3f3f3f,
    0x7f7f7f7f7f7f7f7f,
    0xffffffffffffffff,
};

pub const POS_DIAG: [13]u64 = [_]u64{
    0x0201000000000000, // A7B8
    0x0402010000000000, // A6C8
    0x0804020100000000, // A5D8
    0x1008040201000000, // A4E8
    0x2010080402010000, // A3F8
    0x4020100804020100, // A2G8
    0x8040201008040201, // A1H8
    0x0080402010080402, // B1H7
    0x0000804020100804, // C1H6
    0x0000008040201008, // D1H5
    0x0000000080402010, // E1H4
    0x0000000000804020, // F1H3
    0x0000000000008040, // G1H2
};

pub const NEG_DIAG: [13]u64 = [_]u64{
    0x0000000000000102, // A2B1
    0x0000000000010204, // A3C1
    0x0000000001020408, // A4D1
    0x0000000102040810, // A5E1
    0x0000010204081020, // A6F1
    0x0001020408102040, // A7G1
    0x0102040810204080, // A8H1
    0x0204081020408000, // B8H2
    0x0408102040800000, // C8H3
    0x0810204080000000, // D8H4
    0x1020408000000000, // E8H5
    0x2040800000000000, // F8H6
    0x4080000000000000, // G8H7
};

pub const SQUARE: [64]u64 = initSquares();

fn initSquares() [64]u64 {
    var sqs: [64]u64 = undefined;
    for (0..64) |i| sqs[i] = (1 << i);
    return sqs;
}

pub const BB = enum {
    _1,
    _2,
    _3,
    _4,
    _5,
    _6,
    _7,
    _8,
    A,
    B,
    C,
    D,
    E,
    F,
    G,
    H,
    A7B8,
    A6C8,
    A5D8,
    A4E8,
    A3F8,
    A2G8,
    A1H8,
    B1H7,
    C1H6,
    D1H5,
    E1H4,
    F1H3,
    G1H2,
    A2B1,
    A3C1,
    A4D1,
    A5E1,
    A6F1,
    A7G1,
    A8H1,
    B8H2,
    C8H3,
    D8H4,
    E8H5,
    F8H6,
    G8H7,
    A1,
    B1,
    C1,
    D1,
    E1,
    F1,
    G1,
    H1,
    A2,
    B2,
    C2,
    D2,
    E2,
    F2,
    G2,
    H2,
    A3,
    B3,
    C3,
    D3,
    E3,
    F3,
    G3,
    H3,
    A4,
    B4,
    C4,
    D4,
    E4,
    F4,
    G4,
    H4,
    A5,
    B5,
    C5,
    D5,
    E5,
    F5,
    G5,
    H5,
    A6,
    B6,
    C6,
    D6,
    E6,
    F6,
    G6,
    H6,
    A7,
    B7,
    C7,
    D7,
    E7,
    F7,
    G7,
    H7,
    A8,
    B8,
    C8,
    D8,
    E8,
    F8,
    G8,
    H8,
    full,
    empty,
    rank_evens,
    rank_odds,
    file_evens,
    file_odds,
    rank_1256,
    rank_3478,
    file_ABEF,
    file_CDGH,
    rank_north,
    rank_south,
    file_west,
    file_east,
    edges,
    edges_2,
    edges_3,
    center,
    ext_center,
    dark_sqr,
    lite_sqr,
    corners,
};

pub fn get(bb: BB) u64 {
    var val = @intFromEnum(bb);
    if (val < 8) {
        return RANK[val];
    } else if (val < 16) {
        return FILE[val - 8];
    } else if (val < 29) {
        return POS_DIAG[val - 16];
    } else if (val < 42) {
        return NEG_DIAG[val - 29];
    } else if (val < 106) {
        return SQUARE[val - 42];
    } else {
        return switch (bb) {
            BB.full => FULL,
            BB.empty => EMPTY,
            BB.rank_evens => RANK_EVENS,
            BB.rank_odds => RANK_ODDS,
            BB.file_evens => FILE_EVENS,
            BB.file_odds => FILE_ODDS,
            BB.rank_1256 => RANK_1256,
            BB.rank_3478 => RANK_3478,
            BB.file_ABEF => FILE_ABEF,
            BB.file_CDGH => FILE_CDGH,
            BB.rank_north => RANK_NORTH,
            BB.rank_south => RANK_SOUTH,
            BB.file_west => FILE_WEST,
            BB.file_east => FILE_EAST,
            BB.edges => EDGES,
            BB.edges_2 => EDGES_2,
            BB.edges_3 => EDGES_3,
            BB.center => CENTER,
            BB.ext_center => EXT_CENTER,
            BB.dark_sqr => DARK,
            BB.lite_sqr => LIGHT,
            BB.corners => CORNERS,
            else => EMPTY,
        };
    }
}

pub fn flipud(bits: u64) u64 {
    const k1 = RANK_ODDS;
    const k2 = RANK_1256;
    var x = bits;
    x = ((x >> 8) & k1) | ((x & k1) << 8);
    x = ((x >> 16) & k2) | ((x & k2) << 16);
    x = (x >> 32) | (x << 32);
    return x;
}

pub fn fliplr(bits: u64) u64 {
    const k1 = FILE_ODDS;
    const k2 = FILE_ABEF;
    const k4 = FILE_WEST;
    var x = bits;
    x = ((x >> 1) & k1) + 2 * (x & k1);
    x = ((x >> 2) & k2) + 4 * (x & k2);
    x = ((x >> 4) & k4) + 16 * (x & k4);
    return x;
}

pub fn reverse(bits: u64) u64 {
    return @bitReverse(bits);
}

pub fn lsb(bits: u64) u7 { // Convenience function
    return @ctz(bits);
}

pub fn msb(bits: u64) u7 { // Convenience function
    return @clz(bits);
}

pub fn popcnt(bits: u64) u7 { // Convenience function
    return @popCount(bits);
}

pub fn north(bits: u64, n: u3) u64 {
    return bits << 8 * @as(u6, n);
}

pub fn south(bits: u64, n: u3) u64 {
    return bits >> 8 * @as(u6, n);
}

pub fn west(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[8 - @as(u4, n)];
    return (bits >> n) & mask;
}

pub fn east(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[n];
    return (bits << n) & ~mask;
}

pub fn northwest(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[8 - @as(u4, n)];
    return (bits << 7 * @as(u6, n)) & mask;
}

pub fn northeast(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[n];
    return (bits << 9 * @as(u6, n)) & ~mask;
}

pub fn southwest(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[8 - @as(u4, n)];
    return (bits >> 9 * @as(u6, n)) & mask;
}

pub fn southeast(bits: u64, n: u3) u64 {
    var mask = CUM_FILES[n];
    return (bits >> 7 * @as(u6, n)) & ~mask;
}

pub fn fullRanks(bits: u64) u64 {
    var mask = EMPTY;
    var bs = BitBoardSerializer(bits);
    while (bs.next()) |pos| {
        mask |= RANK[pos / 8];
    }
    return mask;
}

pub fn fullFiles(bits: u64) u64 {
    var mask = EMPTY;
    var bs = BitBoardSerializer(bits);
    while (bs.next()) |pos| {
        mask |= FILE[pos % 8];
    }
    return mask;
}

pub fn subset(bits: u64, other: u64) bool {
    return (bits | other) == other;
}

pub fn superset(bits: u64, other: u64) bool {
    return subset(other, bits);
}

pub fn setPos(bits: u64, n: u6) u64 {
    return bits | @as(u64, 1) << n;
}

pub fn clearPos(bits: u64, n: u6) u64 {
    return bits & ~(@as(u64, 1) << n);
}

pub fn flipPos(bits: u64, n: u6) u64 {
    return bits ^ @as(u64, 1) << n;
}

pub fn posIsLightSquare(n: u6) bool {
    const mask = @as(u64, 1) << n;
    return (mask & LIGHT) != 0;
}

pub fn occFromArray(pieces: [6]u64) u64 {
    const vec: @Vector(6, u64) = pieces;
    return @reduce(std.builtin.ReduceOp.Or, vec);
}

pub const BitBoardSerializer = struct {
    bits: u64,

    pub fn init(bits: u64) BitBoardSerializer {
        return BitBoardSerializer{ .bits = bits };
    }

    pub fn next(self: *BitBoardSerializer) ?u7 {
        var position = @ctz(self.bits);
        if (position == 64) return null;
        self.bits &= ~(@as(u64, 1) << @truncate(position));
        return position;
    }
};

pub const ANSI = struct {
    prefix: []const u8,
    postfix: []const u8,

    pub fn init(prefix: []const u8, postfix: []const u8) ANSI {
        return ANSI{ .prefix = "\u{001B}[" ++ prefix ++ "m", .postfix = "\u{001B}[" ++ postfix ++ "m" };
    }

    pub fn cat(self: ANSI, other: ANSI) ANSI {
        return ANSI{ .prefix = self.prefix ++ other.prefix, .postfix = self.postfix ++ other.postfix };
    }
};

pub const ANSICodes = struct { // TODO: Why are these camelcase???
    pub const bold: ANSI = ANSI.init("1", "22");
    pub const reset: ANSI = ANSI.init("0", "0");
    pub const fgReset: ANSI = ANSI.init("39", "39");
    pub const bgReset: ANSI = ANSI.init("49", "39");
    pub const fgWhite: ANSI = ANSI.init("37", "39");
    pub const fgBlack: ANSI = ANSI.init("30", "39");
    pub const fgGray: ANSI = ANSI.init("90", "39");
    pub const fgMagenta: ANSI = ANSI.init("35", "39");
    pub const fgCyan: ANSI = ANSI.init("36", "39");
    pub const bgWhite: ANSI = ANSI.init("47", "49");
    pub const bgBlack: ANSI = ANSI.init("40", "49");
    pub const bgGray: ANSI = ANSI.init("100", "49");
    pub const bgMagenta: ANSI = ANSI.init("45", "49");
    pub const bgCyan: ANSI = ANSI.init("46", "49");
    pub const whiteOnBlack: ANSI = ANSICodes.bgBlack.cat(ANSICodes.fgWhite);
    pub const blackOnWhite: ANSI = ANSICodes.bgWhite.cat(ANSICodes.fgBlack);
    pub const cyanOnMagenta: ANSI = ANSICodes.bgMagenta.cat(ANSICodes.fgCyan);
    pub const magentaOnCyan: ANSI = ANSICodes.bgCyan.cat(ANSICodes.fgMagenta);
    pub const whiteOnMagenta: ANSI = ANSICodes.bgMagenta.cat(ANSICodes.fgWhite);
    pub const grayOnCyan: ANSI = ANSICodes.bgCyan.cat(ANSICodes.fgGray);
};

pub const UTFPiece = struct {
    white: u21,
    black: u21,
};

pub const Player = enum { white, black };

pub const Piece = enum { k, q, r, b, n, p };

pub const PlayerPiece = enum { K, Q, R, B, N, P, k, q, r, b, n, p };

pub const UTFBoard = struct {
    k: UTFPiece,
    q: UTFPiece,
    r: UTFPiece,
    b: UTFPiece,
    n: UTFPiece,
    p: UTFPiece,
    lsqr: ANSI,
    dsqr: ANSI,
    alt_pcs: bool = false,
    empty: u21 = ' ',
    newline: []const u8 = "\n",
    final: []const u8 = "\n\n",

    pub fn getPiece(self: UTFBoard, piece: PlayerPiece, lsqr: bool) u21 {
        const alt = !lsqr and self.alt_pcs;
        return switch (piece) {
            PlayerPiece.K => if (alt) self.k.black else self.k.white,
            PlayerPiece.Q => if (alt) self.q.black else self.q.white,
            PlayerPiece.R => if (alt) self.r.black else self.r.white,
            PlayerPiece.B => if (alt) self.b.black else self.b.white,
            PlayerPiece.N => if (alt) self.n.black else self.n.white,
            PlayerPiece.P => if (alt) self.p.black else self.p.white,
            PlayerPiece.k => if (alt) self.k.white else self.k.black,
            PlayerPiece.q => if (alt) self.q.white else self.q.black,
            PlayerPiece.r => if (alt) self.r.white else self.r.black,
            PlayerPiece.b => if (alt) self.b.white else self.b.black,
            PlayerPiece.n => if (alt) self.n.white else self.n.black,
            PlayerPiece.p => if (alt) self.p.white else self.p.black,
        };
    }
};

pub const BoardTypes = struct {
    pub const basic: UTFBoard = UTFBoard{
        .k = UTFPiece{ .white = 'K', .black = 'k' },
        .q = UTFPiece{ .white = 'Q', .black = 'q' },
        .r = UTFPiece{ .white = 'R', .black = 'r' },
        .b = UTFPiece{ .white = 'B', .black = 'b' },
        .n = UTFPiece{ .white = 'N', .black = 'n' },
        .p = UTFPiece{ .white = 'P', .black = 'p' },
        .empty = '\u{00b7}',
        .lsqr = ANSICodes.bold,
        .dsqr = ANSICodes.reset,
    };

    pub const retro: UTFBoard = UTFBoard{
        .k = UTFPiece{ .white = 'K', .black = 'k' },
        .q = UTFPiece{ .white = 'Q', .black = 'q' },
        .r = UTFPiece{ .white = 'R', .black = 'r' },
        .b = UTFPiece{ .white = 'B', .black = 'b' },
        .n = UTFPiece{ .white = 'N', .black = 'n' },
        .p = UTFPiece{ .white = 'P', .black = 'p' },
        .empty = '\u{00b7}',
        .lsqr = ANSICodes.grayOnCyan,
        .dsqr = ANSICodes.whiteOnMagenta,
    };

    pub const fancy: UTFBoard = UTFBoard{
        .k = UTFPiece{ .white = '\u{2654}', .black = '\u{265a}' },
        .q = UTFPiece{ .white = '\u{2655}', .black = '\u{265b}' },
        .r = UTFPiece{ .white = '\u{2656}', .black = '\u{265c}' },
        .b = UTFPiece{ .white = '\u{2657}', .black = '\u{265d}' },
        .n = UTFPiece{ .white = '\u{2658}', .black = '\u{265e}' },
        .p = UTFPiece{ .white = '\u{2659}', .black = '\u{265f}' },
        .lsqr = ANSICodes.blackOnWhite,
        .dsqr = ANSICodes.whiteOnBlack,
        .alt_pcs = true,
    };
};

pub const BoardArray = struct {
    array: [64]u21,
    board: UTFBoard,

    pub fn init(board: UTFBoard) BoardArray {
        var arr: [64]u21 = undefined;
        for (&arr) |*item| {
            item.* = board.empty;
        }
        return BoardArray{
            .array = arr,
            .board = board,
        };
    }

    pub fn update(self: *BoardArray, bits: u64, piece: PlayerPiece) void {
        var bbs = BitBoardSerializer.init(bits);
        while (bbs.next()) |pos| {
            const lsqr = posIsLightSquare(@truncate(pos));
            self.array[pos] = self.board.getPiece(piece, lsqr);
        }
    }

    pub fn printTo(self: *BoardArray, writer: anytype) !void {
        for (0..64) |i| {
            const row: u6 = @truncate(7 - (i / 8));
            const col: u6 = @truncate(i % 8);
            const pos: u6 = (row * 8 + col);
            const ansi = if (posIsLightSquare(pos)) self.board.lsqr else self.board.dsqr;
            if (col == 0 and i != 0) std.debug.print("{s}", .{self.board.newline});
            var str: [4]u8 = undefined;
            const length = std.unicode.utf8Encode(self.array[pos], &str) catch unreachable;
            try writer.print("{s}{s} {s}", .{ ansi.prefix, str[0..length], ansi.postfix });
        }
        try writer.print("{s}", .{self.board.final});
    }

    pub fn print(self: *BoardArray) void {
        self.printTo(std.io.getStdErr().writer()) catch unreachable;
    }
};

pub fn printBitsTo(writer: anytype, bits: u64, board: UTFBoard, piece: PlayerPiece) !void {
    var repr = BoardArray.init(board);
    repr.update(bits, piece);
    try repr.printTo(writer);
}

pub fn printBits(bits: u64, board: UTFBoard, piece: PlayerPiece) void {
    printBitsTo(std.io.getStdErr().writer(), bits, board, piece) catch unreachable;
}

pub const BoardState = struct {
    pieces: [6]u64,
    player: [2]u64,
    castling: u64,
    enpassant: u64,
    turn: Player,
    halfmove: u32,
    fullmove: u32,

    pub fn init() BoardState {
        var pieces = [6]u64{
            get(BB.E1) | get(BB.E8), // k
            get(BB.D1) | get(BB.D8), // q
            get(BB.A1) | get(BB.H1) | get(BB.A8) | get(BB.H8), // r
            get(BB.C1) | get(BB.F1) | get(BB.C8) | get(BB.F8), // b
            get(BB.B1) | get(BB.G1) | get(BB.B8) | get(BB.G8), // n
            get(BB._2) | get(BB._7), // p
        };
        var player = [2]u64{
            get(BB._1) | get(BB._2), // white
            get(BB._7) | get(BB._8), // black
        };
        return BoardState{ .pieces = pieces, .player = player, .castling = CORNERS, .enpassant = EMPTY, .turn = Player.white, .halfmove = 0, .fullmove = 0 };
    }

    pub fn occ(self: *BoardState) u64 {
        return occFromArray(self.pieces);
    }

    pub fn getPiece(self: *BoardState, piece: Piece) u64 {
        return self.pieces[@intFromEnum(piece)];
    }

    pub fn getPlayerPiece(self: *BoardState, piece: PlayerPiece) u64 {
        const enumint = @intFromEnum(piece);
        var pl = self.player[enumint / 6];
        var pc = self.pieces[enumint % 6];
        return pl & pc;
    }

    pub fn toPlayerPieceArray(self: *BoardState) [12]u64 {
        var result: [12]u64 = undefined;
        for (0..12) |i| {
            const pl: PlayerPiece = @enumFromInt(i);
            result[i] = self.getPlayerPiece(pl);
        }
        return result;
    }

    pub fn toBoardArray(self: *BoardState, board: UTFBoard) BoardArray {
        var ba = BoardArray.init(board);
        for (0..12) |i| {
            const pl: PlayerPiece = @enumFromInt(i);
            ba.update(self.getPlayerPiece(pl), pl);
        }
        return ba;
    }
};

pub fn main() !void {
    var bs = BoardState.init();
    var ba = bs.toBoardArray(BoardTypes.fancy);
    ba.print();

    printBits(0x4020100804020100, BoardTypes.fancy, PlayerPiece.P);

    // var bb = get(BB.center);
    // var bb2 = setPos(bb, 44);
    // printBits(bb2, BoardTypes.simple, PieceType.P);
    // var rep = BoardArray.init(BoardTypes.retro);
    // rep.update(get(BB._2), PlayerPiece.P);
    // rep.update(get(BB._7), PlayerPiece.p);
    // rep.update(get(BB.A1) | get(BB.H1), PlayerPiece.R);
    // rep.update(get(BB.A8) | get(BB.H8), PlayerPiece.r);
    // rep.print();

    // var brd = BoardTypes.fancy;
    // std.debug.print("{s}\n", .{brd.k.dchr});
    // var pcs = @as(u32, @bitCast(UnicodePiece.B));
    // std.debug.print("{x}\n", .{pcs});
    // var utf = UTF8.init(&UnicodePiece.Q);
    // std.debug.print("{s}", .{utf.sym});
    // var str = "this|is|a|test";
    // var chk = std.mem.split(u8, str, "|");
    // std.debug.print("{s}", .{@typeName(@TypeOf(chk))});
}
