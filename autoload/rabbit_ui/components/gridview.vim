
function! rabbit_ui#components#gridview#exec(data, option)
  let option = rabbit_ui#helper#set_common_options(a:option)


  let option['display_start'] = 0
  let option['display_last'] = option['box_bottom'] - option['box_top'] - 1

  let option['selected_col'] = 1
  let option['selected_row'] = 1

  let option['display_col_size'] = 10
  let option['display_row_size'] = 10

  let option['split_width'] = option['box_width'] / option['display_col_size']

  let option['display_offset'] = 0

  let option['data'] = a:data

  return rabbit_ui#helper#wrapper(function('s:wrapper_f_gridview'), option)
endfunction

function! s:wrapper_f_gridview(option)
  let background_lines = get(a:option, 'background_lines', [])
  let box_height = a:option['box_height']

  let do_redraw = 1
  while 1

    if do_redraw
      % delete _
      silent! put=background_lines
      1 delete _
    endif

    let rtn_value = s:redraw_gridview(a:option, do_redraw)
    redraw

    let do_redraw = 0

    let c_nr = getchar()

    if char2nr('q') is c_nr
      break

    elseif char2nr('j') is c_nr
      if a:option['selected_row'] + 1 < a:option['display_row_size'] - 1
        let a:option['selected_row'] += 1
      endif

    elseif char2nr('k') is c_nr
      if 0 <= a:option['selected_row'] - 1
        let a:option['selected_row'] -= 1
      endif

    elseif char2nr('l') is c_nr
      if a:option['selected_col'] < a:option['display_col_size'] - 1
        let a:option['selected_col'] += 1
      endif

    elseif char2nr('h') is c_nr
      if 0 <  a:option['selected_col'] - 1
        let a:option['selected_col'] -= 1
      endif

    elseif char2nr('e') is c_nr
      let selected_col = a:option['selected_col']
      let selected_row = a:option['selected_row']
      let text = get(get(a:option['data'], selected_row, []), selected_col, '')

      while len(a:option['data']) <= selected_row
        let a:option['data'] += [[]]
      endwhile
      while len(a:option['data'][selected_row]) <= selected_col
        let a:option['data'][selected_row] += ['']
      endwhile

      let a:option['data'][selected_row][selected_col] = input('>', text)
      let do_redraw = 1

    endif
  endwhile

  return rtn_value
endfunction
function! s:redraw_gridview(option, do_redraw)
  let box_left = a:option['box_left']
  let box_right =  a:option['box_right']
  let box_top = a:option['box_top']
  let box_bottom =  a:option['box_bottom']
  let box_height = a:option['box_height']

  let split_width = a:option['split_width']

  let selected_row = a:option['selected_row']
  let selected_col = a:option['selected_col']

  let display_offset = a:option['display_offset']

  let display_col_size = a:option['display_col_size']
  let display_row_size = a:option['display_row_size']

  let fixed_data = deepcopy(a:option['data'])

  for row_data in fixed_data
    for col_index in range(0, len(row_data) - 1)
      let row_data[col_index] = rabbit_ui#helper#smart_split( row_data[col_index], split_width)[0]
    endfor
  endfor

  call rabbit_ui#helper#clear_highlights()

  let offsets = {}
  for col_index in range(0, display_col_size - 1)
    for row_index in range(0, display_row_size - 1)

      let text = get(get(fixed_data, row_index, []), col_index, repeat(' ', split_width))

      let len = len(substitute(text, ".", "x", "g"))

      if !has_key(offsets, row_index)
        let offsets[row_index] = 0
      endif

      if a:do_redraw
        call rabbit_ui#helper#redraw_line(row_index + (box_top + 1), box_left + offsets[row_index], text)
      endif

      if row_index is 0
        let gname = 'rabbituiTitleLine'
      elseif col_index is 0
        let gname = 'rabbituiTitleLine'
      elseif row_index is (selected_row - display_offset)
        if col_index is a:option['selected_col']
          let gname = 'rabbituiSelectedItemActive'
        else
          let gname = 'rabbituiSelectedItemNoActive'
        endif
      else
        if col_index is a:option['selected_col']
          let gname = 'rabbituiSelectedItemNoActive'
        else
          let gname = 'rabbituiTextLines'
        endif
      endif

      call rabbit_ui#helper#set_highlight(gname, row_index + (box_top + 1), box_left + 1 + offsets[row_index], len)

      let offsets[row_index] += split_width
    endfor
  endfor

  return a:option['data']
endfunction

