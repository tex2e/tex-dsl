
module TexDSL
	def self.included(receiver)
		Kernel.puts "% generated by #{self} at #{Time.now}"
	end

	# constance
	NewLine = '\\\\'

	# 
	# Modify method_missing
	# 
	alias_method :original_method_missing, :method_missing

	def method_missing(method, *args, &block)
		tex_command = 
			!args.empty? && args.all? { |e| e.kind_of?(String) or e.kind_of?(Array) } ||
			args.empty? && block_given?

		if tex_command
			# print "make_command #{method} >> "
			make_command(method, *args, &block)
		else
			original_method_missing(method, *args, &block)
		end
	end

	# 
	# Make command
	# 
	# create method 'func_name', and send it.
	# next time, when method 'func_name' is called, it has already defined.
	def make_command(func_name, *mkcmd_args, &block)
		# define ghost method
		if block_given? && mkcmd_args.empty?
			# func{} -> \func{}
			# this braces is Proc, therefore use 'block_given?' method.
			define_method(func_name) do
				Kernel.puts "\\#{func_name}{}"
			end
		else
			# func ''             -> \func{}
			# func 'val'          -> \func{val}
			# func 'val1', 'val2' -> \func{val1}{val2}
			# func ['opt'], 'val' -> \func[opt]{val}
			define_method(func_name) do |*args|
				return if args.nil?
				args = [args] unless args.respond_to?(:inject) # convert to Array

				# output string as \func[opt1]{arg1}{arg2}
				init = "\\#{func_name}"
				out = args.inject(init.dup) do |memo, arg|
					if arg.kind_of?(Array)
						memo << "[#{arg.join(',')}]"
					elsif arg.kind_of?(String)
						memo << "{#{arg}}"
					end
				end

				return if out == init
				Kernel.puts out
			end
		end

		send(func_name, *mkcmd_args)
	end
	
	# 
	# Delete indent on here-document
	# 
	def puts(*strs)
		strs.each do |str|
			Kernel.puts str.to_s.unindent
		end
	end

	String.class_eval do
		def unindent
			gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
		end
	end

	# 
	# Make string ( \tiny - \Huge )
	# 
	# Large('insert text') -> '{ \Large insert text }'
	%w(tiny scriptsize footnotesize small normalsize large Large LARGE huge Huge)
	.map(&:to_sym).each do |cmd|
		define_method(cmd) do |insert_text|
			return "{ \\#{cmd} #{insert_text} }"
		end
	end

	# 
	# Make block command
	# 
	def block_command(cmd, args={})
		option = args[:option]
		value  = args[:value]
		out = "\\begin{#{cmd}}"
		out << "[#{option}]" if option
		out << "{#{value}}" if value
		Kernel.puts out
		yield
		Kernel.puts "\\end{#{cmd}}"
	end

	alias_method :start, :block_command
	alias_method :set, :block_command

	# 
	# Make table
	# 
	def table(args={}, &block)
		caption = args[:caption] || ''
		label = args[:label] || ''
		array = yield []
		hline = '\hline'

		# make table struct
		# if row is numeric, put 'r'. otherwise, 'l'
		# eg) '|l|r|r|'
		table_struct = 
			array[1].inject('|') do |memo, col|
				memo << (col.numeric? ? 'r|' : 'l|')
			end

		# insert \hline to [0], [2], [last]
		array.insert(0, [hline]).insert(2, [hline]).push([hline])

		table_str = 
			array.inject('') do |memo, row|
				next memo << hline << "\n" if row.first == hline
				next memo << row.join(' & ') << "\\\\\n"
			end

		# output table
		set :table, option: 'h' do
			centering{}
			caption "#{caption}"
			label "#{label}"
			set :tabular, value: table_struct do
				puts "#{table_str}"
			end
		end
	end

	String.class_exec do
		def numeric?
			Float(self) != nil rescue false
		end
	end

	Numeric.class_exec do
		def numeric?
			true
		end
	end

	# 
	# Put figure
	# 
	def figure(args={})
		option  = args[:option]  || 'h'
		scale   = args[:scale]   || '1.0'
		caption = args[:caption] || ''
		label   = args[:label]   || ''
		path    = args[:path]    || raise(ArgumentError, 'must specify path of figure')

		# output figure
		set :figure, option: "#{option}" do
			centering{}
			includegraphics ["scale=#{scale}"], "#{path}"
			caption "#{caption}"
			label "#{label}"
		end
	end
end



if __FILE__ == $PROGRAM_NAME
	include(TexDSL)

	# documentclass %w(a4j titlepage), 'jarticle'
	# usepackage ['utf8'], 'inputenc'
	# usepackage 'fancybox, ascmac'

	# set :document do
	# 	section 'Overview'

	# 	puts <<-'EOS'
	# 		This is sample text
	# 		This is sample text
	# 		This is sample text
	# 	EOS
	# end

	table caption: 'Table test' do
		[
			%w(title tag  description totalcost),
			%w(hoge  fuga piyo 100),
			%w(foo   bar  baz  200),
			%w(spam  eggs ham  300),
		]
	end
end










































__END__

# TODO: create lstinputlisting()
# TODO: create verbatiminput()
# TODO: code_block() call lstinputlisting() or verbatiminput()

\subsection{説明}

プログラムの手順を以下に示す。

\begin{enumerate}
\item {\tt argc}の値を出力する
\item {\tt argv}の要素を、for文で {\tt argv[i]} として出力する
\item {\tt argv}の要素を、2重for文を用いて {\tt argv[i][j]} として出力する
\item {\tt argv}の要素を、2重for文を用いて {\tt *(argv[i] + j)} として出力する
\end{enumerate}

\subsection{プログラムリスト}

\lstinputlisting[caption=argcとargvの中身を表示するプログラム ,label=pg:3a]
{path/to/file.c}

\subsection{実行結果}

\begin{itembox}[c]{課題3a. 出力結果}
{\small
\verbatiminput{path/to/file.out}
}
\end{itembox}

\subsection{考察}

{\tt argc}, {\tt argv} それぞれの特徴を以下にまとめる。

\begin{description}
\item[{\tt argc}]\mbox{}\\ main関数の引数である{\tt argc}は、...

\item[{\tt argv}]\mbox{}\\ main関数の引数である{\tt argv}は、...
\end{description}