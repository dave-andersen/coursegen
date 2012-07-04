# A thing to note about this:  ERB works by building up output
# strings.  For this file, pretend that you're a functional programmer:
# Anything that the function returns will be interpolated into
# the HTML.

require 'erb'
require 'ostruct'

$INC = File.dirname(__FILE__)
$PDIR = nil
if ($INC =~ /www-include/)
    $LOAD_PATH << (File.dirname(__FILE__) + "/../include/")
else
    $LOAD_PATH << (File.dirname(__FILE__) + "/../../www/")
end

begin
    if (ARGF && ARGF.file && ARGF.file.path)
        $PDIR = File.dirname(ARGF.file.path)
    end
rescue
end


def pagehead(title)
    page = OpenStruct.new
    page.title = title

    HTMLenv.new(page).libinc("pagehead.srhtml")
end

class HTMLenv

    def initialize(page = nil)
        @page = page || OpenStruct.new
    end

    def inc(file)
	fl = [$INC]
	fl.push($PDIR) if $PDIR
	if ($INC =~ /www-include/)
	    fl.push($INC + "/../www/")
	end
	fl.push($PDIR + "/../../www/") if $PDIR
	fl.each { |dir|
	    if (File.exist?(dir + "/" + file))
		return IO.read(dir + "/" + file)
	    end
	}
	throw "Could not find #{file}"
    end

    def libinc(file)
        b = binding
        ERB.new(inc(file).untaint, $SAFE, "%<>", "_estr").result b
    end
    
end

def inc(file)
    HTMLenv.new().inc(file)
end

def libinc(file)
    HTMLenv.new().libinc(file)
end

def bodytop(title)
    page = OpenStruct.new
    page.title = title

    HTMLenv.new(page).libinc("bodyhead.srhtml")
end

def pagetop(title)
    pagehead(title) + bodytop(title)
end

def pagebottom
    libinc("pagebottom.srhtml")
end
