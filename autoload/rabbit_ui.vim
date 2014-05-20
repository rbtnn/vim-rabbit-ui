
scriptencoding utf-8

function! rabbit_ui#messagebox(title, text, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  return rabbit_ui#components#messagebox#exec(a:title, a:text, option)
endfunction
function! rabbit_ui#choices(title, items, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  return rabbit_ui#components#choices#exec(a:title, a:items, option)
endfunction
function! rabbit_ui#panel(title_and_items_list, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  return rabbit_ui#components#panel#exec(a:title_and_items_list, option)
endfunction
function! rabbit_ui#gridview(data, ...)
  let option = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  return rabbit_ui#components#gridview#exec(a:data, option)
endfunction

function! rabbit_ui#run_testcases()
  let option = {
        \   'box_top' : 0,
        \   'box_bottom' : 20,
        \   'box_right' : 25,
        \   'box_left' : 0,
        \ }

  let com_items = [
        \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
        \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
        \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
        \ 'Elixir', 'Ada', 'Type Script', ]
  let com_items = repeat(com_items, 100)
  for idx in range(0, len(com_items) - 1)
    let com_items[idx] = printf('%d. %s', idx, com_items[idx])
  endfor

  let spo_items = [
        \ '英語', '中国語', '韓国語', 'フランス語', 'ロシア語', 'ポルトガル語', 'スペイン語',
        \ 'ドイツ語', 'イタリア語', ]
  let spo_items = repeat(spo_items, 100)
  for idx in range(0, len(spo_items) - 1)
    let spo_items[idx] = printf('%d. %s', idx, spo_items[idx])
  endfor

  let testcase_count = 1
  for items in [spo_items,com_items]
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
  call rabbit_ui#panel([
        \ [ printf('testcase:%d', testcase_count), com_items ],
        \ [ 'A', spo_items ],
        \ [ 'B', com_items ],
        \ [ 'C', spo_items ],
        \ ])
  let testcase_count += 1
  call rabbit_ui#panel([
        \ [ printf('testcase:%d (TwoPane(A))', testcase_count), com_items ],
        \ [ printf('testcase:%d (TwoPane(B))', testcase_count), spo_items ],
        \ ], option)
  let testcase_count += 1
endfunction

