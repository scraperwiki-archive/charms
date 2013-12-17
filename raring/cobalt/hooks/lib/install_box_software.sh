#!/bin/sh
#
# Script to set up the inside of a ScraperWiki box

#set -e # exit on error
#set -x # Useful for debugging, but not useful routinely.

# get rid of Perl warnings about locale
# http://hexample.com/2012/02/05/fixing-locale-problem-debian/
locale-gen en_US.UTF-8
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export DEBIAN_FRONTEND=noninteractive

blue () {
    # Output a blue string.
    printf '\033[36m'
    echo "$@"
    printf '\033[0m'
}

SCRIPT_LOCATION=$(dirname $(readlink -f $0))
aptit () {
    apt-get install --quiet --quiet --assume-yes "$@"
}

pipit () {
    # remove pip's build directory, which otherwise sometimes causes problems when
    # things are interrupted and there is a half built old version. e.g. errors like:
    #        Source in /build/scraperwiki-local has version 0.0.6 that conflicts with scraperwiki-local==0.1.0 (from -r /root/python-reqs.txt (line 37))
    rm -fr /build /tmp/pip-build-root

    pip --timeout=30 install --quiet --upgrade "$@"
}

# we use an explicit ruby version everywhere as multiple can be installed
WHICH_RUBY=1.9.1
# checks to see if it is already installed - alas gem doesn't do that by
# default, and bundler can't install globally. This seems easiest, but
# would rather use gem or bundler really to do it properly...
gemit() {
    PACKAGE=$1

    # http://stackoverflow.com/questions/10008430/install-gem-on-demand
    ruby$WHICH_RUBY -e '`gem'$WHICH_RUBY' list -i \"^'$PACKAGE'$\"`.chomp=="true" or `gem'$WHICH_RUBY' install '$PACKAGE'`'
    gem$WHICH_RUBY update -q $PACKAGE >/dev/null
}

peclit () {
  pecl upgrade "$@"
}

npmit () {
  npm install --quiet "$@"
  npm update --quiet "$@"
}

cpanit () {
  cpan "$@"
}

# Note: R's install pcakage writes mainly to stderr :(
# There is probably good way round this: http://comments.gmane.org/gmane.comp.lang.r.devel/29136
# XXX might have to redirect stderr for now, it's so broken
# See also: http://r.789695.n4.nabble.com/Install-package-automatically-if-not-there-td2267532.html
rit () {
  R -q -e 'options("repos"="http://cran.ma.imperial.ac.uk/"); if(!"'$@'" %in% rownames(installed.packages())) {install.packages("'$@'")}'
}

debian_stuff () {
  # apt-utils: otherwise get message "debconf: delaying package configuration, since apt-utils is not installed" lots
  # software-properties-common: for add-apt-repository
  aptit apt-utils lsb-core lsb-base software-properties-common
  add-apt-repository -y ppa:chris-lea/node.js # for latest node

  blue "Upgrading Ubuntu packages, for security and update fixes, and our own PPA for poppler"
  cat <<END >/etc/apt/sources.list
  deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s) main universe
  deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s)-updates main universe
  deb http://archive.ubuntu.com/ubuntu $(lsb_release -c -s)-security main universe
  deb http://ppa.launchpad.net/scraperwiki/$(lsb_release -c -s)-backports/ubuntu raring main 
