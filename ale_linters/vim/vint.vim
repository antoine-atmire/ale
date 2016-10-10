" Author: w0rp <devw0rp@gmail.com>, KabbAmine <amine.kabb@gmail.com>
" Description: This file adds support for checking Vim code with Vint.

if exists('g:loaded_ale_linters_vim_vint')
    finish
endif

let g:loaded_ale_linters_vim_vint = 1

function! ale_linters#vim#vint#Handle(buffer, lines) abort
    let pattern = '^\(\d\+\):\(\d\+\):\([^:]\+\):\([^:]\+\):\(.\+\)$'
    let output = []

    for line in a:lines
        let l:match = matchlist(line, pattern)

        if len(l:match) == 0
            continue
        endif

        let line = l:match[1] + 0
        let col = l:match[2] + 0
        let severity = l:match[3]
        let reference = l:match[4]
        let description = l:match[5]

        call add(output, {
        \   'bufnr': a:buffer,
        \   'lnum': line,
        \   'vcol': 0,
        \   'col': col,
        \   'text': printf('%s (see %s)', description, reference),
        \   'type': severity ==# 'error' ? 'E' : 'W',
        \   'nr': -1,
        \})
    endfor

    return output
endfunction

let s:format = '-f {line_number}:{column_number}:{severity}:{reference}:{description}'

call ale#linter#Define('vim', {
\   'name': 'vint',
\   'executable': 'vint',
\   'command': g:ale#util#stdin_wrapper . ' .vim vint -w --no-color ' . s:format,
\   'callback': 'ale_linters#vim#vint#Handle',
\})
