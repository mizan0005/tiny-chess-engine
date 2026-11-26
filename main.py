#!/usr/bin/env python3
"""Tiny deterministic chess engine with a small UCI interface."""
import sys
import chess

VALUES = {chess.PAWN: 100, chess.KNIGHT: 320, chess.BISHOP: 330,
          chess.ROOK: 500, chess.QUEEN: 900, chess.KING: 0}
MATE = 100000

def evaluate(board):
    if board.is_checkmate():
        return -MATE
    if board.is_game_over(claim_draw=True):
        return 0
    score = 0
    for kind, value in VALUES.items():
        score += len(board.pieces(kind, chess.WHITE)) * value
        score -= len(board.pieces(kind, chess.BLACK)) * value
    for sq in chess.SQUARES:
        piece = board.piece_at(sq)
        if piece and piece.piece_type in (chess.KNIGHT, chess.BISHOP, chess.PAWN):
            f, r = chess.square_file(sq), chess.square_rank(sq)
            bonus = int((6 - abs(3.5-f) - abs(3.5-r)) *
                        (2 if piece.piece_type == chess.PAWN else 3))
            score += bonus if piece.color else -bonus
    return score if board.turn else -score

def ordered_moves(board):
    def order(move):
        victim = board.piece_at(move.to_square)
        attacker = board.piece_at(move.from_square)
        captured = VALUES[victim.piece_type] if victim else (
            VALUES[chess.PAWN] if board.is_en_passant(move) else 0)
        attacking = VALUES[attacker.piece_type] if attacker else 0
        return (captured * 10 - attacking + VALUES.get(move.promotion, 0), move.uci())
    return sorted(board.legal_moves, key=order, reverse=True)

def negamax(board, depth, alpha, beta, ply=0):
    if board.is_checkmate():
        return -MATE + ply, None
    if board.is_game_over(claim_draw=True):
        return 0, None
    if depth <= 0:
        return evaluate(board), None
    best, best_move = -2 * MATE, None
    for move in ordered_moves(board):
        board.push(move)
        score, _ = negamax(board, depth-1, -beta, -alpha, ply+1)
        score = -score
        board.pop()
        if score > best:
            best, best_move = score, move
        alpha = max(alpha, score)
        if alpha >= beta:
            break
    return best, best_move

def choose_move(board, depth=3):
    if not board.legal_moves:
        return None
    return negamax(board, max(1, min(int(depth), 6)), -2*MATE, 2*MATE)[1]

def set_position(board, tokens):
    if not tokens:
        return
    if tokens[0] == "startpos":
        board.reset()
        rest = tokens[1:]
    elif tokens[0] == "fen":
        marker = tokens.index("moves") if "moves" in tokens else len(tokens)
        board.set_fen(" ".join(tokens[1:marker]))
        rest = tokens[marker:]
    else:
        return
    if rest and rest[0] == "moves":
        rest = rest[1:]
    for move in rest:
        board.push_uci(move)

def uci_loop():
    board = chess.Board()
    for raw in sys.stdin:
        parts = raw.strip().split()
        if not parts:
            continue
        try:
            cmd = parts[0]
            if cmd == "uci":
                print("id name TinyDeterministic")
                print("id author mizan0005")
                print("uciok", flush=True)
            elif cmd == "isready":
                print("readyok", flush=True)
            elif cmd == "ucinewgame":
                board.reset()
            elif cmd == "position":
                set_position(board, parts[1:])
            elif cmd == "go":
                depth = int(parts[parts.index("depth")+1]) if "depth" in parts else 3
                move = choose_move(board, depth)
                print("bestmove " + (move.uci() if move else "0000"), flush=True)
            elif cmd == "quit":
                break
        except (ValueError, IndexError, chess.InvalidMoveError, chess.IllegalMoveError):
            print("info string invalid command or position", flush=True)

if __name__ == "__main__":
    uci_loop()
