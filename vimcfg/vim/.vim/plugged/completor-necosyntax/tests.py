import sys
import types


class MockComletor(object):
    pass


class Vim(object):
    def Function(self, func):
        return lambda: {
            b'a': {b'word': b'hello', b'description': b'hello world'},
            b'b': {b'word': b'def', b'description': b'def world'},
            b'c': {b'word': b'defm', b'description': b'hello def'},
        }


sys.path.append('./pythonx')
completor = types.ModuleType('completor')
completor.Completor = MockComletor
completor.vim = Vim()
sys.modules['completor'] = completor


from completor_necosyntax import Necosyntax  # noqa


def test_parse():
    neco = Necosyntax()
    neco.ft = 'bat'
    neco.input_data = 'xcopy'

    assert neco.parse('xcopy') == [
        {'dup': 1, 'menu': b'[S]', 'word': b'xcopy'},
    ]
