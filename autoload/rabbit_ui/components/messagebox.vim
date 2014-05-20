
function! rabbit_ui#components#messagebox#exec(title, text, option)
  let option = rabbit_ui#helper#set_common_options(a:option)

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
