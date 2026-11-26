# Tiny Chess Engine

A compact, deterministic chess engine written for Python 3.13. It uses [python-chess](https://python-chess.readthedocs.io/) for legal move generation and implements its own material/centralization evaluation and alpha-beta negamax search.

## Features

- UCI command loop: uci, isready, ucinewgame, position, go depth N, quit
- Deterministic move ordering and search
- Alpha-beta pruning with bounded search depth (1–6)
- Checkmate and draw detection
- No paid APIs, hosted models, or network calls at runtime

## Requirements

- Python 3.13
- Install dependencies: python -m pip install -r requirements.txt

## Run

    python main.py

Then send UCI commands, one per line, for example:

    uci
    isready
    position startpos
    go depth 3
    quit

The engine responds with bestmove <uci-move>. It can also be driven by a UCI-compatible chess GUI that can launch a local Python command.

## Tests

    python -m unittest discover -s tests -v
    python -m py_compile main.py

GitHub Actions runs the test suite on pushes and pull requests using Python 3.13.

## Scope

This is a small baseline engine, not a grandmaster-strength engine. Search strength depends on depth and available compute; the default search depth is 3.
