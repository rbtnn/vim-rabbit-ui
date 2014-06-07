
function! s:getSID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_\zegetSID$')
endfunction
let s:SID = s:getSID()

function! s:keyevent_quit_window(...)
  let keyevent_arg1 = a:1
  let context_list = keyevent_arg1['context_list']
  let active_window_index = keyevent_arg1['active_window_index']
  call rabbit_ui#helper#clear_matches(context_list[active_window_index])
  call remove(context_list, active_window_index)
  call s:keyevent_focus_next_window(a:1)
  let keyevent_arg1['status'] = 'continue'
endfunction
function! s:keyevent_enter(...)
  let keyevent_arg1 = a:1
  let keyevent_arg1['status'] = 'break'
endfunction
function! s:keyevent_focus_next_window(...)
  let keyevent_arg1 = a:1
  let prev_active_window_index = keyevent_arg1['active_window_index']
  let keyevent_arg1['active_window_index'] = 0
  for idx in range(1, len(keyevent_arg1['context_list']))
    let next_idx = (prev_active_window_index + idx) % len(keyevent_arg1['context_list'])
    if ! rabbit_ui#helper#windowstatus(keyevent_arg1['context_list'][next_idx], 'nonactivate')
      let keyevent_arg1['active_window_index'] = next_idx
      break
    endif
  endfor
endfunction

function! rabbit_ui#keymap#get()
  return {
        \   'common' : {
        \     'quit_window' : function(s:SID . 'keyevent_quit_window'),
        \     'enter' : function(s:SID . 'keyevent_enter'),
        \     'focus_next_window' : function(s:SID . 'keyevent_focus_next_window'),
        \   },
        \   'panel' : rabbit_ui#components#panel#get_keymap(),
        \   'choices' : rabbit_ui#components#choices#get_keymap(),
        \   'messagebox' : rabbit_ui#components#messagebox#get_keymap(),
        \   'gridview' : rabbit_ui#components#gridview#get_keymap(),
        \ }
endfunction
