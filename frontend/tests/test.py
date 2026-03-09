import sys

print(f"{sys.executable=}")  # Должен показать путь к frontend/.venv/bin/python


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
