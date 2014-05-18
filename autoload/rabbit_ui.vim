
scriptencoding utf-8

" Helper Functions
function! s:exception(msg)
  throw printf('[rabbit-ui] %s', a:msg)
endfunction
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
function! s:redraw_line(line_num, box_left, text)
  let line = getline(a:line_num)
  let line .= repeat(' ', &columns - strdisplaywidth(line))
  let str = s:smart_split(line, a:box_left)[0]
  let str .= a:text
  let str .= line[(strdisplaywidth(str)):]
  call setline(a:line_num, str)
endfunction
function! s:smart_split(str, boxwidth)
  let lines = []

  let cs = split(a:str, '\zs')
  let cs_index = 0

  if a:boxwidth isnot 0
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
        let text = cs[cs_index]
        let cs_index += 1
      endif
    endwhile
    let text .= repeat(' ', a:boxwidth - strdisplaywidth(text))
    let lines += [text]
  else
    let lines += ['']
  endif


  return lines
endfunction
function! s:wrapper(funcname, option)
  let saved_hlsearch = &hlsearch
  let saved_currtabindex = tabpagenr()
  let saved_titlestring = &titlestring
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
    setfiletype rabbit-ui
    let &l:titlestring = "[rabbit-ui] " . a:option['title']

    unlet rtn_value
    let rtn_value = call(function(a:funcname), [extend(a:option, {
          \   'background_lines' : background_lines,
          \ })])
  finally
    tabclose
    let &l:hlsearch = saved_hlsearch
    let &l:titlestring = saved_titlestring
    execute 'tabnext' . saved_currtabindex
    redraw
  endtry

  return rtn_value
endfunction

" MessageBox
function! rabbit_ui#messagebox(title, text, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}

  let option['box_top'] = abs(get(option, 'box_top', &lines / 4 * 1))
  let option['box_bottom'] = abs(get(option, 'box_bottom', &lines / 4 * 3))
  if option['box_bottom'] < option['box_top']
    call s:exception('rabbit_ui#choices: box_top is larger than box_bottom.')
  endif
  let option['box_left'] = abs(get(option, 'box_left', &columns / 4 * 0))
  let option['box_right'] = abs(get(option, 'box_right', &columns / 4 * 3))
  if option['box_right'] < option['box_left']
    call s:exception('rabbit_ui#choices: box_left is larger than box_right.')
  endif

  let option['box_width'] = option['box_right'] - option['box_left'] + 1
  let option['box_height'] = option['box_bottom'] - option['box_top'] + 1
  let option['title'] = s:smart_split(a:title, option['box_width'])[0]
  let option['text_lines'] = s:smart_split(a:text, option['box_width'])

  return s:wrapper('s:wrapper_f_messagebox', option)
endfunction
function! s:wrapper_f_messagebox(option)
  let background_lines = get(a:option, 'background_lines', [])


  call s:set_highlight()

  while 1
    % delete _
    silent! put=background_lines
    1 delete _
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

  for line_num in range(box_top + 1, box_bottom + 1)
    let text = get([title] + text_lines, (line_num - (box_top + 1)), repeat(' ', box_width))

    call s:redraw_line(line_num, box_left, text)

    let len = len(substitute(text, ".", "x", "g"))

    if line_num is (box_top + 1)
      execute 'syntax match rabbituiTitleLine /^\%' . line_num . 'l.\{0,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    else
      execute 'syntax match rabbituiTextLines /^\%' . line_num . 'l.\{0,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    endif

  endfor

  return 0
endfunction

" Choices
function! rabbit_ui#choices(title, items, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}

  let option['box_top'] = abs(get(option, 'box_top', &lines / 4 * 1))
  let option['box_bottom'] = abs(get(option, 'box_bottom', &lines / 4 * 3))
  if option['box_bottom'] < option['box_top']
    call s:exception('rabbit_ui#choices: box_top is larger than box_bottom.')
  endif
  let option['box_left'] = abs(get(option, 'box_left', &columns / 4 * 0))
  let option['box_right'] = abs(get(option, 'box_right', &columns / 4 * 3))
  if option['box_right'] < option['box_left']
    call s:exception('rabbit_ui#choices: box_left is larger than box_right.')
  endif

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


  call s:set_highlight()

  while 1

    % delete _
    silent! put=background_lines
    1 delete _

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

  for line_num in range(box_top + 1, box_bottom + 1)
    let text = get([title] + text_items, (line_num - (box_top + 1)), repeat(' ', box_width))

    call s:redraw_line(line_num, box_left, text)

    let len = len(substitute(text, ".", "x", "g"))

    if line_num is (box_top + 1)
      execute 'syntax match rabbituiTitleLine /^\%' . line_num . 'l.\{0,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    elseif line_num is (box_top + 1) + 1 + index - display_offset
      execute 'syntax match rabbituiSelectedItem /^\%' . line_num . 'l.\{0,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    else
      execute 'syntax match rabbituiTextLines /^\%' . line_num . 'l.\{0,' . box_left . '}\zs.\{1,' . len . '}\ze.*$/ containedin=ALL'
    endif
  endfor

  return index
endfunction

function! rabbit_ui#_testcase()
  let option = {
        \   'box_top' : 0,
        \   'box_bottom' : 20,
        \   'box_right' : 25,
        \   'box_left' : 0,
        \ }
  let en = [
        \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
        \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
        \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
        \ 'Elixir', 'Ada', 'Type Script', ]
  let ja = [
        \ '英語', '中国語', '韓国語', 'フランス語', 'ロシア語', 'ポルトガル語', 'スペイン語',
        \ 'ドイツ語', 'イタリア語', ]

  let testcase_count = 1
  for lang_list in [ja,en]
    let items = repeat(lang_list, 100)
    for item_index in range(0, len(items) - 1)
      let items[item_index] = printf('%d. %s', item_index, items[item_index])
    endfor
    let text = join(items, ', ')

    call rabbit_ui#messagebox(printf('testcase:%d (MessageBox)', testcase_count), text)
    let testcase_count += 1
    call rabbit_ui#messagebox(printf('testcase:%d (MessageBox)', testcase_count), text, option)
    let testcase_count += 1
    call rabbit_ui#choices(printf('testcase:%d (Choices)', testcase_count), items)
    let testcase_count += 1
    call rabbit_ui#choices(printf('testcase:%d (Choices)', testcase_count), items, option)
    let testcase_count += 1
  endfor
endfunction

