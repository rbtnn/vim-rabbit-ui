
function! rabbit_ui#components#choices#exec(title, items, option)
  let option = rabbit_ui#helper#set_common_options(a:option)

  let option['index'] = 0
  let option['display_offset'] = 0
  let option['display_start'] = 0
  let option['display_last'] = option['box_bottom'] - option['box_top'] - 1
  let option['title'] = rabbit_ui#helper#smart_split(a:title, option['box_width'])[0]
  let option['text_items'] = map(a:items, 'rabbit_ui#helper#smart_split(v:val, option["box_width"])[0]')

  return rabbit_ui#helper#wrapper(function('s:wrapper_f_choices'), option)
endfunction

function! s:wrapper_f_choices(option)
  let background_lines = get(a:option, 'background_lines', [])

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

  call rabbit_ui#helper#clear_highlights()

  for line_num in range(box_top + 1, box_bottom + 1)
    let text = get([title] + text_items, (line_num - (box_top + 1)), repeat(' ', box_width))

    call rabbit_ui#helper#redraw_line(line_num, box_left, text)

    let len = len(substitute(text, ".", "x", "g"))

    if line_num is (box_top + 1)
      call rabbit_ui#helper#set_highlight('rabbituiTitleLine', line_num, (box_left + 1), len)
    elseif line_num is (box_top + 1) + 1 + index - display_offset
      call rabbit_ui#helper#set_highlight('rabbituiSelectedItemActive', line_num, (box_left + 1), len)
    else
      if line_num % 2 is 0
        call rabbit_ui#helper#set_highlight('rabbituiTextLinesEven', line_num, (box_left + 1), len)
      else
        call rabbit_ui#helper#set_highlight('rabbituiTextLinesOdd', line_num, (box_left + 1), len)
      endif
    endif
  endfor

  return index
endfunction
