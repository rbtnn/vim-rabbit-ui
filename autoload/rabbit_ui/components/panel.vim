
function! rabbit_ui#components#panel#exec(title_and_items_list, option)
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

  let option['split_size'] = len(a:title_and_items_list)
  let option['split_width'] = option['box_width'] / option['split_size']

  let option['display_start'] = 0
  let option['display_last'] = option['box_bottom'] - option['box_top'] - 1

  let option['selected_pane_index'] = 0

  let option['item_index'] = {}
  let option['display_offset'] = {}
  let option['title'] = {}
  let option['text_items'] = {}
  for i in range(0, option['split_size'] - 1)
    let option['item_index'][i] = 0
    let option['display_offset'][i] = 0
    let option['title'][i] = rabbit_ui#helper#smart_split(a:title_and_items_list[i][0], option['split_width'])[0]
    let option['text_items'][i] = a:title_and_items_list[i][1]
  endfor

  return rabbit_ui#helper#wrapper(function('s:wrapper_f_panel'), option)
endfunction

function! s:wrapper_f_panel(option)
  let background_lines = get(a:option, 'background_lines', [])
  let box_height = a:option['box_height']

  let do_redraw = 1
  while 1

    if do_redraw
      % delete _
      silent! put=background_lines
      1 delete _
    endif
    let rtn_value = s:redraw_panel(a:option, do_redraw)
    redraw
    let do_redraw = 0

    let c_nr = getchar()

    let selected_pane_index = a:option['selected_pane_index']

    if char2nr('q') is c_nr
      break

    elseif char2nr('g') is c_nr
      let a:option['item_index'][selected_pane_index] = 0
      let a:option['display_offset'][selected_pane_index] = 0
      let do_redraw = 1

    elseif char2nr('G') is c_nr
      let item_size = len(a:option['text_items'][selected_pane_index])
      let a:option['item_index'][selected_pane_index] = item_size - 1
      let a:option['display_offset'][selected_pane_index] = (
            \   item_size - 1 < box_height - 1
            \   ? 0
            \   : item_size - box_height + 1
            \ )
      let do_redraw = 1

    elseif char2nr('j') is c_nr
      if a:option['item_index'][selected_pane_index] + 1 <= len(a:option['text_items'][selected_pane_index]) - 1
        let a:option['item_index'][selected_pane_index] += 1
      endif
      if a:option['display_last'] < a:option['item_index'][selected_pane_index] - a:option['display_offset'][selected_pane_index]
        let a:option['display_offset'][selected_pane_index] = a:option['item_index'][selected_pane_index] - a:option['display_last']
        let do_redraw = 1
      endif

    elseif char2nr('k') is c_nr
      if 0 <= a:option['item_index'][selected_pane_index] - 1
        let a:option['item_index'][selected_pane_index] -= 1
      endif
      if a:option['item_index'][selected_pane_index] - a:option['display_offset'][selected_pane_index] < a:option['display_start']
        let a:option['display_offset'][selected_pane_index] = a:option['item_index'][selected_pane_index] - a:option['display_start']
        let do_redraw = 1
      endif

    elseif char2nr('h') is c_nr
      if 0 < selected_pane_index
        let a:option['selected_pane_index'] -= 1
        let do_redraw = 1
      endif

    elseif char2nr('l') is c_nr
      if selected_pane_index < a:option['split_size'] - 1
        let a:option['selected_pane_index'] += 1
        let do_redraw = 1
      endif

    endif
  endwhile

  return rtn_value
endfunction
function! s:redraw_panel(option, do_redraw)
  let box_left = a:option['box_left']
  let box_right =  a:option['box_right']
  let box_top = a:option['box_top']
  let box_bottom =  a:option['box_bottom']
  let box_height = a:option['box_height']
  let split_width = a:option['split_width']
  let split_size = a:option['split_size']

  call rabbit_ui#helper#clear_highlights()

  let offsets = {}
  for pane_index in range(0, split_size - 1)
    let item_index = a:option['item_index'][pane_index]
    let display_offset = a:option['display_offset'][pane_index]
    let title = a:option['title'][pane_index]
    let text_items = a:option['text_items'][pane_index][(display_offset):(display_offset + box_height)]
    let fixed_text_items = map( text_items, 'rabbit_ui#helper#smart_split(v:val, split_width)[0]')

    for line_num in range(box_top + 1, box_bottom + 1)

      let text = get([title] + fixed_text_items, (line_num - (box_top + 1)), repeat(' ', split_width))

      let len = len(substitute(text, ".", "x", "g"))

      if !has_key(offsets, line_num)
        let offsets[line_num] = 0
      endif
      let offsets[line_num] += split_width

      if a:do_redraw
        call rabbit_ui#helper#redraw_line(line_num, box_left + offsets[line_num], text)
      endif

      if line_num is (box_top + 1)
        let gname = 'rabbituiTitleLine'
      elseif line_num is (box_top + 1) + 1 + item_index - display_offset
        let gname = 'rabbituiSelectedItem'
      else
        let gname = 'rabbituiTextLines'
      endif

      call rabbit_ui#helper#set_highlight(gname, line_num, box_left + 1 + offsets[line_num], len)
    endfor
  endfor

  return map(range(0, split_size - 1), "[ (a:option['item_index'][(v:val)]), (a:option['text_items'][(v:val)]) ]")
endfunction

    " let s:com = [
    "       \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
    "       \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
    "       \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
    "       \ 'Elixir', 'Ada', 'Type Script', ]
    " let s:alp = [ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J' ]
    " let s:spo = [
    "       \ '英語', '中国語', '韓国語', 'フランス語', 'ロシア語', 'ポルトガル語', 'スペイン語',
    "       \ 'ドイツ語', 'イタリア語', ]
    "
    " call rabbit_ui#panel([
    "       \ ['Computer Languages', s:com],
    "       \ ['Alphabets', s:alp],
    "       \ ['Spoken Languages', repeat(s:spo, 10)],
    "       \ ])

    " echo strdisplaywidth(rabbit_ui#helper#smart_split('あi', 4)[0])
    " let s:text = rabbit_ui#helper#smart_split('あiあa', 5)[0]
    " let s:len = len(substitute(s:text, ".", "x", "g"))
    " echo s:len