END
  apt-get update --assume-yes --quiet --quiet
  apt-get dist-upgrade --assume-yes --quiet --quiet

  blue "aptitude, xml, node, R, and other miscellaneous stuff"
  aptit aptitude wget curl tidy ack-grep tree telnet netcat net-tools lsof
  dpkg-divert  --local --divert /usr/bin/ack --rename --add /usr/bin/ack-grep
  aptit libxml2-dev libxslt1-dev libssl-dev libcurl4-openssl-dev geoip-bin libfreetype6-dev
  aptit nodejs coffeescript r-recommended tcc luarocks
  aptit xvfb golang libreoffice

  blue "Installing databases"
  aptit mysql-client sqlite3 libsqlite3-dev libspatialite3

  blue "Installing Python debian packages"
  aptit python-pip python-dev python3-dev swig ipython
  aptit libgd2-xpm # force XPM version rather than no-XPM version as php5-gd needs it later

  # The below python packages have to be compiled if installed via pip, slowing things down
  aptit python-geoip graphviz python-nltk python-rpy2 python-poppler python-cairo
  aptit python-scipy python-numpy python-pandas python-imaging
  aptit python-lxml python-M2Crypto python-matplotlib python-levenshtein
  aptit python-creoleparser python-pycurl python-simplejson python-paramiko python-boto

  blue "Installing PHP debian packages"
  aptit php5-dev php5-sqlite php5-cli php-pear php5-gd php5-curl php5-geoip php5-sqlite php5-tidy

  blue "Installing Ruby debian packages"
  aptit ruby$WHICH_RUBY ruby$WHICH_RUBY-dev # ruby includes gem after 1.9

  blue "Installing Java/Clojure debian packages"
  aptit openjdk-7-jre openjdk-7-jdk # needs /proc
  # aptit libhtmlunit-java # hmmm seems to need openjdk-6 :( leave until somebody asks
  aptit clojure1.4
}

debian_extras() {
  blue "Installing popular editors"
  aptit vim emacs nano joe nedit vim-gnome

  update-alternatives --set editor /bin/nano >/dev/null 2>&1 || true

  blue "Installing spawnable binaries"
  aptit poppler-utils pdftk inkscape duplicity

  blue "Installing version control systems"
  aptit git mercurial subversion rcs

  blue "Installing additional useful utilities"
  aptit screen tmux bc w3m links lynx strace psmisc run-one

  blue "Setting up SFTP"
  # sftp requires /usr/lib/sftp-server, but no server daemon running
  mkdir -p /etc/ssh
  touch /etc/ssh/sshd_not_to_be_run
  aptit openssh-server

  blue "Setting up selenium"
  aptit chromium-chromedriver xvfb

  echo "Finished Debian extras"

}

python_extras() {
  blue "Installing Python extras"
  pipit pip
  # clear shell's search path, as pip has just moved from /usr/bin to /usr/local/bin
  hash -r
  # pipit distribute # don't think needed any more

  # lots of useful data science tools
  pipit BeautifulSoup
  pipit beautifulsoup4
  pipit bitly_api
  pipit cartodb
  pipit chardet
  pipit chromium_compact_language_detector
  pipit ckanclient
  pipit csvkit
  pipit dataset
  pipit demjson
  pipit dexy
  pipit dumptruck
  pipit feedparser
  pipit flickrapi
  pipit fluidinfo.py
  pipit geopy
  pipit gensim
  pipit googlemaps
  pipit gmvault
  pipit html5lib
  pipit icalendar
  pipit jellyfish
  pipit jsonschema
  pipit markdown
  pipit mechanize
  pipit messytables
  pipit ngram
  pipit networkx
  pipit openpyxl
  pipit parslepy
  pipit pdfminer
  pipit pipe2py
  pipit plurk-oauth
  # pipit pydot # loads incompatible version of pyparsing for now, like https://github.com/RDFLib/rdflib/issues/245
  pipit pyephem
  pipit pyrise
  pipit python-dateutil
  pipit python-instagram
  pipit pygooglechart
  pipit pyhamcrest
  pipit pyPdf
  pipit pyquery
  pipit pyth
  pipit pytidylib
  pipit pytz
  pipit requests
  pipit requests_cache
  pipit requests-foauth
  pipit rdflib
  pipit robotexclusionrulesparser
  pipit gdata
  pipit recurly
  pipit scrapely
  pipit scraperwiki
  pipit scrapy
  pipit selenium
  pipit specloud
  pipit sqlaload
  pipit tweepy
  pipit tweetstream
  pipit twill
  pipit twitter
  pipit unicodecsv
  pipit Unidecode
  pipit virtualenv
  pipit xlrd
  pipit xlutils
  pipit xlwt
  pipit xmltodict
  pipit yql
  pipit python-magic

  echo "Finished Python extras"
}

