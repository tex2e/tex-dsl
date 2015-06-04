

require_relative('tex_dsl.rb')
include(TexDSL)

documentclass %w(a4j titlepage), 'jarticle'
usepackage ['utf8'], 'inputenc'
usepackage 'fancybox, ascmac'
usepackage 'amsmath, amssymb'
usepackage 'fancybox, ascmac'
usepackage ['dvipdfmx'], 'graphicx'
usepackage 'verbatim'
# to display code list
usepackage 'ascmac'
usepackage 'here'
usepackage 'txfonts'
usepackage 'listings, jlisting'
renewcommand '\lstlistingname', 'List'

lstset <<'EOS'
	language = c,
	basicstyle = \ttfamily\small,
	commentstyle = \textit,
	classoffset = 1,
	keywordstyle = \bfseries,
	frame = tRBl,
	framesep = 5pt,
	showstringspaces = false,
	numbers = left,
	stepnumber = 1,
	numberstyle = \footnotesize,
	tabsize = 2
EOS

title 'How to write TexDSL'
author '@TeX2e'
date Time.now.strftime('%Y/%m/%d')

set :document do
	maketitle ''
	thispagestyle 'empty'
	newpage ''
	setcounter 'page', '1'

	section 'Overview'

	puts <<-'EOS'
		This is sample text
		This is sample text
		This is sample text
	EOS

	section 'Table'

	table caption: 'Table test', label: 'table:env' do
		[
			%w(title tag description totalcost),
			%w(hoge fuga piyo 100),
			%w(foo  bar  baz  200),
			%w(spam eggs ham  300),
		]
	end

	section 'Code'

	set :screen do
		set :verbatim do
			puts 'write code here'
		end
	end

	set :itembox, caption: 'source code' do
		set :verbatim do
			puts File.open("sample.c", "r", &:read).sub(/\t/, ' ' * 4)
		end
	end

	section 'Figure'

	# figure caption: 'Figure test', path: 'path/to/file.eps', label: 'fig:env'
end


























