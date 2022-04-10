# -*- coding: utf-8 -*-

import logging
from completor import Completor, vim, get_encoding
from completor.compat import to_bytes, to_unicode

_cache = {}

logger = logging.getLogger('completor')


class Necosyntax(Completor):
    filetype = 'necosyntax'
    sync = True

    def __init__(self):
        super(Completor, self).__init__()
        necosyntax_init = vim.Function('necosyntax#initialize')
        necosyntax_init()

    def _get_candidates(self):
        get_candidates = vim.Function('necosyntax#gather_candidates')
        candidates = [{
            'abbr': word,
            'dup': 1,
            'menu': b'[S]'
        } for word in get_candidates()[:]]
        candidates.sort(key=lambda x: x['abbr'])
        return candidates

    def parse(self, base):
        if not self.ft or not base or base.endswith((' ', '\t')):
            return []

        if self.ft not in _cache:
            try:
                _cache[self.ft] = self._get_candidates()
            except Exception:
                _cache[self.ft] = []

        # token = base.split()[-1]
        token = to_bytes(base, get_encoding())[self.start_column():]
        token = to_unicode(token, 'utf-8')
        if len(token) < self.get_option('min_chars'):
            return []
        candidates = [dict(item) for item in _cache[self.ft]
                      if item['abbr'].startswith(token.encode('utf-8'))]

        offset = len(to_bytes(base[:-len(token)], get_encoding()))
        for c in candidates:
            c['word'] = c['abbr']
            c['offset'] = offset
        return candidates
