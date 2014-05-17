
" Helper Funcions
function! s:set_highlight()
  highlight! default link rabbituiTitleLine     Menu
  highlight! default link rabbituiTextLines     Pmenu
  highlight! default link rabbituiSelectedItem  PmenuSel
endfunction
function! s:clear_highlight()
  syntax clear rabbituiTitleLine
  syntax clear rabbituiSelectedItem
  syntax clear rabbituiTextLines
endfunction
function! s:smart_split(str, boxwidth)
  let lines = []

  let cs = split(a:str, '\zs')
  let cs_index = 0

  let text = ''
  while cs_index < len(cs)
    if strdisplaywidth(text . cs[cs_index]) == a:boxwidth
      let text .= cs[cs_index]
      let cs_index += 1
      let lines += [text]
      let text = ''
    elseif strdisplaywidth(text . cs[cs_index]) < a:boxwidth
      let text .= cs[cs_index]
      let cs_index += 1
    elseif strdisplaywidth(text . cs[cs_index]) > a:boxwidth
      let text .= ' '
      let lines += [text]
      let text = ''
    else
      let lines += [text]
      let text = ''
    endif
  endwhile
  let text .= repeat(' ', a:boxwidth - strdisplaywidth(text))
  let lines += [text]

  return lines
endfunction
function! s:wrapper(funcname, option)
  let saved_laststatus = &laststatus
  let saved_showtabline = &showtabline
  let saved_hlsearch = &hlsearch
  let saved_currtabindex = tabpagenr()
  let rtn_value = ''
  try

    let background_lines = []
    for line in getline(line('w0'), line('w0') + &lines) + repeat([''], &lines)
      let background_lines += [
            \ join(map(split(line,'\zs'), 'strdisplaywidth(v:val) isnot 1 ? ".." : v:val'), '')
            \ ]
    endfor

    tabnew
    normal gg

    setlocal nolist
    setlocal nospell
    setlocal nonumber
    setlocal nohlsearch
    setlocal buftype=nofile nobuflisted noswapfile bufhidden=hide
    let &l:laststatus = 0
    let &l:showtabline = 0

    unlet rtn_value
    let rtn_value = call(function(a:funcname), [extend(a:option, {
          \   'background_lines' : background_lines,
          \ })])
  finally
    tabclose
    let &l:laststatus = saved_laststatus
    let &l:showtabline = saved_showtabline
    let &l:hlsearch = saved_hlsearch
    execute 'tabnext' . saved_currtabindex
    redraw
  endtry

  return rtn_value
endfunction

" MessageBox
function! rabbit_ui#messagebox(title, text, ...)
  let option = {}
  let option['box_top'] = &lines / 4 * 1
  let option['box_bottom'] = &lines / 4 * 3
  let option['box_left'] = &columns / 4 * 1
  let option['box_right'] = &columns / 4 * 3
  let option['box_width'] = option['box_right'] - option['box_left'] + 1
  let option['box_height'] = option['box_bottom'] - option['box_top'] + 1
  let option['title'] = s:smart_split(a:title, option['box_width'])[0]
  let option['text_lines'] = s:smart_split(a:text, option['box_width'])

  return s:wrapper('s:wrapper_f_messagebox', option)
endfunction
function! s:wrapper_f_messagebox(option)
  let background_lines = get(a:option, 'background_lines', [])

  % delete _
  silent! put=background_lines
  1 delete _

  call s:set_highlight()

  while 1

    let rtn_value = s:redraw_messagebox(a:option)

    redraw

    let c_nr = getchar()

    if char2nr('q') is c_nr
      break
    endif

  endwhile

  return rtn_value
endfunction
function! s:redraw_messagebox(option)
  let title = a:option['title']
  let text_lines = a:option['text_lines']
  let box_left = a:option['box_left']
  let box_right =  a:option['box_right']
  let box_top = a:option['box_top']
  let box_bottom =  a:option['box_bottom']
  let box_width = a:option['box_width']

  call s:clear_highlight()

  for line_num in range(box_top, box_bottom)
    let text = get([title] + text_lines, (line_num - box_top), repeat(' ', box_width))

    let str = getline(line_num)
    let str = str . repeat(' ', &columns - strdisplaywidth(str))
    let str = str[:(box_left > 0 ? box_left - 1 : 0)] . text . str[(box_right):]
    call setline(line_num, str)

    let len = len(substitute(text, ".", "x", "g"))

    if line_num is box_top
      execute 'syntax match rabbituiTitleLine /^\%' . line_num . 'l.\{1,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    else
      execute 'syntax match rabbituiTextLines /^\%' . line_num . 'l.\{1,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    endif

  endfor


  return 0
endfunction

