if exists('g:loaded_ale_linters_elm_make')
  finish
endif

let g:loaded_ale_linters_elm_make = 1

function! ale_linters#elm#make#Handle(buffer, lines)
  let l:output = []
  "for l:line in a:lines
  "echomsg l:line
  "endfor
  let l:show = count(a:lines, "Successfully generated /dev/null")
  "echomsg l:show
  if l:show == 0 
    let l:errors = []
    let l:joined = join(a:lines, "")
    let l:decoded = json_decode(l:joined)
    if type(l:decoded) == type([])
      call extend(l:errors, l:decoded)
      for l:error in l:errors
        let l:qfEntry = {
              \   'lnum': l:error.region.start.line,
              \   'vcol': 0,
              \   'col': l:error.region.start.column,
              \   'text': l:error.overview . '   ' . l:error.details,
              \   'type': l:error.type == 'error' ? 'E' : 'W',
              \}
        if l:error.file =~ '/tmp/'
          let l:qfEntry["filname"] = l:error.file
        else
          let l:qfEntry["bufnr"] = a:buffer
        endif
        " vcol is Needed to indicate that the column is a character.
        " help setqflist
        call add(l:output, l:qfEntry)
      endfor
    endif
  endif
  return l:output
endfunction

call ale#linter#Define('elm', {
      \   'name': 'elm-make',
      \   'executable': 'elm-make',
      \   'command': g:ale#util#stdin_wrapper . ' .elm elm-make --warn --report json --output ' . g:ale#util#nul_file,
      \   'callback': 'ale_linters#elm#make#Handle'
      \})


"\   'command': 'echo '."'".'[{"tag":"MISSING DEFINITION","overview":"There is a type annotation for `test` but there is no corresponding definition!","subregion":null,"details":"Directly below the type annotation, put a definition like:\n\n    test = 42","region":{"start":{"line":18,"column":1},"end":{"line":18,"column":11}},"type":"error","file":"app/elm/Main.elm"}]'."'",
