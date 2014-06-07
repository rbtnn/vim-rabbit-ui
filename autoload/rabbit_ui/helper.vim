
function! rabbit_ui#helper#id()
  return 'rabbit-ui'
endfunction
function! rabbit_ui#helper#exception(msg)
  throw printf('[%s] %s', rabbit_ui#helper#id(), a:msg)
endfunction
function! rabbit_ui#helper#get_componentname_list()
  let r = split(&runtimepath, ',')
  call map(r, "globpath(v:val, 'autoload/rabbit_ui/components/*.vim')")
  call map(r , 'split(v:val, "\n")')
  call filter(r, '!empty(v:val)')

  let xs = []
  for path_list in r
    for path in path_list
      let xs += [ matchstr(tr(path, '\', '/'), '/\zs\i\+\ze\.vim$') ]
    endfor
  endfor
  return xs
endfunction
function! rabbit_ui#helper#set_common_configs(config)
  let config = a:config

  let config['box_top'] = abs(get(config, 'box_top', &lines / 4 * 1))
  let config['box_bottom'] = abs(get(config, 'box_bottom', &lines / 4 * 3))
  if config['box_bottom'] < config['box_top']
    call rabbit_ui#helper#exception('rabbit_ui#choices: box_top is larger than box_bottom.')
  endif

  let config['box_left'] = abs(get(config, 'box_left', &columns / 4 * 1))
  let config['box_right'] = abs(get(config, 'box_right', &columns / 4 * 3))
  if config['box_right'] < config['box_left']
    call rabbit_ui#helper#exception('rabbit_ui#choices: box_left is larger than box_right.')
  endif

  let config['box_width'] = config['box_right'] - config['box_left'] + 1
  let config['box_height'] = config['box_bottom'] - config['box_top'] + 1

  call rabbit_ui#helper#init_highlights({})

  return config
endfunction
" text
function! s:padding_right_space(text, width)
  return a:text . repeat(' ', a:width - strdisplaywidth(a:text))
endfunction
function! rabbit_ui#helper#redraw_line(lines, line_num, box_left, text)
  let orgline = a:lines[(a:line_num - 1)]
  let line = s:padding_right_space(orgline, &columns)
  let str = rabbit_ui#helper#smart_split(line, a:box_left)[0]
  let str .= a:text
  let str .= line[(strdisplaywidth(str)):]
  if orgline isnot str
    let a:lines[(a:line_num - 1)] = str
  endif
endfunction
function! rabbit_ui#helper#smart_split(str, boxwidth, ...)
  let is_wrap = 0 < a:0 ? a:1 : &wrap
  let lines = []

  let cs = split(a:str, '\zs')
  let cs_index = 0

  if a:boxwidth isnot 0
    let text = ''
    while cs_index < len(cs)
      if cs[cs_index] is "\n"
        let text = s:padding_right_space(text, a:boxwidth)
        let lines += [text]
        let text = ''
      elseif strdisplaywidth(text . cs[cs_index]) < a:boxwidth
        let text .= cs[cs_index]
      elseif strdisplaywidth(text . cs[cs_index]) == a:boxwidth
        let text .= cs[cs_index]
        let lines += [text]
        if is_wrap
          let text = ''
        else
          while get(cs, cs_index, "\n") isnot "\n"
            let cs_index += 1
          endwhile
          continue
        endif
      elseif strdisplaywidth(text . cs[cs_index]) > a:boxwidth
        let text .= ' '
        let lines += [text]
        if is_wrap
          let text = cs[cs_index]
        else
          while get(cs, cs_index, "\n") isnot "\n"
            let cs_index += 1
          endwhile
          continue
        endif
      endif
      let cs_index += 1
    endwhile
    let text .= repeat(' ', a:boxwidth - strdisplaywidth(text))
    let lines += [text]
  else
    let lines += ['']
  endif

  return lines
endfunction
" layout
function! rabbit_ui#helper#layout_1(context_list)
  let context_list = a:context_list
  let size = len(context_list)
  let width = { 'start' : &columns * 1 / 4, 'last' : &columns * 3 / 4 }
  let height = { 'start' : &lines * 1 / 4, 'last' : &lines * 3 / 4 }

  let splited_col_size = 1
  while splited_col_size * splited_col_size < size
    let splited_col_size += 1
  endwhile

  let splited_row_size = 1
  while splited_row_size * splited_col_size < size
    let splited_row_size += 1
  endwhile

  for row in range(0, splited_row_size - 1)
    for col in range(0, splited_col_size - 1)
      let index = row * splited_col_size + col
      if index < size
        let context = context_list[index]
        let config = context['config']

        let box_height = (height.last - height.start) / splited_row_size
        let config['box_top'] = height.start + row * (box_height + 1)
        let config['box_bottom'] = config['box_top'] + (box_height - 1)

        let box_width = (width.last - width.start) / splited_col_size
        let config['box_left'] = width.start + col * (box_width + 1)
        let config['box_right'] = config['box_left'] + (box_width - 1)

        call rabbit_ui#components#{context['component_name']}#init(context)
      endif
    endfor
  endfor

endfunction
" gridview helper
function! rabbit_ui#helper#to_alphabet_title(n)
  let n = a:n
  let str = ''
  while 1
    let str = nr2char(0x41 + n % 26) . str
    let n = n / 26 - 1
    if n < 0
      break
    endif
  endwhile
  return str
endfunction
" highlight
function! rabbit_ui#helper#clear_matches(context)
  let config = a:context['config']
  for id in get(config, 'matches', [])
    call matchdelete(id)
  endfor
  let config['matches'] = []
endfunction
function! rabbit_ui#helper#set_highlight(groupname, config, line, col, size)
  let config = a:config
  execute printf('highlight! default link %s %s', a:groupname, a:groupname)
  if !has_key(config, 'matches')
    let config['matches'] = []
  endif
  let config['matches'] += [ matchadd(a:groupname, printf('\%%%dl\%%%dv.\{%d,%d}', a:line, a:col, a:size, a:size)) ]
endfunction
function! rabbit_ui#helper#init_highlights(highlights)
  let highlights = a:highlights

  let default_table = {
        \   'rabbituiTitleLineActive' : {
        \     'guifg' : '#ffffff', 'guibg' : '#aaaaee', 'gui' : 'bold',
        \     'ctermfg' : 'White', 'ctermbg' : 'Blue', 'cterm' : 'bold',
        \   },
        \   'rabbituiTitleLineNoActive' : {
        \     'guifg' : '#ffffff', 'guibg' : '#555555', 'gui' : 'bold',
        \     'ctermfg' : 'White', 'ctermbg' : 'Blue', 'cterm' : 'bold',
        \   },
        \   'rabbituiTextLinesEven' : {
        \     'guifg' : '#000000', 'guibg' : '#ddddff', 'gui' : 'none',
        \     'ctermfg' : 'Black', 'ctermbg' : 'LightRed', 'cterm' : 'bold',
        \   },
        \   'rabbituiTextLinesOdd' : {
        \     'guifg' : '#000000', 'guibg' : '#ffffff', 'gui' : 'none',
        \     'ctermfg' : 'Black', 'ctermbg' : 'White', 'cterm' : 'bold',
        \   },
        \   'rabbituiSelectedItemActive' : {
        \     'guifg' : '#ffff00', 'guibg' : '#888888', 'gui' : 'bold',
        \     'ctermfg' : 'Yellow', 'ctermbg' : 'Gray', 'cterm' : 'bold',
        \   },
        \   'rabbituiSelectedItemNoActive' : {
        \     'guifg' : '#000000', 'guibg' : '#bbbbbb', 'gui' : 'none',
        \     'ctermfg' : 'Black', 'ctermbg' : 'LightGray', 'cterm' : 'bold',
        \   },
        \ }
  for x in keys(default_table)
    execute printf('highlight! %s guifg=%s guibg=%s gui=%s ctermfg=%s ctermbg=%s cterm=%s',
          \   x,
          \   get(get(highlights, x, {}), 'guifg', default_table[x]['guifg']),
          \   get(get(highlights, x, {}), 'guibg', default_table[x]['guibg']),
          \   get(get(highlights, x, {}), 'gui', default_table[x]['gui']),
          \   get(get(highlights, x, {}), 'ctermfg', default_table[x]['ctermfg']),
          \   get(get(highlights, x, {}), 'ctermbg', default_table[x]['ctermbg']),
          \   get(get(highlights, x, {}), 'cterm', default_table[x]['cterm'])
          \ )
  endfor
endfunction


