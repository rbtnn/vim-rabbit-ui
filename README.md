
rabbit-ui.vim
=============

This is Rich UI Vim script Library.


Packages
--------

1. MessageBox

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/messagebox.png)

* `q` key: quit messagebox.


        let s:title = 'MessageBox'
        let s:text = 'Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text Text '
        call rabbit_ui#messagebox(s:title, s:text)


2. Choices

![](https://raw.github.com/rbtnn/rabbit-ui.vim/master/choices.png)

* `j` key: down cursor.
* `k` key: up cursor.
* `q` key: quit choices.


        let s:title = 'Choices'
        let s:items = [
              \ 'Dart',
              \ 'JavaScript',
              \ 'Vim script',
              \ 'Go',
              \ 'C',
              \ 'C++',
              \ 'Java',
              \ 'Perl',
              \ 'Ruby',
              \ 'Python',
              \ 'Haskell',
              \ 'HTML',
              \ 'css',
              \ 'Lisp',
              \ 'COBOL',
              \ 'Scheme',
              \ 'Scala',
              \ 'Lua',
              \ 'CoffeeScript',
              \ 'Common Lisp',
              \ 'Erlang',
              \ 'Elixir',
              \ 'Ada',
              \ 'Type Script',
              \ ]
        let selected_index = rabbit_ui#choices(s:title, s:items)





