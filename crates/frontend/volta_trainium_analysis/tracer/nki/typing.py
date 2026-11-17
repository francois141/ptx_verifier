"""The stand-in `nki.typing`: its annotations carry no meaning for a traced call."""


class _Annotation:
    def __getitem__(self, _):
        return self


tensor = _Annotation()
