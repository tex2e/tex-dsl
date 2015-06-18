# tex-dsl
LaTeX DSL (written in Ruby)

# Usage
1. create new ruby script
2. require 'tex_dsl.rb' on new script
3. include TexDSL module. example: `require_relative('tex_dsl.rb'); include(TexDSL)`
4. write DSL code
5. enter the following command  `ruby this_script.rb`
6. create tex file `ruby this_script.rb > file.tex`

# DSL writing style

You can use ruby syntax in TexDSL.

Use `puts` to write document.
It will automatically delete indent.

~~~ruby
puts "sample sentence"
# => output: sample sentence

puts "
  multi line
  sample sentence
"
# => output:
# multi line
# sample sentence
~~~

TexDSL will convert the ghost method into real method.

~~~ruby
maketitle ''            # => output: \maketitle{}
maketitle{}             # => output: \maketitle{}
thispagestyle 'empty'   # => output: \thispagestyle{empty}
setcounter 'page', '1'  # => output: \setcounter{page}{1}

usepackage ['dvipdfmx'], 'graphicx' 
# => output: \usepackage[dvipdfmx]{graphicx}
documentclass ['a4', 'titlepage'], 'article' 
# => output: \documentclass[a4,titlepage]{article}
~~~

`set` function will make 'begin' and 'end'.

~~~ruby
set :document do
  puts 'foo'
end
# => output:
# \begin{document}
# foo
# \end{document}

set :itemize do
  item 'spam'
  item 'ham'
  item 'eggs'
end
# => output:
# \begin{itemize}
# \item{spam}
# \item{ham}
# \item{eggs}
# \end{itemize}
~~~


