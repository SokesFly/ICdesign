# -*- coding: utf-8 -*-

from logging import getLogger
from completor import Completor, vim
import subprocess
import sys

logger = getLogger('completor')

class Shell(Completor):
    filetype = 'shell'
    sync = True

    def parse(self, base):
        if not self.ft or not base:
            return []

        get_shell_commands = vim.Function('completor_shell#get_shell_commands')
        commands = get_shell_commands()

        candidates = []

        token = self.input_data.split()[-1]
        adjust_token = vim.Function('completor_shell#adjust_token')
        token = adjust_token(token)

        for command in commands:
            try:
                replaced = command.replace('${token}', token).replace('${filetype}', self.ft)
                output = subprocess.check_output(replaced, shell=True)
            except:
                logger.error(sys.exc_info())
                return []

            for line in output.splitlines():
                candidates.append({'abbr': line, 'word': line})

        return candidates
