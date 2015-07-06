
task :default => :pdf

source_files = Rake::FileList['report*.rb']

desc "Make tex file from DSL"
task :tex => source_files.ext('.tex')

desc "Make dvi file from tex file"
task :dvi => source_files.ext('.dvi')

desc "Make pdf file from dvi file"
task :pdf => source_files.ext('.pdf')

rule '.tex' => '.rb' do |t|
	sh "ruby #{t.source} > #{t.name}"
	puts
end

rule '.dvi' => '.tex' do |t|
	command = "platex --kanji=utf8 #{t.source}"
	result = `#{command}`
	puts command, result

	# remake dvi file, if necessary.
	while result.match(/Rerun to get cross-references right\./)
		result = `#{command}`
		puts result
	end
	puts
end

rule '.pdf' => '.dvi' do |t|
	sh "dvipdfmx -d5 #{t.source}"
	puts
end


require 'rake/clean'

# rake clean
generated = %W(.log .tex .aux .dvi)
generated.each do |extention|
	CLEAN.include(source_files.ext(extention))
end

# rake clobber
CLOBBER.include(source_files.ext('.pdf'))