php_extras() {
  blue "Installing PHP extras"

  # scraperwiki-php libraries stuff
  echo "include_path = \".:/usr/share/php:/usr/share/pear:/usr/share/scraperwiki-php\"
allow_url_include = On" >/etc/php5/conf.d/scraperwiki_python.ini # LOL
  (
    cd /usr/share
    if [ ! -e scraperwiki-php ]
    then
      git clone --quiet https://github.com/scraperwiki/scraperwiki-php.git
    fi
    cd scraperwiki-php
    git pull --quiet
  )

  peclit rar
  echo "extension=rar.so" > /etc/php5/conf.d/rar.ini
  echo "Finished PHP extras"
}

node_extras() {
  blue "Installing Node extras"
  npmit request@2.14.0 # later versions require Node 0.8 (we use 0.6 which is in Ubuntu Precise Pangolin)
  npmit htmlparser
  npmit html5

  # Get version of jsdom with contextify 0.1.3 as dependency, because of bug
  # Can remove when https://github.com/tmpvar/jsdom/issues/436 is fixed
  npmit contextify@0.1.3
  npmit jsdom@0.5.4

  npmit sqlite3
  npmit node-rss
  npmit rss
  npmit async
  npmit zombie
  npmit moment
  npmit cheerio

  echo "Finished Node extras"
}

ruby_extras() {
  blue "Installing Ruby extras"
  gemit sqlite3
  gemit httpclient
  gemit nokogiri
  gemit hpricot
  gemit libxml-ruby
  gemit mechanize
  gemit spreadsheet
  gemit fastercsv
  gemit pdf-reader
  gemit gdata
  gemit tmail
  gemit typhoeus
  gemit rubyzip # roo needs rubyzip
  gemit roo
  gem$WHICH_RUBY install -v 3.0.3 highrise # later versions don't work for me, got back to latest when this fixed https://github.com/tapajos/highrise/issues/50
  gemit rfgraph
  gemit google-spreadsheet-ruby
  gemit google_drive
  gemit polylines
  gemit twitter
  gemit dm-sqlite-adapter
  gemit scraperwiki
  gemit icalendar
  echo "Finished Ruby extras"
}

# Note: some R packages are available as Debian packages r-cran-*
r_extras() {
  echo "Installing R extras"
  rit rjson
  rit RCurl
  rit hexbin
  rit knitr
  echo "Finished R extras"
}

# XXX this works, however it is a bit slow - enable if we get more Perl demand
# than one person
#perl_extras() {
    # Set up CPAN to work unattended
    # http://stackoverflow.com/questions/3462058/how-do-i-automate-cpan-configuration
#    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)
#
#    cpanit HTML::TreeBuilderX::ASP_NET
#}

lua_extras() {
  luarocks install lsqlite3
}

mounts () {
  # /proc mounted because it's needed by the Java install, and probably other things.
  # Need both of these to ensure that the fs is mounted whether or not it already was.
  mount /proc 2>&- || mount -o remount /proc
  # Frabcus says (2012-11-15) that /dev is probably needed by random things too.
  mount /dev 2>&- || mount -o remount /dev
}

mounts

# Have to install the Debian packages for each language serially
debian_stuff

# Install everything else in parallel
debian_extras&
python_extras&
php_extras&
node_extras&
ruby_extras&
r_extras&
#perl_extras&
lua_extras&

# waits for all the processes backgrounded with & to finish
wait

# this takes ~10mins, downloads lots of stuff to /usr/share/nltk_data
# so spawn it completely in the background to speed things up a lot
# XXX this could cause problems for people using NLTK on newly minted machines.
# rethink if it does!
nohup python -m nltk.downloader -d /usr/share/nltk_data -q all >/var/log/nltk_data.download.log 2>&1 &