" Choices
function! rabbit_ui#choices(title, items, ...)
  let option = {}
  let option['box_top'] = &lines / 4 * 1
  let option['box_bottom'] = &lines / 4 * 3
  let option['box_left'] = &columns / 4 * 1
  let option['box_right'] = &columns / 4 * 3
  let option['box_width'] = option['box_right'] - option['box_left'] + 1
  let option['box_height'] = option['box_bottom'] - option['box_top'] + 1
  let option['index'] = 0
  let option['display_offset'] = 0
  let option['display_start'] = 0
  let option['display_last'] = option['box_bottom'] - option['box_top'] - 1
  let option['title'] = s:smart_split(a:title, option['box_width'])[0]
  let option['text_items'] = map(a:items, 's:smart_split(v:val, option["box_width"])[0]')

  return s:wrapper('s:wrapper_f_choices', option)
endfunction
function! s:wrapper_f_choices(option)
  let background_lines = get(a:option, 'background_lines', [])

  % delete _
  silent! put=background_lines
  1 delete _

  call s:set_highlight()

  while 1
    let rtn_value = s:redraw_choices(a:option)
    redraw

    let c_nr = getchar()

    if char2nr('q') is c_nr
      break

    elseif char2nr('g') is c_nr
      let a:option['index'] = 0
      let a:option['display_offset'] = 0

    elseif char2nr('G') is c_nr
      let a:option['index'] = len(a:option['text_items']) - 1
      let a:option['display_offset'] = len(a:option['text_items']) - a:option['box_height'] + 1

    elseif char2nr('j') is c_nr
      if a:option['index'] + 1 <= len(a:option['text_items']) - 1
        let a:option['index'] += 1
      endif
      if a:option['display_last'] < a:option['index'] - a:option['display_offset']
        let a:option['display_offset'] = a:option['index'] - a:option['display_last']
      endif
    elseif char2nr('k') is c_nr
      if 0 <= a:option['index'] - 1
        let a:option['index'] -= 1
      endif
      if a:option['index'] - a:option['display_offset'] < a:option['display_start']
        let a:option['display_offset'] = a:option['index'] - a:option['display_start']
      endif
    endif
  endwhile

  return rtn_value
endfunction
function! s:redraw_choices(option)
  let box_left = a:option['box_left']
  let box_right =  a:option['box_right']
  let box_top = a:option['box_top']
  let box_bottom =  a:option['box_bottom']
  let box_width = a:option['box_width']
  let index = a:option['index']
  let display_offset = a:option['display_offset']
  let title = a:option['title']
  let text_items = a:option['text_items'][(display_offset):(display_offset + a:option['box_height'])]

  call s:clear_highlight()

  for line_num in range(box_top, box_bottom)
    let text = get([title] + text_items, (line_num - box_top), repeat(' ', box_width))

    let str = getline(line_num)
    let str = str . repeat(' ', &columns - strdisplaywidth(str))
    let str = str[:(box_left > 0 ? box_left - 1 : 0)] . text . str[(box_right + 1):]
    call setline(line_num, str)

    let len = len(substitute(text, ".", "x", "g"))

    if line_num is box_top
      execute 'syntax match rabbituiTitleLine /^\%' . line_num . 'l.\{1,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    elseif line_num is box_top + 1 + index - display_offset
      execute 'syntax match rabbituiSelectedItem /^\%' . line_num . 'l.\{1,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    else
      execute 'syntax match rabbituiTextLines /^\%' . line_num . 'l.\{1,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    endif

  endfor

  return index
endfunction


" let s:title = 'MessageBox'
" let s:text = 'Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text '
" echo rabbit_ui#messagebox(s:title, s:text)
"
" let s:title = 'Choices'
" let s:items = repeat([
"       \ 'Dart',
"       \ 'JavaScript',
"       \ 'Vim script',
"       \ 'Go',
"       \ 'C',
"       \ 'C++',
"       \ 'Java',
"       \ 'Perl',
"       \ 'Ruby',
"       \ 'Python',
"       \ 'Haskell',
"       \ 'HTML',
"       \ 'css',
"       \ 'Lisp',
"       \ 'COBOL',
"       \ 'Scheme',
"       \ 'Scala',
"       \ 'Lua',
"       \ 'CoffeeScript',
"       \ 'Common Lisp',
"       \ 'Erlang',
"       \ 'Elixir',
"       \ 'Ada',
"       \ 'Type Script',
"       \ ], 1000)
" for s:item_index in range(0, len(s:items) - 1)
"   let s:items[(s:item_index)] = printf('%d. %s', s:item_index, s:items[(s:item_index)])
" endfor
" echo rabbit_ui#choices(s:title, s:items)
