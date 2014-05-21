
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

* `j` key: cursor down.
* `k` key: cursor up.
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




3. Panel
--------

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/panel.png)


*Keys in Choices*

* `j` key: cursor down.
* `k` key: cursor up.
* `h` key: move cursor to left panel.
* `l` key: move cursor to right panel.
* `H` key: move selected item to left panel.
* `L` key: move selected item to right panel.
* `q` key: quit panel.
* `g` key: move cursor to first item.
* `G` key: move cursor to last item.


*SampleCode*

    let s:com = [
          \ 'Dart', 'JavaScript', 'Vim script', 'Go', 'C', 'C++', 'Java', 'Perl',
          \ 'Ruby', 'Python', 'Haskell', 'HTML', 'css', 'Lisp', 'COBOL', 'Scheme',
          \ 'Scala', 'Lua', 'CoffeeScript', 'Common Lisp', 'Erlang',
          \ 'Elixir', 'Ada', 'Type Script', ]
    let s:alp = [ 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J' ]
    let s:spo = [
          \ '英語', '中国語', '韓国語', 'フランス語', 'ロシア語', 'ポルトガル語', 'スペイン語',
          \ 'ドイツ語', 'イタリア語', ]
    let s:num = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 ]

    " return [ [ selected_index, items], [ selected_index, items], ... ]
    echo rabbit_ui#panel([
          \ ['Computer Languages', s:com],
          \ ['Alphabets', s:alp],
          \ ['Spoken Languages', s:spo],
          \ ['Number', s:num],
          \ ])
    " [
    "   [
    "     15,
    "     [
    "       'Dart',
    "       'JavaScript',
    "       'Vim script',
    "       'Go',
    "       'C',
    "       'C++',
    "       'Java',
    "       'Perl',
    "       'Ruby',
    "       'Python',
    "       'Haskell',
    "       'HTML',
    "       'css',
    "       'Lisp',
    "       'COBOL',
    "       'Scheme',
    "       'Scala',
    "       'Lua',
    "       'CoffeeScript',
    "       'Common Lisp',
    "       'Erlang',
    "       'Elixir',
    "       'Ada',
    "       'Type Script'
    "     ]
    "   ],
    "   [2, ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']],
    "   [
    "     7,
    "     [
    "       '英語',
    "       '中国語',
    "       '韓国語',
    "       'フランス語',
    "       'ロシア語',
    "       'ポルトガル語',
    "       'スペイン語',
    "       'ドイツ語',
    "       'イタリア語'
    "     ]
    "   ],
    "   [1, [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]]
    " ]




4. GridView
-----------

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/gridview.png)


*Keys in GridView*

* `j` key: cursor down.
* `k` key: cursor up.
* `h` key: cursor left.
* `l` key: cursor right.
* `e` key: edit cell.
* `q` key: quit panel.


*SampleCode*

    echo rabbit_ui#gridview([
          \ [1,2,3],
          \ [4,5,6],
          \ [7,8,9],
          \ ])
    " [[1, 2, 3], [4, 5, 6], [7, 8, 9, 'foo'], ['', 'hoge']]

