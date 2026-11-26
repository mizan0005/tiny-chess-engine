import unittest
import chess
from main import choose_move, evaluate, set_position

class EngineTests(unittest.TestCase):
    def test_start_position_returns_legal_move(self):
        board = chess.Board()
        move = choose_move(board, 2)
        self.assertIsNotNone(move)
        self.assertIn(move, board.legal_moves)

    def test_search_is_deterministic(self):
        board = chess.Board()
        self.assertEqual(choose_move(board, 2), choose_move(board, 2))

    def test_mate_position_has_no_move(self):
        board = chess.Board("7k/6Q1/6K1/8/8/8/8/8 b - - 0 1")
        self.assertTrue(board.is_checkmate())
        self.assertIsNone(choose_move(board, 2))

    def test_position_command_applies_moves(self):
        board = chess.Board()
        set_position(board, ["startpos", "moves", "e2e4", "e7e5"])
        self.assertEqual(board.fullmove_number, 2)
        self.assertEqual(board.turn, chess.WHITE)

    def test_initial_evaluation_is_balanced(self):
        self.assertEqual(evaluate(chess.Board()), 0)

if __name__ == "__main__":
    unittest.main()
