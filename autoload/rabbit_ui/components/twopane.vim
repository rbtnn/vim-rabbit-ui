
function! rabbit_ui#components#twopane#exec(A_title, A_items, B_title, B_items, option)
  let option = a:option

  let option['box_top'] = abs(get(option, 'box_top', &lines / 4 * 1))
  let option['box_bottom'] = abs(get(option, 'box_bottom', &lines / 4 * 3))
  if option['box_bottom'] < option['box_top']
    call rabbit_ui#helper#exception('rabbit_ui#choices: box_top is larger than box_bottom.')
  endif
  let option['box_left'] = abs(get(option, 'box_left', &columns / 4 * 1))
  let option['box_right'] = abs(get(option, 'box_right', &columns / 4 * 3))
  if option['box_right'] < option['box_left']
    call rabbit_ui#helper#exception('rabbit_ui#choices: box_left is larger than box_right.')
  endif

  let option['box_width'] = (option['box_right'] - option['box_left'] + 1) / 2
  let option['box_height'] = option['box_bottom'] - option['box_top'] + 1

  let option['display_start'] = 0
  let option['display_last'] = option['box_bottom'] - option['box_top'] - 1

  " A:0, B:1
  let option['A_or_B'] = 0

  let option['A_index'] = 0
  let option['A_display_offset'] = 0
  let option['A_title'] = rabbit_ui#helper#smart_split(a:A_title, option['box_width'])[0]
  let option['A_text_items'] = map(a:A_items, 'rabbit_ui#helper#smart_split(v:val, option["box_width"])[0]')

  let option['B_index'] = 0
  let option['B_display_offset'] = 0
  let option['B_title'] = rabbit_ui#helper#smart_split(a:B_title, option['box_width'])[0]
  let option['B_text_items'] = map(a:B_items, 'rabbit_ui#helper#smart_split(v:val, option["box_width"])[0]')

  return rabbit_ui#helper#wrapper(function('s:wrapper_f_twopane'), option)
endfunction

function! s:wrapper_f_twopane(option)
  let background_lines = get(a:option, 'background_lines', [])

  while 1
    % delete _
    silent! put=background_lines
    1 delete _

    let rtn_value = s:redraw_twopane(a:option)
    redraw

    let c_nr = getchar()

    let prefix = a:option['A_or_B'] ? 'B_' : 'A_'

    if char2nr('q') is c_nr
      break

    elseif char2nr('g') is c_nr
        let a:option[prefix . 'index'] = 0
        let a:option[prefix . 'display_offset'] = 0

    elseif char2nr('G') is c_nr
        let a:option[prefix . 'index'] = len(a:option[prefix . 'text_items']) - 1
        let mod = len(a:option[prefix . 'text_items']) / a:option['box_height']
        let a:option[prefix . 'display_offset'] = mod

    elseif char2nr('j') is c_nr
      if a:option[prefix . 'index'] + 1 <= len(a:option[prefix . 'text_items']) - 1
        let a:option[prefix . 'index'] += 1
      endif
      if a:option['display_last'] < a:option[prefix . 'index'] - a:option[prefix . 'display_offset']
        let a:option[prefix . 'display_offset'] = a:option[prefix . 'index'] - a:option['display_last']
      endif

    elseif char2nr('k') is c_nr
      if 0 <= a:option[prefix .'index'] - 1
        let a:option[prefix . 'index'] -= 1
      endif
      if a:option[prefix . 'index'] - a:option[prefix . 'display_offset'] < a:option['display_start']
        let a:option[prefix . 'display_offset'] = a:option[prefix . 'index'] - a:option['display_start']
      endif

    elseif char2nr('h') is c_nr
        let a:option['A_or_B'] = 0

    elseif char2nr('l') is c_nr
        let a:option['A_or_B'] = 1

    endif
  endwhile

  return rtn_value
endfunction
function! s:redraw_twopane(option)
  let box_left = a:option['box_left']
  let box_right =  a:option['box_right']
  let box_top = a:option['box_top']
  let box_bottom =  a:option['box_bottom']
  let box_width = a:option['box_width']

  let A_index = a:option['A_index']
  let A_display_offset = a:option['A_display_offset']
  let A_title = a:option['A_title']
  let A_text_items = a:option['A_text_items'][(A_display_offset):(A_display_offset + a:option['box_height'])]

  let B_index = a:option['B_index']
  let B_display_offset = a:option['B_display_offset']
  let B_title = a:option['B_title']
  let B_text_items = a:option['B_text_items'][(B_display_offset):(B_display_offset + a:option['box_height'])]

  call rabbit_ui#helper#clear_highlights()

  for line_num in range(box_top + 1, box_bottom + 1)

    " A
    let A_text = get([A_title] + A_text_items, (line_num - (box_top + 1)), repeat(' ', box_width))
    call rabbit_ui#helper#redraw_line(line_num, box_left, A_text)
    let A_len = len(substitute(A_text, ".", "x", "g"))
    if line_num is (box_top + 1)
      call rabbit_ui#helper#set_highlight('rabbituiTitleLine', line_num, box_left + 1, A_len)
    elseif line_num is (box_top + 1) + 1 + A_index - A_display_offset
      call rabbit_ui#helper#set_highlight('rabbituiSelectedItem', line_num, box_left + 1, A_len)
    else
      call rabbit_ui#helper#set_highlight('rabbituiTextLines', line_num, box_left + 1, A_len)
    endif

    " B
    let B_text = get([B_title] + B_text_items, (line_num - (box_top + 1)), repeat(' ', box_width))
    call rabbit_ui#helper#redraw_line(line_num, box_left + A_len, B_text)
    let B_len = len(substitute(B_text, ".", "x", "g"))
    if line_num is (box_top + 1)
      call rabbit_ui#helper#set_highlight('rabbituiTitleLine', line_num, box_left + 1 + A_len, B_len)
    elseif line_num is (box_top + 1) + 1 + B_index - B_display_offset
      call rabbit_ui#helper#set_highlight('rabbituiSelectedItem', line_num, box_left + 1 + A_len, B_len)
    else
      call rabbit_ui#helper#set_highlight('rabbituiTextLines', line_num, box_left + 1 + A_len, B_len)
    endif

  endfor

  return A_index
endfunction

