import sys

print(
    f"Должен показать путь к backend/.venv/bin/python: {sys.executable=}"
)  # Должен показать путь к backend/.venv/bin/python
a = {"a": 1, "b": 2, "c": 3, "d": 4}


class Test:
    def __init__(self, a, b):
        self.a, self.b = a, b
        self.aa = {
            "a": "apple",
            "b": "bottom",
            "c": "current",
            "d": "drop out",
            "e": "asdf;ljsdf;lkajsfd;lasdjf;asldkfja;sdlfk",
        }
