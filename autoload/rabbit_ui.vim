
scriptencoding utf-8

function! rabbit_ui#messagebox(title, text, ...)
  let config = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  let config['keymap'] = get(config, 'keymap', {})
  let default_keymap = rabbit_ui#components#messagebox#get_default_keymap()
  call extend(config['keymap'], default_keymap, 'keep')
  let context_list = rabbit_ui#exec_components([
        \   { 'component_name' : 'messagebox',
        \     'arguments' : [(a:title), (a:text)],
        \     'config' : config,
        \   }])
  if empty(context_list)
    return {}
  else
    return { 'value' : [] }
  endif
endfunction
function! rabbit_ui#choices(title, items, ...)
  let config = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  let config['keymap'] = get(config, 'keymap', {})
  let default_keymap = rabbit_ui#components#choices#get_default_keymap()
  call extend(config['keymap'], default_keymap, 'keep')
  let context_list = rabbit_ui#exec_components([
        \   { 'component_name' : 'choices',
        \     'arguments' : [(a:title), (a:items)],
        \     'config' : config,
        \   }])
  if empty(context_list)
    return {}
  else
    return { 'value' : context_list[0]['config']['index'] }
  endif
endfunction
function! rabbit_ui#panel(title_and_items_list, ...)
  let config = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  let config['keymap'] = get(config, 'keymap', {})
  let default_keymap = rabbit_ui#components#panel#get_default_keymap()
  call extend(config['keymap'], default_keymap, 'keep')
  let context_list = rabbit_ui#exec_components([
        \   { 'component_name' : 'panel',
        \     'arguments' : [(a:title_and_items_list)],
        \     'config' : config,
        \   }])
  if empty(context_list)
    return {}
  else
    let item_index = context_list[0]['config']['item_index']
    let text_items = context_list[0]['config']['text_items']
    let xs = []
    for key in sort(keys(item_index))
      let xs += [[item_index[key], text_items[key]]]
    endfor
    return { 'value' : xs }
  endif
endfunction
function! rabbit_ui#gridview(data, ...)
  let config = ( 0 < a:0 ) ? (type(a:1) is type({}) ? a:1 : {}) : {}
  let config['keymap'] = get(config, 'keymap', {})
  let default_keymap = rabbit_ui#components#gridview#get_default_keymap()
  call extend(config['keymap'], default_keymap, 'keep')
  let context_list = rabbit_ui#exec_components([
        \   { 'component_name' : 'gridview',
        \     'arguments' : [(a:data)],
        \     'config' : config,
        \   }])
  if empty(context_list)
    return {}
  else
    return { 'value' : context_list[0]['config']['data'] }
  endif
endfunction

function! rabbit_ui#exec_components(context_list)
  let context_list = deepcopy(a:context_list)

  let saved_laststatus = &laststatus
  let saved_statusline = &statusline
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
    setlocal norelativenumber
    setlocal nohlsearch
    setlocal laststatus=2
    setlocal buftype=nofile nobuflisted noswapfile bufhidden=hide
    let &l:statusline = ' '
    let &l:filetype = rabbit_ui#helper#id()
    let &l:titlestring = printf('[%s]', rabbit_ui#helper#id())



    let componentname_list = rabbit_ui#helper#get_componentname_list()
    let active_window_index = 0
    for context in context_list
      if ! rabbit_ui#helper#windowstatus(context, 'nonactivate')
        break
      else
        let active_window_index += 1
      endif
    endfor

    for context in context_list
      if -1 isnot index(componentname_list, context['component_name'])
        call rabbit_ui#components#{context['component_name']}#init(context)
      endif
    endfor

    let c_nr = ''
    while 1
      if len(filter(deepcopy(context_list), '! rabbit_ui#helper#windowstatus(v:val, "nonactivate")')) is 0
        break
      endif

      let keyevent_arg1 = {
            \   'status' : 'redraw',
            \   'context_list' : context_list,
            \   'active_window_index' : active_window_index,
            \ }
      let context = context_list[active_window_index]
      if !has_key(context['config'], 'keymap')
        let context['config']['keymap'] =
              \ rabbit_ui#components#{context['component_name']}#get_default_keymap()
      endif
      if has_key(context['config']['keymap'], c_nr)
        call call(context['config']['keymap'][c_nr], [keyevent_arg1])
      endif
      let context_list = keyevent_arg1['context_list']
      let active_window_index = keyevent_arg1['active_window_index']
      let status = keyevent_arg1['status']
      if status is 'break'
        break
      elseif status is 'continue'
        let c_nr = ''
        continue
      endif

      for context in context_list
        call rabbit_ui#helper#clear_matches(context)
      endfor

      let lines = deepcopy(background_lines)

      for idx in range(0, len(context_list) - 1)
        if ! has_key(context_list[idx], 'windowstatus')
          let context_list[idx]['windowstatus'] = {}
        endif
        let context_list[idx]['windowstatus']['focused'] = idx is active_window_index
        call vimconsole#log(context_list[idx]['windowstatus']['focused'])
      endfor

      for context in context_list
        if -1 isnot index(componentname_list, context['component_name'])
          call rabbit_ui#components#{context['component_name']}#redraw(lines, context)
        endif
      endfor

      % delete _
      silent! put=lines
      1 delete _

      redraw

      let c_nr = getchar()
    endwhile
  finally
    for context in context_list
      call rabbit_ui#helper#clear_matches(context)
    endfor
    tabclose
    let &l:laststatus = saved_laststatus
    let &l:statusline = saved_statusline
    let &l:hlsearch = saved_hlsearch
    let &l:titlestring = saved_titlestring
    execute 'tabnext' . saved_currtabindex
    redraw
  endtry

  return context_list
endfunction

