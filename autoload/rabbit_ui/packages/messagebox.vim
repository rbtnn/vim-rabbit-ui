
function! rabbit_ui#packages#messagebox#exec(title, text, option)
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

  let option['box_width'] = option['box_right'] - option['box_left'] + 1
  let option['box_height'] = option['box_bottom'] - option['box_top'] + 1
  let option['title'] = rabbit_ui#helper#smart_split(a:title, option['box_width'])[0]
  let option['text_lines'] = rabbit_ui#helper#smart_split(a:text, option['box_width'])

  return rabbit_ui#helper#wrapper(function('s:wrapper_f_messagebox'), option)
endfunction

function! s:wrapper_f_messagebox(option)
  let background_lines = get(a:option, 'background_lines', [])

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

  call rabbit_ui#helper#clear_highlights()

  for line_num in range(box_top + 1, box_bottom + 1)
    let text = get([title] + text_lines, (line_num - (box_top + 1)), repeat(' ', box_width))
    call rabbit_ui#helper#redraw_line(line_num, box_left, text)
    let len = len(substitute(text, ".", "x", "g"))

    if line_num is (box_top + 1)
      call rabbit_ui#helper#set_highlight('rabbituiTitleLine', line_num, box_left + 1, len)
    elseif line_num is (box_bottom + 1)
      call rabbit_ui#helper#set_highlight('rabbituiTextLines', line_num, box_left + 1, len)
    else
      call rabbit_ui#helper#set_highlight('rabbituiTextLines', line_num, box_left + 1, len)
    endif
  endfor

  return 0
endfunction
