
rabbit-ui.vim
=============

This is Rich UI Vim script Library.


1. MessageBox
-------------


![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/messagebox.png)


*Keys in MessageBox*

* `q` key: quit messagebox.


*SampleCode*

    let s:title = 'MessageBox'
    let s:text = 'Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text '
    call rabbit_ui#messagebox(s:title, s:text)




2. Choices
----------

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/choices.png)


*Keys in Choices*

* `j` key: down cursor.
* `k` key: up cursor.
* `q` key: quit choices.
* `g` key: move cursor to first item.
* `G` key: move cursor to last item.


*SampleCode*

    let s:title = 'Choices'
    let s:com = [
          \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
          \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
          \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
          \ 'Elixir', 'Ada', 'Type Script', ]
    let s:selected_index = rabbit_ui#choices(s:title, s:com)




3. TwoPane
----------

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/twopane.png)


*Keys in Choices*

* `j` key: down cursor.
* `k` key: up cursor.
* `h` key: move cursor to left pane.
* `l` key: move cursor to right pane.
* `q` key: quit twopane.
* `g` key: move cursor to first item.
* `G` key: move cursor to last item.


*SampleCode*

    let s:com = [
          \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
          \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
          \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
          \ 'Elixir', 'Ada', 'Type Script', ]
    let s:spo = [
          \ '英語', '中国語', '韓国語', 'フランス語', 'ロシア語', 'ポルトガル語', 'スペイン語',
          \ 'ドイツ語', 'イタリア語', ]
    call rabbit_ui#twopain( 'Computer Languages', s:com, 'Spoken Languages', s:spo)




