
local he = require "he"
local list = he.list
local hepack = require "hepack"

data = {}

data.alldeps01 = [[

# alldeps.01
#removed python from kmod, util-linux

ConsoleKit2.dep:acl,attr,cgmanager,dbus,eudev,glib2,libX11,libXau,libXdmcp,libffi,libnih,libxcb,polkit,zlib
Cython.dep:python
GConf.dep:cyrus-sasl,dbus,dbus-glib,glib2,libffi,libxml2,openldap-client,openssl|openssl-solibs,polkit,xz,zlib
LibRaw.dep:gcc,gcc-g++,jasper,lcms2,libjpeg-turbo
M2Crypto.dep:openssl|openssl-solibs,python
MPlayer.dep:a52dec,aalib,alsa-lib,atk,attr,audiofile,bzip2,cairo,cyrus-sasl,dbus,e2fsprogs,esound,expat,flac,fontconfig,freeglut,freetype,fribidi,gcc,gcc-g++,gdk-pixbuf2,giflib,glib2,glu,gmp,gnutls,gpm,gtk+2,harfbuzz,json-c,lcms2,libICE,libSM,libX11,libXScrnSaver,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXv,libXxf86dga,libXxf86vm,libasyncns,libcaca,libcap,libcdio,libcdio-paranoia,libdrm,libdvdnav,libdvdread,libffi,libidn,libjpeg-turbo,libmad,libmng,libogg,libpng,libsndfile,libtheora,libvdpau,libvorbis,libvpx,libxcb,libxshmfence,lzo,mesa,mpg123,ncurses,nettle,openjpeg,openldap-client,openssl|openssl-solibs,p11-kit,pango,pixman,pulseaudio,samba,sdl,slang,svgalib,util-linux,zlib
ModemManager.dep:eudev,glib2,libffi,libgudev,libmbim,libqmi,zlib,mobile-broadband-provider-info
NetworkManager.dep:ModemManager,bluez,dbus,dbus-glib,eudev,expat,gcc,gcc-g++,glib2,icu4c,libffi,libgudev,libndp,libnl3,libsoup,libxml2,mozilla-nss,ncurses,newt,polkit,readline,slang,sqlite,util-linux,xz,zlib
PyQt.dep:attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,python,qt,sqlite,util-linux,xz,zlib
QScintilla.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,util-linux,zlib
Thunar.dep:atk,bzip2,cairo,dbus,dbus-glib,eudev,exo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libexif,libffi,libgudev,libnotify,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pcre,pixman,startup-notification,util-linux,xcb-util,xfce4-panel,xfconf,zlib
aalib.dep:gpm,libX11,libXau,libXdmcp,libxcb,ncurses,slang
acl.dep:attr
akonadi.dep:boost,bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,icu4c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,sqlite,util-linux,zlib
alpine.dep:cyrus-sasl,ncurses,openldap-client,openssl|openssl-solibs
alsa-lib.dep:python
alsa-oss.dep:alsa-lib
alsa-plugins.dep:alsa-lib,attr,dbus,flac,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXtst,libasyncns,libcap,libogg,libsamplerate,libsndfile,libvorbis,libxcb,pulseaudio,speexdsp,util-linux
alsa-utils.dep:alsa-lib,fftw,libsamplerate,ncurses
amarok.dep:acl,attica,attr,bzip2,curl,cyrus-sasl,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,gdk-pixbuf2,glib2,gmp,gnutls,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libaio,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libgpod,libidn,libimobiledevice,libjpeg-turbo,liblastfm,libmtp,libogg,libplist,libpng,libsndfile,libssh2,libusb,libusbmuxd,libvorbis,libxcb,libxml2,libxshmfence,libxslt,loudmouth,mariadb,mesa,nepomuk-core,nettle,openldap-client,openssl|openssl-solibs,orc,p11-kit,pcre,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,taglib,taglib-extras,util-linux,xz,zlib
amor.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
analitza.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libdbusmenu-qt,libdrm,libffi,libpng,libtermcap,libxcb,libxshmfence,mesa,ncurses,qca,qt,readline,util-linux,xz,zlib
appres.dep:libICE,libSM,libX11,libXau,libXdmcp,libXt,libxcb,util-linux
apr-util.dep:apr,cyrus-sasl,db44,expat,gcc,gcc-g++,icu4c,openldap-client,openssl|openssl-solibs,sqlite,util-linux
apr.dep:util-linux
ark.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,harfbuzz,json-c,kde-baseapps,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libarchive,libasyncns,libcap,libdbusmenu-qt,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,lzo,nettle,pcre,phonon,pulseaudio,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
artikulate.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,qt-gstreamer,soprano,sqlite,strigi,util-linux,xz,zlib
aspell.dep:gcc,gcc-g++,ncurses
at-spi2-atk.dep:at-spi2-core,atk,dbus,glib2,libICE,libSM,libX11,libXau,libXdmcp,libffi,libxcb,util-linux
at-spi2-core.dep:dbus,glib2,libICE,libSM,libX11,libXau,libXdmcp,libXevie,libXext,libXi,libXtst,libffi,libxcb,util-linux,zlib
atk.dep:glib2,libffi
atkmm.dep:atk,gcc,gcc-g++,glib2,glibmm,libffi,libsigc++
attica.dep:gcc,gcc-g++,glib2,qt,zlib
audacious-plugins.dep:alsa-lib,atk,attr,audacious,bzip2,cairo,curl,cyrus-sasl,dbus,dbus-glib,expat,flac,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,json-c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libcddb,libcdio,libcdio-paranoia,libdrm,libffi,libidn,libnotify,libogg,libpng,libproxy,libsamplerate,libsndfile,libssh2,libvorbis,libxcb,libxml2,libxshmfence,mesa,mpg123,neon,openldap-client,openssl|openssl-solibs,pango,pixman,pulseaudio,sdl,svgalib,util-linux,wavpack,xz,zlib
audacious.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
audiocd-kio.dep:acl,alsa-lib,attica,attr,bzip2,cdparanoia,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkcddb,libkcompactdisc,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
audiofile.dep:flac,gcc,gcc-g++,libogg
autofs.dep:cyrus-sasl,libxml2,openldap-client,openssl|openssl-solibs,xz,zlib
automoc4.dep:gcc,gcc-g++,glib2,qt,zlib
baloo-widgets.dep:acl,attica,attr,baloo,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,kfilemetadata,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qjson,qt,soprano,strigi,util-linux,xapian-core,xz,zlib
baloo.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdepimlibs,kfilemetadata,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libical,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,util-linux,xapian-core,xz,zlib
bash.dep:libtermcap
bc.dep:ncurses,readline
bdftopcf.dep:bzip2,freetype,glib2,harfbuzz,libXfont,libfontenc,libpng,zlib
beforelight.dep:libICE,libSM,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXt,libxcb,util-linux
bind.dep:attr,idnkit,libcap,libtermcap,libxml2,openssl|openssl-solibs,readline,xz,zlib
binutils.dep:flex
bitmap.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
blackbox.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXft,libXrender,libpng,libxcb,util-linux,zlib
blinken.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
bluedevil.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libbluedevil,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
blueman.dep:bluez,glib2,libffi,python
bluez.dep:dbus,eudev,glib2,libical,ncurses,readline
bomber.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
boost.dep:bzip2,gcc,gcc-g++,icu4c,zlib
bovo.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
bpe.dep:ncurses
btrfs-progs.dep:e2fsprogs,lzo,util-linux,zlib
cairo.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,lzo,mesa,pixman,zlib
cairomm.dep:bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libpng,libsigc++,libxcb,libxshmfence,mesa,pixman,zlib
calligra.dep:LibRaw,acl,akonadi,attica,attr,boost,bzip2,curl,cyrus-sasl,dbus,eudev,exiv2,expat,fftw,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glew,glib2,glu,gsl,gst-plugins-base,gstreamer,harfbuzz,icu4c,ilmbase,jasper,json-c,kactivities,kdelibs,kdepimlibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libical,libidn,libjpeg-turbo,libkdcraw,libkscreen,libodfgen,libogg,libpng,librevenge,libsndfile,libssh,libssh2,libtiff,libvisio,libvorbis,libwpd,libwpg,libxcb,libxml2,libxshmfence,libxslt,marble,mariadb,mesa,okular,openexr,openjpeg,openldap-client,openssl|openssl-solibs,orc,pcre,phonon,poppler,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,util-linux,xz,zlib
cantor.dep:acl,analitza,attica,attr,bzip2,cups,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,ghostscript,glib2,glu,gmp,gnutls,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libdbusmenu-qt,libdrm,libffi,libidn,libpng,libspectre,libxcb,libxml2,libxshmfence,mesa,nettle,p11-kit,python,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
ccache.dep:zlib
cdrdao.dep:gcc,gcc-g++,libao,libmad,libogg,libvorbis
cdrtools.dep:acl,attr,libcap,zlib
cervisia.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
cgmanager.dep:dbus,libnih
cifs-utils.dep:keyutils,libcap-ng,samba
clisp.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXpm,libxcb,ncurses,pcre,readline,util-linux,zlib
clucene.dep:gcc,gcc-g++,zlib
cmake.dep:acl,attr,bzip2,curl,cyrus-sasl,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libarchive,libffi,libidn,libpng,libssh2,libxcb,libxml2,lzo,ncurses,nettle,openldap-client,openssl|openssl-solibs,qt,util-linux,xz,zlib
compiz.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,fuse,gcc,gcc-g++,gdk-pixbuf2,glib2,glu,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libcroco,libdrm,libffi,libpng,librsvg,libwnck,libxcb,libxml2,libxshmfence,libxslt,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xz,zlib
conntrack-tools.dep:libmnl,libnetfilter_conntrack,libnetfilter_cthelper,libnetfilter_cttimeout,libnetfilter_queue,libnfnetlink
coreutils.dep:acl,attr,libcap
crda.dep:libgcrypt,libgpg-error,libnl3
cryptsetup.dep:eudev,libgcrypt,libgpg-error,lvm2,popt,util-linux
cscope.dep:ncurses
cups-filters.dep:bzip2,cups,cyrus-sasl,dbus,expat,fontconfig,freetype,gcc,gcc-g++,glib2,gmp,gnutls,harfbuzz,lcms2,libffi,libidn,libjpeg-turbo,libpng,libtiff,nettle,openjpeg,openldap-client,openssl|openssl-solibs,p11-kit,pcre,poppler,qpdf,xz,zlib
cups.dep:acl,attr,dbus,eudev,gcc,gcc-g++,gmp,gnutls,libffi,libidn,libusb,nettle,p11-kit,zlib
curl.dep:cyrus-sasl,libidn,libssh2,openldap-client,openssl|openssl-solibs,zlib
cyrus-sasl.dep:gdbm,openssl|openssl-solibs
db44.dep:gcc,gcc-g++
db48.dep:gcc,gcc-g++
dbus-glib.dep:dbus,expat,glib2,libffi,zlib
dbus-python.dep:dbus,dbus-glib,glib2,libffi,zlib,python
dbus.dep:expat,util-linux
dconf-editor.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,dconf,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,util-linux,xz,zlib
dconf.dep:dbus,glib2,libffi,zlib
ddd.dep:bzip2,elfutils,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXft,libXmu,libXp,libXpm,libXrender,libXt,libjpeg-turbo,libpng,libxcb,motif,ncurses,util-linux,zlib
ddrescue.dep:gcc,gcc-g++
desktop-file-utils.dep:glib2
dhcpcd.dep:eudev
dialog.dep:ncurses
dirmngr.dep:cyrus-sasl,libassuan,libgcrypt,libgpg-error,libksba,openldap-client,openssl|openssl-solibs,pth
distcc.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,popt,python,zlib
djvulibre.dep:gcc,gcc-g++,libjpeg-turbo,libtiff,xz,zlib
dnsmasq.dep:libidn
dolphin-plugins.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kde-baseapps,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
doxygen.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,util-linux,zlib
dragon.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
dvd+rw-tools.dep:gcc,gcc-g++
e2fsprogs.dep:util-linux
ebook-tools.dep:libxml2,libzip,xz,zlib
editres.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
efibootmgr.dep:zlib
electricsheep.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libglade,libjpeg-turbo,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,xz,zlib
elfutils.dep:bzip2,gcc,gcc-g++,xz,zlib
elm.dep:ncurses
elvis.dep:libtermcap
emacs.dep:acl,alsa-lib,atk,attr,bzip2,cairo,dbus,djvulibre,expat,fftw,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,giflib,glib2,gmp,gnutls,gpm,gtk+2,harfbuzz,ilmbase,imagemagick,lcms2,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXinerama,libXpm,libXrandr,libXrender,libXt,libXxf86vm,libcroco,libdrm,libffi,libidn,libjpeg-turbo,libpng,librsvg,libtiff,libwmf,libxcb,libxml2,libxshmfence,mesa,ncurses,nettle,openexr,openjpeg,p11-kit,pango,pixman,util-linux,xz,zlib
enchant.dep:aspell,gcc,gcc-g++,glib2,hunspell
epic5.dep:acl,attr,bzip2,gmp,libarchive,libxml2,lzo,ncurses,nettle,openssl|openssl-solibs,perl,ruby,tcl,xz,zlib
esound.dep:alsa-lib,audiofile,flac,gcc,gcc-g++,libogg
eudev.dep:kmod,util-linux,xz,zlib
exiv2.dep:curl,cyrus-sasl,expat,gcc,gcc-g++,libgcrypt,libgpg-error,libidn,libssh,libssh2,openldap-client,openssl|openssl-solibs,zlib
exo.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,zlib
expect.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXft,libXrender,libpng,libxcb,tcl,tk,zlib
fetchmail.dep:openssl|openssl-solibs
fftw.dep:gcc
file.dep:zlib
filelight.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
flac.dep:gcc,gcc-g++,libogg
fluxbox.dep:bzip2,expat,fontconfig,freetype,fribidi,gcc,gcc-g++,glib2,harfbuzz,libX11,libXau,libXdmcp,libXext,libXft,libXinerama,libXpm,libXrandr,libXrender,libpng,libxcb,zlib
fontconfig.dep:bzip2,expat,freetype,glib2,harfbuzz,libpng,zlib
fonttosfnt.dep:bzip2,freetype,glib2,harfbuzz,libfontenc,libpng,zlib
foomatic-filters.dep:dbus
freeglut.dep:expat,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrandr,libXrender,libXxf86vm,libdrm,libxcb,libxshmfence,mesa
freetype.dep:bzip2,glib2,harfbuzz,libpng,zlib
fslsfonts.dep:libFS
fstobdf.dep:libFS,libX11,libXau,libXdmcp,libxcb
fvwm.dep:bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXinerama,libXpm,libXrender,libXxf86vm,libcroco,libdrm,libffi,libpng,librsvg,libtermcap,libxcb,libxml2,libxshmfence,mesa,pango,pixman,readline,util-linux,xz,zlib
gamin.dep:glib2
garcon.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,zlib
gawk.dep:gmp,libsigsegv,libtermcap,mpfr,readline
gc.dep:gcc,gcc-g++
gcc-g++.dep:gcc,gmp,libmpc,mpfr,zlib
gcc-gfortran.dep:gcc,gmp,libmpc,mpfr,zlib
gcc-gnat.dep:gcc,gmp,libmpc,mpfr,zlib
gcc-go.dep:gcc,gmp,libmpc,mpfr,zlib
gcc-java.dep:gcc,util-linux,zlib
gcc-objc.dep:gcc,gmp,libmpc,mpfr,zlib
gcc.dep:gmp,libmpc,mpfr,zlib
gcr.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libgcrypt,libgpg-error,libpng,libxcb,libxshmfence,mesa,p11-kit,pango,pixman,util-linux,zlib
gd.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdmcp,libXpm,libjpeg-turbo,libpng,libtiff,libxcb,xz,zlib
gdb.dep:expat,gc,gmp,guile,libffi,libtool,libunistring,ncurses,python,xz
gdk-pixbuf2.dep:glib2,libX11,libXau,libXdmcp,libffi,libjpeg-turbo,libpng,libtiff,libxcb,xz,zlib
geeqie.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,curl,cyrus-sasl,dbus,exiv2,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+3,harfbuzz,lcms2,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libpng,libssh,libssh2,libtiff,libxcb,libxshmfence,mesa,openldap-client,openssl|openssl-solibs,pango,pixman,util-linux,xz,zlib
gegl.dep:babl,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,harfbuzz,ilmbase,jasper,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrandr,libXrender,libXxf86vm,libcroco,libdrm,libffi,libjpeg-turbo,libpng,librsvg,libxcb,libxml2,libxshmfence,mesa,openexr,pango,pixman,sdl,svgalib,xz,zlib
gettext-tools.dep:acl,attr,gcc,glib2,libcroco,libunistring,libxml2,ncurses,xz,zlib
gettext.dep:gcc,gcc-g++
getty-ps.dep:libtermcap
gftp.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,ncurses,openssl|openssl-solibs,pango,pixman,readline,zlib
ghostscript.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,cups,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gmp,gnutls,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libepoxy,libffi,libidn,libpng,libxcb,libxshmfence,mesa,nettle,p11-kit,pango,pixman,util-linux,zlib
gimp.dep:aalib,alsa-lib,atk,babl,bzip2,cairo,cups,dbus,dbus-glib,eudev,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,gegl,ghostscript,glib2,gmp,gnutls,gpm,gtk+2,harfbuzz,jasper,lcms2,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXmu,libXpm,libXrandr,libXrender,libXt,libXxf86vm,libcroco,libdrm,libexif,libffi,libgudev,libidn,libjpeg-turbo,libmng,libpng,librsvg,libtiff,libwmf,libxcb,libxml2,libxshmfence,mesa,ncurses,nettle,openjpeg,p11-kit,pango,pixman,poppler,slang,util-linux,xz,zlib
git.dep:curl,cyrus-sasl,expat,libidn,libssh2,openldap-client,openssl|openssl-solibs,zlib
gkrellm.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,lm_sensors,mesa,openssl|openssl-solibs,pango,pixman,util-linux,zlib
glade3.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,python,xz,zlib
glew.dep:expat,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXxf86vm,libdrm,libxcb,libxshmfence,mesa
glib-networking.dep:gcc,gcc-g++,glib2,gmp,gnutls,js185,libffi,libidn,libproxy,mozilla-nss,nettle,p11-kit,zlib
glib2.dep:gamin,libffi,zlib
glibmm.dep:gcc,gcc-g++,glib2,libffi,libsigc++,zlib
glu.dep:expat,gcc,gcc-g++,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXxf86vm,libdrm,libxcb,libxshmfence,mesa
gmime.dep:glib2,libffi,zlib
gmp.dep:gcc,gcc-g++
gnome-keyring.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gcr,gdk-pixbuf2,glib2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libgcrypt,libgpg-error,libpng,libxcb,libxshmfence,mesa,p11-kit,pango,pixman,util-linux,zlib
gnome-themes-standard.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
gnu-cobol.dep:db48,gmp,ncurses
gnuchess.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdbm,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libcroco,libdrm,libffi,libpng,librsvg,libxcb,libxml2,libxshmfence,mesa,ncurses,pango,pixman,readline,xz,zlib
gnupg.dep:bzip2,curl,cyrus-sasl,eudev,libidn,libssh2,libtermcap,libusb,libusb-compat,openldap-client,openssl|openssl-solibs,readline,zlib
gnupg2.dep:bzip2,curl,cyrus-sasl,eudev,libassuan,libgcrypt,libgpg-error,libidn,libksba,libssh2,libtermcap,libusb,libusb-compat,openldap-client,openssl|openssl-solibs,pth,readline,zlib
gnuplot.dep:bzip2,cairo,expat,fontconfig,freeglut,freetype,gcc,gcc-g++,gd,glib2,glu,harfbuzz,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXpm,libXrandr,libXrender,libXxf86vm,libcaca,libdrm,libffi,libjpeg-turbo,libpng,libtiff,libxcb,libxshmfence,mesa,ncurses,pango,pixman,qt,slang,util-linux,xz,zlib
gnutls.dep:gc,gcc,gcc-g++,gmp,guile,libffi,libidn,libtool,libunistring,nettle,p11-kit,zlib
gobject-introspection.dep:glib2,libffi,zlib
gpa.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gpgme,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libassuan,libdrm,libffi,libgpg-error,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
gparted.dep:atk,atkmm,bzip2,cairo,cairomm,eudev,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glibmm,gtk+2,gtkmm2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libsigc++,libxcb,libxshmfence,lvm2,mesa,pango,pangomm,parted,pixman,util-linux,zlib
gperf.dep:gcc,gcc-g++
gpgme.dep:libassuan,libgpg-error
gphoto2.dep:aalib,gpm,libX11,libXau,libXdmcp,libexif,libgphoto2,libjpeg-turbo,libtool,libxcb,ncurses,popt,readline,slang,slang1
gpm.dep:ncurses
gptfdisk.dep:gcc,gcc-g++,ncurses,popt,util-linux
granatier.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
grantlee.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,util-linux,zlib
grep.dep:pcre
groff.dep:gcc,gcc-g++,util-linux
grub.dep:bzip2,eudev,freetype,fuse,glib2,harfbuzz,libpng,lvm2,xz,zlib
gst-plugins-base.dep:gstreamer,zlib
gst-plugins-base0.dep:gstreamer0,util-linux,xz,zlib
gst-plugins-good.dep:gst-plugins-base,gstreamer,util-linux,xz,zlib
gst-plugins-good0.dep:GConf,gst-plugins-base0,gstreamer0,util-linux,xz,zlib
gstreamer.dep:attr,glib2,libcap,libffi,zlib
gstreamer0.dep:glib2,libffi,libxml2,xz,zlib
gtk+.dep:glib,libX11,libXau,libXdmcp,libXext,libxcb
gtk+2.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gmp,gnutls,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libidn,libpng,libxcb,libxshmfence,mesa,nettle,p11-kit,pango,pixman,zlib
gtk+3.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gmp,gnutls,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libidn,libpng,libxcb,libxshmfence,mesa,nettle,p11-kit,pango,pixman,util-linux,zlib
gtk-xfce-engine.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
gtkmm2.dep:atk,atkmm,bzip2,cairo,cairomm,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glibmm,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libsigc++,libxcb,libxshmfence,mesa,pango,pangomm,pixman,zlib
gtkmm3.dep:at-spi2-atk,at-spi2-core,atk,atkmm,bzip2,cairo,cairomm,dbus,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glibmm,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libsigc++,libxcb,libxshmfence,mesa,pango,pangomm,pixman,util-linux,zlib
gtkspell.dep:atk,bzip2,cairo,enchant,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
gucharmap.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,util-linux,zlib
guile.dep:gc,gmp,libffi,libtool,libunistring,ncurses,readline
gutenprint.dep:atk,bzip2,cairo,cups,eudev,expat,fontconfig,freetype,gdk-pixbuf2,gimp,glib2,gmp,gnutls,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libidn,libpng,libusb,libxcb,libxshmfence,mesa,ncurses,nettle,p11-kit,pango,pixman,readline,zlib
gv.dep:libICE,libSM,libX11,libXau,libXaw3d,libXdmcp,libXext,libXinerama,libXmu,libXpm,libXt,libxcb,util-linux
gvfs.dep:acl,at-spi2-atk,at-spi2-core,atk,attr,bzip2,cairo,cyrus-sasl,dbus,e2fsprogs,eudev,expat,fontconfig,freetype,fuse,gcc,gcc-g++,gcr,gdk-pixbuf2,glib2,gmp,gnutls,gtk+3,harfbuzz,icu4c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libarchive,libcap,libcdio,libcdio-paranoia,libdrm,libepoxy,libexif,libffi,libgcrypt,libgpg-error,libgphoto2,libgudev,libidn,libimobiledevice,libmtp,libplist,libpng,libsecret,libsoup,libtool,libusb,libusbmuxd,libxcb,libxml2,libxshmfence,lzo,mesa,nettle,openldap-client,openssl|openssl-solibs,p11-kit,pango,pixman,sqlite,udisks2,util-linux,xz,zlib
gwenview.dep:LibRaw,acl,attica,attr,baloo,bzip2,curl,cyrus-sasl,dbus,eudev,exiv2,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,jasper,json-c,kactivities,kde-baseapps,kdelibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libkdcraw,libkipi,libogg,libpng,libsndfile,libssh,libssh2,libvorbis,libxcb,libxml2,libxshmfence,mesa,openldap-client,openssl|openssl-solibs,phonon,pulseaudio,qca,qjson,qt,soprano,strigi,util-linux,xapian-core,xz,zlib
harfbuzz.dep:bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,glib2,icu4c,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libpng,libxcb,libxshmfence,mesa,pixman,zlib
herqq.dep:gcc,gcc-g++,glib2,qt,zlib
hexchat.dep:atk,bzip2,cairo,dbus,dbus-glib,eudev,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,js185,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libcanberra,libdrm,libffi,libnotify,libogg,libpng,libproxy,libtool,libvorbis,libxcb,libxshmfence,mesa,mozilla-nss,openssl,pango,pciutils,perl,pixman,python,samba,zlib
hfsutils.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXft,libXrender,libpng,libxcb,zlib
hplip.dep:cups,dbus,eudev,gcc,gcc-g++,gmp,gnutls,libexif,libffi,libgphoto2,libidn,libieee1284,libjpeg-turbo,libtiff,libtool,libusb,net-snmp,nettle,openssl|openssl-solibs,p11-kit,sane,v4l-utils,xz,zlib
htdig.dep:gcc,gcc-g++,openssl|openssl-solibs,zlib
htop.dep:ncurses
httpd.dep:apr,apr-util,cyrus-sasl,db44,expat,gcc,gcc-g++,icu4c,libxml2,openldap-client,openssl|openssl-solibs,pcre,sqlite,util-linux,xz,zlib
hunspell.dep:gcc,gcc-g++,ncurses,readline
iceauth.dep:libICE
ico.dep:libX11,libXau,libXdmcp,libxcb
icu4c.dep:gcc,gcc-g++
iftop.dep:dbus,eudev,libnl3,libpcap,libusb,ncurses
ilmbase.dep:gcc,gcc-g++
imagemagick.dep:bzip2,cairo,djvulibre,expat,fftw,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,harfbuzz,ilmbase,lcms2,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXt,libXxf86vm,libcroco,libdrm,libffi,libjpeg-turbo,libpng,librsvg,libtiff,libwmf,libxcb,libxml2,libxshmfence,mesa,openexr,openjpeg,pango,pixman,util-linux,xz,zlib
imapd.dep:cyrus-sasl,ncurses,openldap-client,openssl|openssl-solibs
infozip.dep:bzip2
intel-gpu-tools.dep:bzip2,cairo,eudev,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrandr,libXrender,libXv,libXxf86vm,libdrm,libpciaccess,libpng,libxcb,libxshmfence,mesa,pixman,zlib
iproute2.dep:db48,dbus,eudev,iptables,libnl3,libpcap,libusb
ipset.dep:libmnl
iptables.dep:dbus,eudev,libmnl,libnetfilter_conntrack,libnfnetlink,libnl3,libpcap,libusb
iptraf-ng.dep:ncurses
iputils.dep:attr,gmp,gnutls,libcap,libffi,libidn,nettle,p11-kit,zlib
irssi.dep:glib2,ncurses,openssl|openssl-solibs,perl
iw.dep:libnl3
jasper.dep:expat,freeglut,gcc,gcc-g++,glu,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXmu,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libjpeg-turbo,libxcb,libxshmfence,mesa,util-linux
jed.dep:gpm,ncurses,slang
jfsutils.dep:util-linux
joe.dep:ncurses
jove.dep:libtermcap
js185.dep:gcc,gcc-g++,mozilla-nss,zlib
juk.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,pcre,phonon,pulseaudio,qca,qt,soprano,strigi,taglib,utempter,util-linux,xz,zlib
k3b.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libdvdread,libffi,libjpeg-turbo,libkcddb,libmad,libogg,libpng,libsamplerate,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,taglib,utempter,util-linux,xz,zlib
kaccessible.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kactivities.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,nepomuk-core,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kalgebra.dep:acl,analitza,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kalzium.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,pcre,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kamera.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libexif,libffi,libgphoto2,libpng,libtool,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kanagram.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libkdeedu,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kapman.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kapptemplate.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kate.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,python,qca,qjson,qt,soprano,sqlite,strigi,util-linux,xz,zlib
katomic.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kaudiocreator.dep:acl,alsa-lib,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libdiscid,libffi,libkcddb,libkcompactdisc,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,taglib,util-linux,xz,zlib
kblackbox.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kblocks.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kbounce.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kbreakout.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kbruch.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kcachegrind.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kcalc.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gmp,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kcharselect.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kcolorchooser.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kcron.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kde-baseapps.dep:acl,attica,attr,baloo,baloo-widgets,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kdelibs,kdewebdev,kfilemetadata,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXt,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,pcre,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,utempter,util-linux,xapian-core,xz,zlib
kde-dev-utils.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kde-runtime.dep:acl,alsa-lib,attica,attr,bzip2,curl,cyrus-sasl,dbus,e2fsprogs,eudev,exiv2,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gmp,gnutls,gpgme,gst-plugins-base,gstreamer,harfbuzz,icu4c,ilmbase,json-c,kactivities,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libassuan,libasyncns,libcanberra,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libogg,libpng,libsndfile,libssh,libssh2,libtool,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,nettle,openexr,openldap-client,openssl|openssl-solibs,orc,p11-kit,pcre,phonon,pulseaudio,qca,qt,samba,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
kde-workspace.dep:ConsoleKit2,acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib,glib2,glu,gst-plugins-base,gstreamer,gtk+,harfbuzz,icu4c,json-c,kactivities,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXinerama,libXpm,libXrandr,libXrender,libXres,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libical,libjpeg-turbo,libogg,libpng,libraw1394,libsndfile,libusb,libusb-compat,libvorbis,libxcb,libxkbfile,libxml2,libxshmfence,libxslt,lm_sensors,mesa,nepomuk-core,orc,pcre,phonon,pulseaudio,qca,qimageblitz,qjson,qt,soprano,sqlite,strigi,utempter,util-linux,xcb-util,xcb-util-image,xcb-util-keysyms,xmms,xz,zlib
kdeartwork.dep:acl,attica,attr,bzip2,curl,cyrus-sasl,eudev,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,harfbuzz,kde-workspace,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXt,libXtst,libXxf86vm,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libidn,libkexiv2,libpng,libssh,libssh2,libxcb,libxml2,libxshmfence,mesa,openldap-client,openssl|openssl-solibs,qca,qt,soprano,strigi,util-linux,xz,zlib
kdeconnect-kde.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libfakekey,libffi,libpng,libxcb,libxml2,qca,qjson,qt,soprano,strigi,util-linux,xz,zlib
kdegraphics-mobipocket.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kdegraphics-strigi-analyzer.dep:bzip2,gcc,gcc-g++,libjpeg-turbo,libtiff,libxml2,strigi,xz,zlib
kdegraphics-thumbnailers.dep:LibRaw,acl,attica,attr,bzip2,curl,cyrus-sasl,eudev,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,jasper,kdelibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libkdcraw,libkexiv2,libpng,libssh,libssh2,libxcb,libxml2,openldap-client,openssl|openssl-solibs,qca,qt,soprano,strigi,util-linux,xz,zlib
kdelibs.dep:acl,aspell,attica,attr,bzip2,dbus,enchant,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,ilmbase,jasper,json-c,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,openexr,orc,pcre,phonon,polkit,polkit-qt-1,pulseaudio,qca,qt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
kdenetwork-filesharing.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kdenetwork-strigi-analyzers.dep:bzip2,gamin,gcc,gcc-g++,glib2,kdelibs,libxml2,qt,strigi,xz,zlib
kdepim-runtime.dep:acl,akonadi,attica,attr,bzip2,cyrus-sasl,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libical,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qjson,qt,soprano,strigi,util-linux,xz,zlib
kdepim.dep:acl,akonadi,attica,attr,baloo,bzip2,cyrus-sasl,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gpgme,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libassuan,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgpg-error,libical,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,openldap-client,openssl|openssl-solibs,orc,pcre,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,utempter,util-linux,xapian-core,xz,zlib
kdepimlibs.dep:acl,akonadi,attica,attr,bzip2,cyrus-sasl,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gpgme,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libassuan,libasyncns,libcap,libdbusmenu-qt,libffi,libgpg-error,libical,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,openldap-client,openssl|openssl-solibs,phonon,pulseaudio,qca,qjson,qt,soprano,strigi,util-linux,xz,zlib
kdeplasma-addons.dep:acl,akonadi,attica,attr,bzip2,curl,cyrus-sasl,dbus,eudev,exiv2,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kde-workspace,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libical,libidn,libjpeg-turbo,libkexiv2,libogg,libpng,libsndfile,libssh,libssh2,libtool,libvorbis,libxcb,libxml2,libxshmfence,libxslt,marble,mesa,openldap-client,openssl|openssl-solibs,orc,phonon,pulseaudio,qca,qimageblitz,qjson,qt,scim,soprano,sqlite,strigi,util-linux,xz,zlib
kdesdk-kioslaves.dep:acl,apr,apr-util,attica,attr,bzip2,cyrus-sasl,db44,eudev,expat,file,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,icu4c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,openldap-client,openssl|openssl-solibs,qca,qt,serf,soprano,sqlite,strigi,subversion,util-linux,xz,zlib
kdesdk-strigi-analyzers.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kdesdk-thumbnailers.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,gettext-tools,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libunistring,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kdev-python.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdevplatform,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kdevelop-pg-qt.dep:gcc,gcc-g++,glib2,qt,zlib
kdevelop-php-docs.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdevplatform,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kdevelop-php.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdevplatform,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kdevelop.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kde-workspace,kdelibs,kdevplatform,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXres,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,okteta,orc,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kdevplatform.dep:acl,apr,apr-util,attica,attr,bzip2,cyrus-sasl,db44,dbus,eudev,expat,file,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,openldap-client,openssl|openssl-solibs,orc,phonon,pulseaudio,qca,qjson,qt,serf,soprano,sqlite,strigi,subversion,util-linux,xz,zlib
kdewebdev.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,harfbuzz,json-c,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,pcre,phonon,pulseaudio,qca,qjson,qt,soprano,strigi,utempter,util-linux,xz,zlib
kdf.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kdiamond.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
keybinder.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,util-linux,zlib
kfilemetadata.dep:acl,attica,attr,bzip2,curl,cyrus-sasl,ebook-tools,eudev,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdegraphics-mobipocket,kdelibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libpng,libssh,libssh2,libtiff,libxcb,libxml2,libzip,openjpeg,openldap-client,openssl|openssl-solibs,poppler,qca,qt,soprano,strigi,taglib,util-linux,xz,zlib
kfloppy.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
kfourinline.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kgamma.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kgeography.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
kget.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gmp,gpgme,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kde-workspace,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libassuan,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libjpeg-turbo,libktorrent,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,nepomuk-core,nepomuk-widgets,orc,pcre,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kgoldrunner.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kgpg.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libical,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qjson,qt,soprano,strigi,util-linux,xz,zlib
khangman.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdeedu,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kig.dep:acl,attica,attr,boost,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,python,qca,qt,soprano,strigi,util-linux,xz,zlib
kigo.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
killbots.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kio-mtp.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libmtp,libpng,libusb,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kiriki.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kiten.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,pcre,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kjumpingcube.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
klettres.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
klickety.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
klines.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kmag.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kmahjongg.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libkmahjongg,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kmines.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kmix.dep:acl,alsa-lib,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcanberra,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libtool,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,samba,soprano,sqlite,strigi,util-linux,xz,zlib
kmod.dep:xz,zlib
kmousetool.dep:attica,attr,bzip2,dbus,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,phonon,pulseaudio,qca,qt,util-linux,xz,zlib
kmouth.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
kmplot.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
knavalbattle.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
knetwalk.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kolf.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kollision.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kolourpaint.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qimageblitz,qt,soprano,strigi,util-linux,xz,zlib
kompare.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libkomparediff2,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
konquest.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
konsole.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kde-baseapps,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
kopete.dep:acl,akonadi,attica,attr,baloo,bzip2,cyrus-sasl,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib,glib2,gpgme,gst-plugins-base,gstreamer,gtk+,harfbuzz,icu4c,jasper,json-c,kdelibs,kdepim,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libassuan,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgpg-error,libical,libidn,libjpeg-turbo,libmsn,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,openldap-client,openssl|openssl-solibs,orc,pcre,phonon,pulseaudio,qca,qimageblitz,qjson,qt,soprano,sqlite,strigi,utempter,util-linux,v4l-utils,xapian-core,xmms,xz,zlib
korundum.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gmp,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kate,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libical,libjpeg-turbo,libkscreen,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,okular,orc,pcre,phonon,pulseaudio,qca,qjson,qt,qtruby,ruby,smokegen,smokekde,smokeqt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
kpat.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kplayer.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
kppp.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,utempter,util-linux,xz,zlib
kqtquickcharts.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
krdc.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gmp,gnutls,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libogg,libpng,libsndfile,libvncserver,libvorbis,libxcb,libxml2,nettle,openssl|openssl-solibs,p11-kit,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kremotecontrol.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kreversi.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
krfb.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libjpeg-turbo,libpng,libxcb,qca,qt,util-linux,xz,zlib
kross-interpreters.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,python,qca,qt,utempter,util-linux,xz,zlib
kruler.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
ksaneplugin.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libexif,libffi,libgphoto2,libieee1284,libjpeg-turbo,libksane,libpng,libtiff,libtool,libusb,libxcb,libxml2,qca,qt,sane,soprano,strigi,util-linux,v4l-utils,xz,zlib
kscreen.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrandr,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libkscreen,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qjson,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kshisen.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libkmahjongg,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ksirk.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ksnakeduel.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ksnapshot.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libkipi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kspaceduel.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ksquares.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kstars.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libdbusmenu-qt,libdrm,libffi,libpng,libxcb,libxml2,libxshmfence,mesa,qca,qjson,qt,soprano,strigi,util-linux,xz,zlib
ksudoku.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,mesa,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ksystemlog.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kteatime.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
ktimer.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
ktorrent.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gmp,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kde-workspace,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libgcrypt,libgpg-error,libjpeg-turbo,libktorrent,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,taglib,util-linux,xz,zlib
ktouch.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxkbfile,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
ktuberling.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kturtle.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
ktux.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kde-workspace,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kubrick.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,glu,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,mesa,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
kuser.dep:acl,attica,attr,bzip2,cyrus-sasl,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,kdepimlibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,openldap-client,openssl|openssl-solibs,qca,qt,soprano,strigi,util-linux,xz,zlib
kwalletmanager.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
kwebkitpart.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libpng,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
kwordquiz.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdeedu,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
lcms.dep:libjpeg-turbo,libtiff,xz,zlib
lcms2.dep:libjpeg-turbo,libtiff,xz,zlib
less.dep:ncurses
lftp.dep:expat,gcc,gcc-g++,libidn,ncurses,openssl|openssl-solibs,readline,zlib
libSM.dep:libICE,util-linux
libX11.dep:libXau,libXdmcp,libxcb
libXScrnSaver.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXaw.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
libXaw3d.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
libXaw3dXft.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXft,libXmu,libXpm,libXrender,libXt,libpng,libxcb,util-linux,zlib
libXcm.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXfixes,libXmu,libXt,libxcb,util-linux
libXcomposite.dep:libX11,libXau,libXdmcp,libxcb
libXcursor.dep:libX11,libXau,libXdmcp,libXfixes,libXrender,libxcb
libXdamage.dep:libX11,libXau,libXdmcp,libXfixes,libxcb
libXevie.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXext.dep:libX11,libXau,libXdmcp,libxcb
libXfixes.dep:libX11,libXau,libXdmcp,libxcb
libXfont.dep:bzip2,freetype,glib2,harfbuzz,libfontenc,libpng,zlib
libXfontcache.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXft.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdmcp,libXrender,libpng,libxcb,zlib
libXi.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXinerama.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXmu.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXt,libxcb,util-linux
libXp.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXpm.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXt,libxcb,util-linux
libXpresent.dep:libX11,libXau,libXdmcp,libxcb
libXrandr.dep:libX11,libXau,libXdmcp,libXext,libXrender,libxcb
libXrender.dep:libX11,libXau,libXdmcp,libxcb
libXres.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXt.dep:libICE,libSM,libX11,libXau,libXdmcp,libxcb,util-linux
libXtst.dep:libX11,libXau,libXdmcp,libXext,libXi,libxcb
libXv.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXvMC.dep:libX11,libXau,libXdmcp,libXext,libXv,libxcb
libXxf86dga.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXxf86misc.dep:libX11,libXau,libXdmcp,libXext,libxcb
libXxf86vm.dep:libX11,libXau,libXdmcp,libXext,libxcb
libarchive.dep:acl,attr,bzip2,libxml2,lzo,nettle,xz,zlib
libassuan.dep:libgpg-error
libatasmart.dep:eudev
libbluedevil.dep:gcc,gcc-g++,glib2,qt,zlib
libcaca.dep:expat,freeglut,gcc,gcc-g++,glu,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrandr,libXrender,libXxf86vm,libdrm,libxcb,libxshmfence,mesa,ncurses,slang,zlib
libcanberra.dep:eudev,libogg,libtool,libvorbis,samba
libcap.dep:attr
libcddb.dep:libcdio
libcdio-paranoia.dep:libcdio
libcdio.dep:gcc,gcc-g++,libcddb,ncurses
libcroco.dep:glib2,libxml2,xz,zlib
libdbusmenu-qt.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,util-linux,zlib
libdmx.dep:libX11,libXau,libXdmcp,libXext,libxcb
libdrm.dep:libpciaccess
libdvdnav.dep:libdvdread
libevent.dep:openssl|openssl-solibs
libfakekey.dep:libX11,libXau,libXdmcp,libXext,libXi,libXtst,libxcb
libfontenc.dep:zlib
libgcrypt.dep:libgpg-error
libglade.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,xz,zlib
libgnome-keyring.dep:dbus,glib2,libffi,libgcrypt,libgpg-error
libgphoto2.dep:bzip2,eudev,expat,fontconfig,freetype,gd,glib2,harfbuzz,libX11,libXau,libXdmcp,libXpm,libexif,libjpeg-turbo,libpng,libtiff,libtool,libusb,libxcb,libxml2,xz,zlib
libgpod.dep:eudev,gcc,gcc-g++,gdk-pixbuf2,glib2,icu4c,libffi,libimobiledevice,libplist,libpng,libusb,libusbmuxd,libxml2,openssl|openssl-solibs,sg3_utils,sqlite,xz,zlib
libgsf.dep:bzip2,gdk-pixbuf2,glib2,libffi,libpng,libxml2,xz,zlib
libgudev.dep:eudev,glib2,libffi,zlib
libid3tag.dep:zlib
libidl.dep:glib2
libimobiledevice.dep:libplist,libusbmuxd,libxml2,openssl|openssl-solibs,xz,zlib
libiodbc.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
libkarma.dep:eudev,gcc,gcc-g++,libusb,libusb-compat,taglib,zlib
libkcddb.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
libkcompactdisc.dep:alsa-lib,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXrender,libXtst,libasyncns,libcap,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,phonon,pulseaudio,qt,util-linux,xz,zlib
libkdcraw.dep:LibRaw,acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,jasper,kdelibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libjpeg-turbo,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
libkdeedu.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
libkdegames.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
libkexiv2.dep:attica,bzip2,curl,cyrus-sasl,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libpng,libssh,libssh2,libxcb,openldap-client,openssl|openssl-solibs,qca,qt,util-linux,xz,zlib
libkipi.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
libkmahjongg.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qt,util-linux,xz,zlib
libkomparediff2.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
libksane.dep:attica,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libexif,libffi,libgphoto2,libieee1284,libjpeg-turbo,libpng,libtiff,libtool,libusb,libxcb,qca,qt,sane,util-linux,v4l-utils,xz,zlib
libksba.dep:libgpg-error
libkscreen.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrandr,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,qca,qjson,qt,util-linux,xz,zlib
libktorrent.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gmp,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
liblastfm.dep:fftw,gcc,gcc-g++,glib2,libsamplerate,qt,zlib
libmbim.dep:eudev,glib2,libffi,libgudev,zlib
libmcs.dep:libmowgli
libmm-qt.dep:gcc,gcc-g++,glib2,qt,zlib
libmng.dep:lcms2,libjpeg-turbo,zlib
libmpc.dep:gmp,mpfr
libmsn.dep:gcc,gcc-g++,openssl|openssl-solibs
libmtp.dep:eudev,libgcrypt,libgpg-error,libusb
libnetfilter_acct.dep:libmnl
libnetfilter_conntrack.dep:libmnl,libnfnetlink
libnetfilter_cthelper.dep:libmnl
libnetfilter_cttimeout.dep:libmnl
libnetfilter_log.dep:libnfnetlink
libnetfilter_queue.dep:libmnl,libnfnetlink
libnftnl.dep:libmnl
libnih.dep:dbus,expat
libnjb.dep:eudev,libusb,libusb-compat,ncurses,zlib
libnm-qt.dep:gcc,gcc-g++,glib2,libmm-qt,qt,zlib
libnotify.dep:gdk-pixbuf2,glib2,libffi,libpng,zlib
libodfgen.dep:gcc,gcc-g++,librevenge,zlib
liboggz.dep:libogg
libpcap.dep:dbus,eudev,libnl3,libusb
libplist.dep:gcc,gcc-g++,libxml2,xz,zlib
libpng.dep:zlib
libqmi.dep:glib2,libffi,zlib
librevenge.dep:gcc,gcc-g++,zlib
librsvg.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libcroco,libdrm,libepoxy,libffi,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,util-linux,xz,zlib
libsamplerate.dep:flac,libogg,libsndfile,libvorbis
libsecret.dep:glib2,libffi,libgcrypt,libgpg-error,zlib
libsigc++.dep:gcc,gcc-g++
libsndfile.dep:alsa-lib,flac,gcc,gcc-g++,icu4c,libogg,libvorbis,sqlite
libsoup.dep:gcc,gcc-g++,glib2,icu4c,libffi,libxml2,sqlite,xz,zlib
libspectre.dep:bzip2,cups,expat,fontconfig,freetype,ghostscript,glib2,gmp,gnutls,harfbuzz,libffi,libidn,libpng,nettle,p11-kit,zlib
libssh.dep:libgcrypt,libgpg-error,zlib
libssh2.dep:openssl|openssl-solibs,zlib
libtheora.dep:libogg
libtiff.dep:expat,freeglut,gcc,gcc-g++,glu,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrandr,libXrender,libXxf86vm,libdrm,libjpeg-turbo,libxcb,libxshmfence,mesa,util-linux,xz,zlib
libusb-compat.dep:eudev,libusb
libusb.dep:eudev
libusbmuxd.dep:libplist,libxml2,xz,zlib
libva-intel-driver.dep:libdrm,libpciaccess
libva.dep:expat,gcc,gcc-g++,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXxf86vm,libdrm,libxcb,libxshmfence,mesa
libvdpau.dep:gcc,gcc-g++,libX11,libXau,libXdmcp,libXext,libxcb
libvisio.dep:gcc,gcc-g++,icu4c,librevenge,libxml2,xz,zlib
libvisual-plugins.dep:alsa-lib,atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gstreamer0,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libvisual,libxcb,libxml2,libxshmfence,mesa,pango,pixman,xz,zlib
libvncserver.dep:gmp,gnutls,libX11,libXau,libXdmcp,libXext,libXrandr,libXrender,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libpng,libxcb,nettle,openssl|openssl-solibs,p11-kit,sdl,svgalib,zlib
libvorbis.dep:libogg
libvpx.dep:gcc,gcc-g++
libwmf.dep:bzip2,expat,freetype,gdk-pixbuf2,glib2,harfbuzz,libX11,libXau,libXdmcp,libffi,libjpeg-turbo,libpng,libxcb,zlib
libwnck.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,startup-notification,xcb-util,zlib
libwpd.dep:gcc,gcc-g++,librevenge,zlib
libwpg.dep:gcc,gcc-g++,librevenge,libwpd,zlib
libxcb.dep:libXau,libXdmcp
libxfce4ui.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libxcb,libxfce4util,libxml2,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,xz,zlib
libxfce4util.dep:glib2
libxkbfile.dep:libX11,libXau,libXdmcp,libxcb
libxklavier.dep:glib2,libX11,libXau,libXdmcp,libXext,libXi,libffi,libxcb,libxkbfile,libxml2,xz,zlib
libxml2.dep:python,xz,zlib
libxslt.dep:libgcrypt,libgpg-error,libxml2,python,xz,zlib
libzip.dep:zlib
lilo.dep:eudev,lvm2
links.dep:bzip2,cairo,expat,fontconfig,freetype,gcc,gdk-pixbuf2,glib2,gpm,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libcroco,libdrm,libevent,libffi,libjpeg-turbo,libpng,librsvg,libtiff,libxcb,libxml2,libxshmfence,mesa,ncurses,openssl|openssl-solibs,pango,pixman,svgalib,xz,zlib
linuxdoc-tools.dep:flex,gcc,gcc-g++
listres.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
llvm.dep:gcc,gcc-g++,libffi,ncurses,zlib
logrotate.dep:popt
lokalize.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,hunspell,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
loudmouth.dep:glib2,gmp,gnutls,libffi,libidn,nettle,p11-kit,zlib
lrzip.dep:bzip2,gcc,gcc-g++,lzo,zlib
lskat.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
luit.dep:libfontenc,zlib
lvm2.dep:eudev,util-linux
lxc.dep:attr,cgmanager,dbus,libcap,libnih
lynx.dep:bzip2,ncurses,openssl|openssl-solibs,zlib
lzip.dep:gcc,gcc-g++
m17n-lib.dep:anthy,libxml2,xz,zlib
madplay.dep:alsa-lib,audiofile,esound,flac,gcc,gcc-g++,libid3tag,libmad,libogg,zlib
mailx.dep:openssl|openssl-solibs
make.dep:gc,gmp,guile,libffi,libtool,libunistring
marble.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
mariadb.dep:gcc,gcc-g++,jemalloc,judy,libaio,libxml2,ncurses,openssl|openssl-solibs,pcre,xz,zlib
mc.dep:glib2,gpm,libssh2,ncurses,openssl|openssl-solibs,slang,zlib
mcabber.dep:glib2,gmp,gnutls,gpgme,libassuan,libffi,libgpg-error,libidn,loudmouth,ncurses,nettle,p11-kit,zlib
mercurial.dep:python
mesa.dep:elfutils,expat,freeglut,gcc,gcc-g++,glew,glu,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrandr,libXrender,libXv,libXvMC,libXxf86vm,libdrm,libffi,libpciaccess,libxcb,libxshmfence,llvm,ncurses,nettle,zlib
metamail.dep:ncurses
minicom.dep:ncurses
mkcomposecache.dep:libX11,libXau,libXdmcp,libxcb
mkfontscale.dep:bzip2,freetype,glib2,harfbuzz,libfontenc,libpng,zlib
moc.dep:alsa-lib,curl,cyrus-sasl,db48,file,flac,libid3tag,libidn,libmad,libogg,libsamplerate,libsndfile,libssh2,libtool,libvorbis,ncurses,openldap-client,openssl|openssl-solibs,wavpack,zlib
most.dep:slang
motif.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXft,libXmu,libXp,libXrender,libXt,libjpeg-turbo,libpng,libxcb,util-linux,zlib
mozilla-firefox.dep:alsa-lib,atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,mozilla-nss,pango,pixman,startup-notification,util-linux,xcb-util,zlib
mozilla-nss.dep:gcc,gcc-g++,icu4c,sqlite,zlib
mozilla-thunderbird.dep:alsa-lib,atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,mozilla-nss,pango,pixman,startup-notification,util-linux,xcb-util,zlib
mpfr.dep:gmp
mpg123.dep:alsa-lib,attr,dbus,flac,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXrandr,libXrender,libXtst,libasyncns,libcap,libogg,libsndfile,libtool,libvorbis,libxcb,pulseaudio,sdl,svgalib,util-linux
mplayerthumbs.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
mtr.dep:glib2,libtermcap,ncurses
mutt.dep:cyrus-sasl,gdbm,gpgme,libassuan,libgpg-error,libidn,ncurses,openssl|openssl-solibs,zlib
nano.dep:file,ncurses,zlib
ncftp.dep:ncurses
ncurses.dep:gcc,gcc-g++
neon.dep:expat,gcc,gcc-g++,libproxy,openssl|openssl-solibs,zlib
nepomuk-core.dep:acl,attica,attr,baloo,bzip2,curl,cyrus-sasl,ebook-tools,eudev,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdegraphics-mobipocket,kdelibs,lcms2,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libpng,libssh,libssh2,libtiff,libxcb,libxml2,libzip,openjpeg,openldap-client,openssl|openssl-solibs,poppler,qca,qjson,qt,soprano,strigi,taglib,util-linux,xapian-core,xz,zlib
nepomuk-widgets.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,nepomuk-core,qca,qt,soprano,strigi,util-linux,xz,zlib
net-snmp.dep:libnl3,lm_sensors,openssl|openssl-solibs,perl,python
netatalk.dep:acl,attr,cups,cyrus-sasl,db48,gmp,gnutls,libffi,libgcrypt,libgpg-error,libidn,nettle,openldap-client,openssl|openssl-solibs,p11-kit,zlib
netkit-ftp.dep:ncurses,readline
netkit-ntalk.dep:ncurses
netpbm.dep:libX11,libXau,libXdmcp,libjpeg-turbo,libpng,libtiff,libxcb,libxml2,xz,zlib
nettle.dep:gmp
netwatch.dep:ncurses
network-manager-applet.dep:GConf,ModemManager,NetworkManager,at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,dbus-glib,eudev,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+3,harfbuzz,icu4c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libgcrypt,libgnome-keyring,libgpg-error,libgudev,libnotify,libpng,libsecret,libxcb,libxshmfence,mesa,mozilla-nss,pango,pixman,sqlite,util-linux,zlib
newt.dep:popt,python,slang,zlib
nfacct.dep:libmnl,libnetfilter_acct
nfs-utils.dep:attr,libcap,libtirpc,util-linux
nftables.dep:gmp,libmnl,libnftnl,ncurses,readline
nmap.dep:gcc,gcc-g++,libnl,openssl|openssl-solibs,pcre
nn.dep:ncurses
normalize.dep:glib,gtk+,libX11,libXau,libXdmcp,libXext,libmad,libxcb,xmms
notify-python.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libnotify,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
ntfs-3g.dep:util-linux
ntp.dep:attr,libcap,libevent,libnl3,lm_sensors,net-snmp,openssl|openssl-solibs,perl
obexftp.dep:bluez,eudev,fuse,libusb,openobex
oclock.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXt,libxcb,libxkbfile,util-linux
okteta.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
okular.dep:acl,attica,attr,bzip2,chmlib,cups,curl,cyrus-sasl,dbus,djvulibre,ebook-tools,eudev,exiv2,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,ghostscript,giflib,glib2,gmp,gnutls,harfbuzz,json-c,kactivities,kdegraphics-mobipocket,kdelibs,lcms2,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libgcrypt,libgpg-error,libidn,libjpeg-turbo,libkexiv2,libkscreen,libogg,libpng,libsndfile,libspectre,libssh,libssh2,libtiff,libvorbis,libxcb,libxml2,libzip,nettle,openjpeg,openldap-client,openssl|openssl-solibs,p11-kit,pcre,phonon,poppler,pulseaudio,qca,qimageblitz,qjson,qt,soprano,strigi,utempter,util-linux,xz,zlib
openexr.dep:gcc,gcc-g++,ilmbase,zlib
openjpeg.dep:lcms2,libjpeg-turbo,libpng,libtiff,xz,zlib
openldap-client.dep:cyrus-sasl,openssl|openssl-solibs
openobex.dep:eudev,libusb
openssh.dep:openssl|openssl-solibs,zlib
openvpn.dep:lzo,openssl|openssl-solibs,iproute2
oprofile.dep:binutils,gcc,gcc-g++,popt
orage.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libical,libnotify,libpng,libxcb,libxfce4util,libxshmfence,mesa,pango,pixman,popt,xfce4-panel,zlib
oxygen-gtk2.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,zlib
p11-kit.dep:libffi,libtasn1
pairs.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,mesa,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
palapeli.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
pamixer.dep:attr,boost,dbus,flac,gcc,gcc-g++,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXtst,libasyncns,libcap,libogg,libsndfile,libvorbis,libxcb,pulseaudio,util-linux
pan.dep:atk,bzip2,cairo,enchant,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gmime,gmp,gnutls,gtk+2,gtkspell,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libidn,libpng,libxcb,libxshmfence,mesa,nettle,p11-kit,pango,pixman,zlib
pango.dep:bzip2,cairo,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pixman,zlib
pangomm.dep:bzip2,cairo,cairomm,expat,fontconfig,freetype,gcc,gcc-g++,glib2,glibmm,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libpng,libsigc++,libxcb,libxshmfence,mesa,pango,pixman,zlib
parley.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libkdeedu,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,pcre,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
parted.dep:eudev,lvm2,ncurses,readline,util-linux
partitionmanager.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libatasmart,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,lvm2,parted,qca,qt,soprano,strigi,util-linux,xz,zlib
patch.dep:attr
pavucontrol.dep:at-spi2-atk,at-spi2-core,atk,atkmm,attr,bzip2,cairo,cairomm,dbus,expat,flac,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glibmm,gtk+3,gtkmm3,harfbuzz,json-c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXxf86vm,libasyncns,libcanberra,libcap,libdrm,libepoxy,libffi,libogg,libpng,libsigc++,libsndfile,libtool,libvorbis,libxcb,libxshmfence,mesa,pango,pangomm,pixman,pulseaudio,samba,util-linux,zlib
pciutils.dep:kmod,xz,zlib
pcmciautils.dep:sysfsutils
pcre.dep:bzip2,gcc,gcc-g++,zlib
perl.dep:db48,expat,gcc,gcc-g++,gdbm,openssl|openssl-solibs,zlib
perlkde.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kate,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libical,libjpeg-turbo,libkscreen,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,okular,orc,pcre,perl,perlqt,phonon,pulseaudio,qca,qjson,qt,smokegen,smokekde,smokeqt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
perlqt.dep:QScintilla,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,perl,phonon,pulseaudio,qimageblitz,qt,smokegen,smokeqt,sqlite,util-linux,xz,zlib
phonon-gstreamer.dep:attr,bzip2,dbus,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,json-c,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,libxshmfence,mesa,orc,phonon,pulseaudio,qt,util-linux,zlib
phonon.dep:attr,bzip2,dbus,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXrender,libXtst,libasyncns,libcap,libffi,libogg,libpng,libsndfile,libvorbis,libxcb,pulseaudio,qt,util-linux,zlib
php.dep:aspell,bzip2,curl,cyrus-sasl,db48,enchant,freetype,gcc,gcc-g++,gdbm,glib2,gmp,harfbuzz,icu4c,libX11,libXau,libXdmcp,libXpm,libgcrypt,libgpg-error,libidn,libiodbc,libjpeg-turbo,libmcrypt,libnl3,libpng,libssh2,libtool,libxcb,libxml2,libxslt,net-snmp,openldap-client,openssl|openssl-solibs,pcre,sqlite,t1lib,xz,zlib
picmi.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libasyncns,libcap,libdbusmenu-qt,libffi,libkdegames,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
pidentd.dep:openssl|openssl-solibs
pidgin.dep:atk,bzip2,cairo,cyrus-sasl,dbus,dbus-glib,enchant,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gst-plugins-base,gstreamer,gtk+2,gtkspell,harfbuzz,icu4c,libICE,libSM,libX11,libXScrnSaver,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libidn,libpng,libxcb,libxml2,libxshmfence,mesa,mozilla-nss,ncurses,orc,pango,perl,pixman,python,sqlite,util-linux,xz,zlib
pilot-link.dep:bluez,eudev,libpng,libtermcap,libusb,libusb-compat,popt,python,readline,zlib
pinentry.dep:at-spi2-atk,at-spi2-core,atk,attr,bzip2,cairo,dbus,expat,fontconfig,freetype,gcc,gcc-g++,gcr,gdk-pixbuf2,glib2,gtk+2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libassuan,libcap,libdrm,libepoxy,libffi,libgcrypt,libgpg-error,libpng,libsecret,libxcb,libxshmfence,mesa,ncurses,p11-kit,pango,pixman,qt,util-linux,zlib
pkg-config.dep:glib2
plasma-nm.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libmm-qt,libnm-qt,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
polkit-gnome.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pango,pixman,polkit,zlib
polkit-kde-agent-1.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,polkit,polkit-qt-1,qca,qt,util-linux,xz,zlib
polkit-kde-kcmodules-1.dep:attica,bzip2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,polkit,polkit-qt-1,qca,qt,util-linux,xz,zlib
polkit-qt-1.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,polkit,qt,util-linux,zlib
polkit.dep:expat,glib2,libffi,zlib
popa3d.dep:openssl|openssl-solibs
poppler.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+3,harfbuzz,lcms2,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libjpeg-turbo,libpng,libtiff,libxcb,libxshmfence,mesa,openjpeg,pango,pixman,util-linux,xz,zlib
powertop.dep:gcc,gcc-g++,libnl3,ncurses,zlib
poxml.dep:gcc,gcc-g++,gettext-tools,glib2,libunistring,qt,zlib
ppp.dep:dbus,eudev,libnl3,libpcap,libusb
print-manager.dep:acl,attica,attr,bzip2,cups,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gmp,gnutls,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libidn,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,nettle,orc,p11-kit,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
procps-ng.dep:gcc,gcc-g++,ncurses
proftpd.dep:attr,libcap,ncurses,openssl|openssl-solibs
pulseaudio.dep:GConf,alsa-lib,attr,dbus,dbus-glib,eudev,fftw,flac,glib2,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXtst,libasyncns,libcap,libffi,libogg,libsndfile,libtool,libvorbis,libxcb,openssl|openssl-solibs,orc,samba,sbc,speexdsp,util-linux,zlib
pycairo.dep:bzip2,cairo,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libpng,libxcb,libxshmfence,mesa,pixman,zlib
pycups.dep:cups,gmp,gnutls,libffi,libidn,nettle,p11-kit,python,zlib
pycurl.dep:curl,cyrus-sasl,libidn,libssh2,openldap-client,openssl|openssl-solibs,python,zlib
pygobject.dep:glib2,libffi,zlib
pygobject3.dep:bzip2,cairo,expat,fontconfig,freetype,glib2,gobject-introspection,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,pixman,zlib
pygtk.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libglade,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,xz,zlib
pykde4.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,pcre,phonon,pulseaudio,python,qca,qjson,qt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
python-pillow.dep:bzip2,eudev,expat,fontconfig,freetype,glib2,harfbuzz,lcms2,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXft,libXrender,libexif,libgphoto2,libieee1284,libjpeg-turbo,libpng,libtiff,libtool,libusb,libxcb,openjpeg,python,v4l-utils,xz,zlib
python.dep:bzip2,db48,expat,gcc,gcc-g++,gdbm,glib2,icu4c,ncurses,openssl|openssl-solibs,readline,sqlite,zlib
qca-cyrus-sasl.dep:cyrus-sasl,gcc,gcc-g++,glib2,qca,qt,zlib
qca-gnupg.dep:gcc,gcc-g++,glib2,qca,qt,zlib
qca-ossl.dep:gcc,gcc-g++,glib2,openssl|openssl-solibs,qca,qt,zlib
qca.dep:gcc,gcc-g++,glib2,qt,zlib
qimageblitz.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libpng,libxcb,qt,util-linux,zlib
qjson.dep:gcc,gcc-g++,glib2,qt,zlib
qpdf.dep:gcc,gcc-g++,pcre,zlib
qt-gstreamer.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,orc,qt,util-linux,zlib
qt.dep:bzip2,eudev,expat,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,lcms2,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libiodbc,libjpeg-turbo,libmng,libpng,libtiff,libxcb,libxml2,libxshmfence,libxslt,mariadb,mesa,openssl|openssl-solibs,orc,sqlite,util-linux,xz,zlib
qtruby.dep:QScintilla,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,gmp,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qt,ruby,smokegen,smokeqt,sqlite,util-linux,xz,zlib
qtscriptgenerator.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,qt,util-linux,zlib
quota.dep:cyrus-sasl,dbus,e2fsprogs,libnl3,openldap-client,openssl|openssl-solibs
radeontool.dep:libpciaccess
raptor2.dep:curl,cyrus-sasl,gcc,gcc-g++,icu4c,libidn,libssh2,libxml2,libxslt,openldap-client,openssl|openssl-solibs,xz,zlib
rasqal.dep:curl,cyrus-sasl,gcc,gcc-g++,gmp,icu4c,libidn,libssh2,libxml2,libxslt,mhash,mpfr,openldap-client,openssl|openssl-solibs,raptor2,util-linux,xz,zlib
rdesktop.dep:alsa-lib,libX11,libXau,libXdmcp,libXext,libXrandr,libXrender,libsamplerate,libxcb,openssl|openssl-solibs
redland.dep:curl,cyrus-sasl,db44,gcc,gcc-g++,gmp,icu4c,libidn,libiodbc,libssh2,libtool,libxml2,libxslt,mariadb,mhash,mpfr,openldap-client,openssl|openssl-solibs,raptor2,rasqal,sqlite,util-linux,xz,zlib
reiserfsprogs.dep:util-linux
rendercheck.dep:libX11,libXau,libXdmcp,libXrender,libxcb
rocs.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,grantlee,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
rpcbind.dep:libtirpc
rpm.dep:acl,attr,bzip2,db48,dbus,elfutils,file,libarchive,libxml2,lzo,mozilla-nss,nettle,popt,python,xz,zlib
rpm2tgz.dep:rpm
rsync.dep:acl,attr,popt
ruby.dep:bzip2,db48,expat,fontconfig,freetype,gdbm,glib2,gmp,harfbuzz,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXft,libXrender,libffi,libpng,libxcb,libyaml,ncurses,openssl|openssl-solibs,readline,tcl,tk,zlib
rust.dep:gcc,gcc-g++
rxvt.dep:libX11,libXau,libXdmcp,libXpm,libxcb,utempter
rzip.dep:bzip2
samba.dep:acl,attr,bzip2,cups,cyrus-sasl,dbus,dmapi,e2fsprogs,gamin,gmp,gnutls,libaio,libarchive,libcap,libffi,libidn,libxml2,lzo,ncurses,nettle,openldap-client,openssl|openssl-solibs,p11-kit,popt,python,xz,zlib
sane.dep:atk,bzip2,cairo,eudev,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libexif,libffi,libgphoto2,libieee1284,libjpeg-turbo,libnl3,libpng,libtiff,libtool,libusb,libxcb,libxshmfence,mesa,net-snmp,openssl|openssl-solibs,pango,pixman,v4l-utils,xz,zlib
sc.dep:ncurses
scim-anthy.dep:anthy,atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,scim,zlib
scim-hangul.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libhangul,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,scim,zlib
scim-input-pad.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,scim,zlib
scim-m17n.dep:gcc,gcc-g++,libtool,libxml2,m17n-lib,scim,xz,zlib
scim-pinyin.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,scim,zlib
scim-tables.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,scim,zlib
scim.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libepoxy,libffi,libpng,libtool,libxcb,libxshmfence,mesa,pango,pixman,qt,util-linux,zlib
screen.dep:ncurses,utempter
sdl.dep:bzip2,freetype,glib2,harfbuzz,libX11,libXau,libXdmcp,libXext,libXrandr,libXrender,libjpeg-turbo,libpng,libtiff,libxcb,svgalib,xz,zlib
sdparm.dep:sg3_utils
seamonkey-solibs.dep:gcc,gcc-g++,mozilla-nss,zlib
seamonkey.dep:alsa-lib,atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,mozilla-nss,pango,pixman,startup-notification,util-linux,xcb-util,zlib
sed.dep:acl,attr
seejpeg.dep:svgalib
sendmail.dep:cyrus-sasl,db48,openssl|openssl-solibs
serf.dep:apr,apr-util,cyrus-sasl,db44,expat,gcc,gcc-g++,icu4c,openldap-client,openssl|openssl-solibs,sqlite,util-linux,zlib
setxkbmap.dep:libX11,libXau,libXdmcp,libxcb,libxkbfile
seyon.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXp,libXpm,libXt,libxcb,util-linux
shadow.dep:acl,attr
shared-mime-info.dep:glib2,libxml2,xz,zlib
showfont.dep:libFS
sip.dep:gcc,gcc-g++
skanlite.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libexif,libffi,libgphoto2,libieee1284,libjpeg-turbo,libksane,libpng,libtiff,libtool,libusb,libxcb,libxml2,qca,qt,sane,soprano,strigi,util-linux,v4l-utils,xz,zlib
slrn.dep:openssl|openssl-solibs,slang
smartmontools.dep:gcc,gcc-g++,libcap-ng
smokegen.dep:gcc,gcc-g++,glib2,qt,zlib
smokekde.dep:acl,akonadi,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kactivities,kate,kdelibs,kdepimlibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libical,libjpeg-turbo,libkscreen,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,okular,orc,pcre,phonon,pulseaudio,qca,qjson,qt,smokegen,smokeqt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
smokeqt.dep:QScintilla,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qimageblitz,qt,smokegen,sqlite,util-linux,xz,zlib
smproxy.dep:libICE,libSM,libX11,libXau,libXdmcp,libXmu,libXt,libxcb,util-linux
snownews.dep:libxml2,ncurses,openssl|openssl-solibs,xz,zlib
soprano.dep:clucene,curl,cyrus-sasl,db44,gcc,gcc-g++,glib2,gmp,icu4c,libidn,libiodbc,libssh2,libtool,libxml2,libxslt,mhash,mpfr,openldap-client,openssl|openssl-solibs,qt,raptor2,rasqal,redland,util-linux,xz,zlib
sox.dep:alsa-lib,attr,dbus,file,flac,gcc,json-c,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXi,libXtst,libao,libasyncns,libcap,libid3tag,libmad,libogg,libpng,libsndfile,libtool,libvorbis,libxcb,pulseaudio,util-linux,wavpack,zlib
sqlite.dep:gcc,gcc-g++,icu4c,ncurses,readline
squashfs-tools.dep:lzo,xz,zlib
startup-notification.dep:libX11,libXau,libXdmcp,libxcb,xcb-util
step.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,giflib,glib2,gsl,harfbuzz,json-c,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,mesa,pcre,phonon,pulseaudio,qca,qt,soprano,strigi,util-linux,xz,zlib
strigi.dep:bzip2,clucene,curl,cyrus-sasl,dbus,exiv2,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libgcrypt,libgpg-error,libidn,libpng,libssh,libssh2,libxcb,libxml2,openldap-client,openssl|openssl-solibs,qt,util-linux,xz,zlib
stunnel.dep:openssl|openssl-solibs,zlib
subversion.dep:apr,apr-util,cyrus-sasl,db44,expat,file,gcc,gcc-g++,gmp,icu4c,openldap-client,openssl|openssl-solibs,ruby,serf,sqlite,subversion,util-linux,zlib
sudo.dep:zlib
superkaramba.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,python,qca,qimageblitz,qt,soprano,sqlite,strigi,utempter,util-linux,xz,zlib
svgpart.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
sweeper.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
swig.dep:gcc,gcc-g++,pcre,zlib
syslinux.dep:util-linux
t1lib.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
taglib-extras.dep:gcc,gcc-g++,taglib,zlib
taglib.dep:gcc,gcc-g++,zlib
tar.dep:acl,attr
tcl.dep:zlib
tcpdump.dep:dbus,eudev,libnl3,libpcap,libusb,openssl|openssl-solibs
tcsh.dep:libtermcap
telnet.dep:ncurses
texinfo.dep:ncurses
tftp-hpa.dep:libtermcap,readline
thunar-volman.dep:atk,bzip2,cairo,dbus,dbus-glib,eudev,exo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libgudev,libnotify,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
tigervnc.dep:bzip2,expat,fltk,fontconfig,freetype,gcc,gcc-g++,glib2,gmp,gnutls,harfbuzz,libICE,libSM,libX11,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXfont,libXft,libXi,libXinerama,libXrender,libXtst,libXxf86vm,libdrm,libffi,libfontenc,libidn,libjpeg-turbo,libpng,libxcb,libxshmfence,mesa,nettle,p11-kit,pixman,util-linux,zlib
tin.dep:gcc,gcc-g++,icu4c,ncurses
tix.dep:libX11,libXau,libXdmcp,libxcb
tk.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXScrnSaver,libXau,libXdmcp,libXext,libXft,libXrender,libpng,libxcb,tcl,zlib
tmux.dep:libevent,ncurses,utempter
transfig.dep:libX11,libXau,libXdmcp,libXpm,libpng,libxcb,zlib
transset.dep:libX11,libXau,libXdmcp,libxcb
trn.dep:ncurses
tumbler.dep:bzip2,cairo,curl,cyrus-sasl,dbus,dbus-glib,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gst-plugins-base,gstreamer,harfbuzz,lcms2,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libgsf,libidn,libjpeg-turbo,libpng,libssh2,libtiff,libxcb,libxml2,libxshmfence,mesa,openjpeg,openldap-client,openssl|openssl-solibs,pixman,poppler,xz,zlib
twm.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXt,libxcb,util-linux
udisks.dep:dbus,dbus-glib,eudev,glib2,libatasmart,libffi,libgudev,lvm2,parted,polkit,sg3_utils,util-linux,zlib
udisks2.dep:expat,glib2,libffi,polkit,zlib
ulogd.dep:dbus,eudev,gcc,gcc-g++,icu4c,libmnl,libnetfilter_acct,libnetfilter_conntrack,libnetfilter_log,libnfnetlink,libnl3,libpcap,libusb,mariadb,openssl|openssl-solibs,sqlite,zlib
umbrello.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,libxslt,qca,qt,soprano,strigi,util-linux,xz,zlib
upower.dep:dbus,dbus-glib,eudev,glib2,libffi,libgudev,libimobiledevice,libplist,libusb,libusbmuxd,libxml2,openssl|openssl-solibs,polkit,xz,zlib
urwid.dep:python
usb_modeswitch.dep:eudev,libusb
usbmuxd.dep:eudev,libimobiledevice,libplist,libusb,libusbmuxd,libxml2,openssl|openssl-solibs,xz,zlib
usbutils.dep:eudev,libusb
util-linux.dep:eudev,libtermcap,ncurses,zlib
v4l-utils.dep:alsa-lib,bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXxf86vm,libdrm,libffi,libjpeg-turbo,libpng,libxcb,libxshmfence,mesa,qt,util-linux,zlib
vbetool.dep:libpciaccess,libx86,zlib
viewres.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
vim-gvim.dep:acl,atk,attr,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gpm,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,ncurses,pango,perl,pixman,python,util-linux,zlib
vim.dep:acl,attr,gpm,ncurses,perl,python
virtuoso-ose.dep:bzip2,cairo,cyrus-sasl,djvulibre,expat,fftw,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,harfbuzz,ilmbase,imagemagick,lcms2,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libXt,libXxf86vm,libcroco,libdrm,libffi,libjpeg-turbo,libpng,librsvg,libtiff,libwmf,libxcb,libxml2,libxshmfence,mesa,openexr,openjpeg,openldap-client,openssl|openssl-solibs,pango,pixman,util-linux,xz,zlib
vorbis-tools.dep:curl,cyrus-sasl,flac,libao,libidn,libogg,libssh2,libvorbis,openldap-client,openssl|openssl-solibs,zlib
vsftpd.dep:attr,libcap,openssl|openssl-solibs
vte.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxshmfence,mesa,ncurses,pango,pixman,zlib
wget.dep:libidn,openssl|openssl-solibs,pcre,util-linux,zlib
whois.dep:libidn
wicd-kde.dep:acl,attica,attr,bzip2,dbus,eudev,expat,flac,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,gst-plugins-base,gstreamer,harfbuzz,icu4c,json-c,kdelibs,libICE,libSM,libX11,libXScrnSaver,libXau,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdbusmenu-qt,libdrm,libffi,libjpeg-turbo,libogg,libpng,libsndfile,libvorbis,libxcb,libxml2,libxshmfence,libxslt,mesa,orc,phonon,pulseaudio,qca,qt,soprano,sqlite,strigi,util-linux,xz,zlib
wicd.dep:dbus-python,pygobject,pygtk,python,urwid,wireless-tools,wpa_supplicant,iw
windowmaker.dep:bzip2,expat,fontconfig,freetype,giflib,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXft,libXinerama,libXmu,libXpm,libXrandr,libXrender,libXt,libexif,libjpeg-turbo,libpng,libtiff,libxcb,util-linux,xz,zlib
wpa_supplicant.dep:bzip2,dbus,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXrender,libffi,libnl3,libpng,libxcb,ncurses,openssl|openssl-solibs,qt,readline,util-linux,zlib
x11-ssh-askpass.dep:libICE,libSM,libX11,libXau,libXdmcp,libXt,libxcb,util-linux
x11perf.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdmcp,libXext,libXft,libXmu,libXrender,libpng,libxcb,zlib
x3270.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,openssl|openssl-solibs,util-linux
xaos.dep:libX11,libXau,libXdmcp,libXext,libpng,libxcb,zlib
xapian-core.dep:gcc,gcc-g++,util-linux,zlib
xauth.dep:libX11,libXau,libXdmcp,libXext,libXmu,libxcb
xbacklight.dep:libXau,libXdmcp,libxcb,xcb-util
xbiff.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xcalc.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xcb-util-cursor.dep:libXau,libXdmcp,libxcb,xcb-util,xcb-util-image,xcb-util-renderutil
xcb-util-errors.dep:libXau,libXdmcp,libxcb
xcb-util-image.dep:libXau,libXdmcp,libxcb,xcb-util
xcb-util-keysyms.dep:libXau,libXdmcp,libxcb
xcb-util-renderutil.dep:libXau,libXdmcp,libxcb
xcb-util-wm.dep:libXau,libXdmcp,libxcb
xcb-util.dep:libXau,libXdmcp,libxcb
xclipboard.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,libxkbfile,util-linux
xclock.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXft,libXmu,libXpm,libXrender,libXt,libpng,libxcb,libxkbfile,util-linux,zlib
xcm.dep:libICE,libSM,libX11,libXau,libXcm,libXdmcp,libXext,libXfixes,libXmu,libXt,libxcb,util-linux
xcmsdb.dep:libX11,libXau,libXdmcp,libxcb
xcompmgr.dep:libX11,libXau,libXcomposite,libXdamage,libXdmcp,libXext,libXfixes,libXrender,libxcb
xconsole.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xcursorgen.dep:libX11,libXau,libXcursor,libXdmcp,libXfixes,libXrender,libpng,libxcb,zlib
xdbedizzy.dep:libX11,libXau,libXdmcp,libXext,libxcb
xditview.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xdm.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXt,libxcb,util-linux
xdpyinfo.dep:libX11,libXau,libXcomposite,libXdmcp,libXext,libXi,libXinerama,libXrender,libXtst,libXxf86dga,libXxf86misc,libXxf86vm,libdmx,libxcb
xdriinfo.dep:expat,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXxf86vm,libdrm,libxcb,libxshmfence,mesa
xedit.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xev.dep:libX11,libXau,libXdmcp,libXext,libXrandr,libXrender,libxcb
xeyes.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXrender,libXt,libxcb,util-linux
xf86-input-acecad.dep:sysfsutils
xf86-input-evdev.dep:eudev,libevdev,mtdev
xf86-input-synaptics.dep:libX11,libXau,libXdmcp,libXext,libXi,libXtst,libevdev,libxcb
xf86-input-vmmouse.dep:eudev
xf86-input-wacom.dep:libX11,libXau,libXdmcp,libXext,libXi,libXinerama,libXrandr,libXrender,libxcb
xf86-video-amdgpu.dep:eudev,expat,libdrm,mesa
xf86-video-ati.dep:eudev,libdrm,libpciaccess
xf86-video-intel.dep:eudev,libX11,libXScrnSaver,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXv,libXvMC,libXxf86vm,libdrm,libpciaccess,libxcb,libxshmfence,pixman,xcb-util
xf86-video-nouveau.dep:eudev,libdrm
xf86-video-openchrome.dep:eudev,libX11,libXau,libXdmcp,libXext,libXv,libXvMC,libdrm,libxcb
xf86-video-vmware.dep:expat,gcc,gcc-g++,libdrm,libffi,llvm,mesa,ncurses,nettle,zlib
xf86dga.dep:libX11,libXau,libXdmcp,libXext,libXxf86dga,libxcb
xfce4-appfinder.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,garcon,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
xfce4-clipman-plugin.dep:atk,bzip2,cairo,dbus,dbus-glib,exo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfce4-panel,xfconf,zlib
xfce4-dev-tools.dep:glib2
xfce4-notifyd.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libnotify,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
xfce4-panel.dep:at-spi2-atk,at-spi2-core,atk,bzip2,cairo,dbus,dbus-glib,exo,expat,fontconfig,freetype,garcon,gdk-pixbuf2,glib2,gtk+2,gtk+3,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libepoxy,libffi,libpng,libwnck,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
xfce4-power-manager.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libnotify,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,upower,util-linux,xcb-util,xfce4-panel,xfconf,zlib
xfce4-pulseaudio-plugin.dep:at-spi2-atk,at-spi2-core,atk,attr,bzip2,cairo,dbus,dbus-glib,expat,flac,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+3,harfbuzz,json-c,keybinder,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXtst,libXxf86vm,libasyncns,libcap,libdrm,libepoxy,libffi,libnotify,libogg,libpng,libsndfile,libvorbis,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,pulseaudio,startup-notification,util-linux,xcb-util,xfce4-panel,xfconf,zlib
xfce4-screenshooter.dep:atk,bzip2,cairo,exo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,icu4c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libsoup,libxcb,libxfce4ui,libxfce4util,libxml2,libxshmfence,mesa,pango,pixman,sqlite,startup-notification,util-linux,xcb-util,xfce4-panel,xz,zlib
xfce4-session.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libffi,libpng,libwnck,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,polkit,startup-notification,util-linux,xcb-util,xfconf,zlib
xfce4-settings.dep:atk,bzip2,cairo,dbus,dbus-glib,exo,expat,fontconfig,freetype,garcon,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libnotify,libpng,libxcb,libxfce4ui,libxfce4util,libxkbfile,libxklavier,libxml2,libxshmfence,mesa,pango,pixman,startup-notification,upower,util-linux,xcb-util,xfconf,xz,zlib
xfce4-systemload-plugin.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,upower,util-linux,xcb-util,xfce4-panel,zlib
xfce4-taskmanager.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libffi,libpng,libwnck,libxcb,libxshmfence,mesa,pango,pixman,startup-notification,xcb-util,zlib
xfce4-terminal.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,ncurses,pango,pixman,startup-notification,util-linux,vte,xcb-util,zlib
xfce4-weather-plugin.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,gtk+2,harfbuzz,icu4c,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libffi,libpng,libsoup,libxcb,libxfce4ui,libxfce4util,libxml2,libxshmfence,mesa,pango,pixman,sqlite,startup-notification,upower,util-linux,xcb-util,xfce4-panel,xz,zlib
xfconf.dep:dbus,dbus-glib,glib2,libffi,libxfce4util,zlib
xfd.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXft,libXmu,libXpm,libXrender,libXt,libpng,libxcb,util-linux,zlib
xfdesktop.dep:Thunar,atk,bzip2,cairo,dbus,dbus-glib,exo,expat,fontconfig,freetype,garcon,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libffi,libnotify,libpng,libwnck,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
xfig.dep:libICE,libSM,libX11,libXau,libXaw3d,libXdmcp,libXext,libXmu,libXpm,libXt,libjpeg-turbo,libpng,libxcb,util-linux,zlib
xfontsel.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xfractint.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libX11,libXau,libXdmcp,libXft,libXrender,libpng,libxcb,zlib
xfs.dep:bzip2,freetype,glib2,harfbuzz,libXfont,libfontenc,libpng,zlib
xfsdump.dep:attr,ncurses,util-linux,xfsprogs
xfsinfo.dep:libFS
xfsprogs.dep:util-linux
xfwm4.dep:atk,bzip2,cairo,dbus,dbus-glib,expat,fontconfig,freetype,gdk-pixbuf2,glib2,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXres,libXxf86vm,libdrm,libffi,libpng,libwnck,libxcb,libxfce4ui,libxfce4util,libxshmfence,mesa,pango,pixman,startup-notification,util-linux,xcb-util,xfconf,zlib
xgames.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xgamma.dep:libX11,libXau,libXdmcp,libXext,libXxf86vm,libxcb
xgc.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xhost.dep:libX11,libXau,libXdmcp,libXmu,libxcb
xine-lib.dep:a52dec,aalib,alsa-lib,attr,audiofile,bzip2,cairo,cyrus-sasl,dbus,djvulibre,e2fsprogs,esound,expat,fftw,flac,fontconfig,freeglut,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glu,gmp,gnutls,gpm,harfbuzz,ilmbase,imagemagick,json-c,lcms2,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXt,libXtst,libXv,libXvMC,libXxf86vm,libasyncns,libcaca,libcap,libcroco,libdrm,libdvdnav,libdvdread,libffi,libidn,libjpeg-turbo,libmad,libmng,libogg,libpng,librsvg,libsndfile,libtheora,libtiff,libva,libvdpau,libvorbis,libvpx,libwmf,libxcb,libxml2,libxshmfence,mesa,ncurses,nettle,openexr,openjpeg,openldap-client,openssl|openssl-solibs,p11-kit,pango,pixman,pulseaudio,samba,sdl,slang,slang1,svgalib,util-linux,v4l-utils,wavpack,xz,zlib
xine-ui.dep:aalib,bzip2,curl,cyrus-sasl,expat,fontconfig,freeglut,freetype,gcc,gcc-g++,glib2,glu,gpm,harfbuzz,libX11,libXScrnSaver,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXinerama,libXrandr,libXrender,libXtst,libXv,libXxf86vm,libcaca,libdrm,libidn,libjpeg-turbo,libpng,libssh2,libxcb,libxshmfence,mesa,ncurses,openldap-client,openssl|openssl-solibs,readline,slang,slang1,xine-lib,zlib
xinit.dep:libX11,libXau,libXdmcp,libxcb
xinput.dep:libX11,libXau,libXdmcp,libXext,libXi,libXinerama,libXrandr,libXrender,libxcb
xkbcomp.dep:libX11,libXau,libXdmcp,libxcb,libxkbfile
xkbevd.dep:libX11,libXau,libXdmcp,libxcb,libxkbfile
xkbprint.dep:libX11,libXau,libXdmcp,libxcb,libxkbfile
xkbutils.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xkill.dep:libX11,libXau,libXdmcp,libXmu,libxcb
xload.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xlockmore.dep:bzip2,cairo,djvulibre,expat,fftw,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glu,harfbuzz,ilmbase,imagemagick,lcms2,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXinerama,libXmu,libXpm,libXrender,libXt,libXxf86vm,libcroco,libdrm,libffi,libjpeg-turbo,libpng,librsvg,libtiff,libwmf,libxcb,libxml2,libxshmfence,mesa,openexr,openjpeg,pango,pixman,util-linux,xz,zlib
xlogo.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXft,libXmu,libXpm,libXrender,libXt,libpng,libxcb,util-linux,zlib
xlsatoms.dep:libXau,libXdmcp,libxcb
xlsclients.dep:libXau,libXdmcp,libxcb
xlsfonts.dep:libX11,libXau,libXdmcp,libxcb
xmag.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xman.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xmessage.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xmh.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xmms.dep:alsa-lib,audiofile,esound,expat,flac,gcc,gcc-g++,glib,gtk+,libICE,libSM,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXxf86vm,libdrm,libogg,libvorbis,libxcb,libxshmfence,mesa,util-linux,zlib
xmodmap.dep:libX11,libXau,libXdmcp,libxcb
xmore.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xorg-server-xephyr.dep:bzip2,expat,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXfont,libXxf86vm,libdrm,libepoxy,libfontenc,libpng,libxcb,libxshmfence,mesa,nettle,pixman,xcb-util,xcb-util-image,xcb-util-keysyms,xcb-util-renderutil,xcb-util-wm,zlib
xorg-server-xnest.dep:bzip2,expat,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXfont,libXxf86vm,libdrm,libfontenc,libpng,libxcb,libxshmfence,mesa,nettle,pixman,zlib
xorg-server-xvfb.dep:bzip2,expat,freetype,glib2,harfbuzz,libX11,libXau,libXdamage,libXdmcp,libXext,libXfixes,libXfont,libXxf86vm,libdrm,libfontenc,libpng,libxcb,libxshmfence,mesa,nettle,pixman,zlib
xorg-server.dep:bzip2,eudev,expat,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdamage,libXdmcp,libXext,libXfixes,libXfont,libXi,libXmu,libXpm,libXrender,libXt,libXxf86vm,libdmx,libdrm,libepoxy,libfontenc,libpciaccess,libpng,libxcb,libxshmfence,mesa,nettle,pixman,util-linux,zlib
xpaint.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw3dXft,libXdmcp,libXext,libXft,libXmu,libXpm,libXrender,libXt,libjpeg-turbo,libpng,libtiff,libxcb,util-linux,xz,zlib
xpdf.dep:bzip2,expat,fontconfig,freetype,gcc,gcc-g++,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXdmcp,libXext,libXft,libXmu,libXp,libXpm,libXrender,libXt,libjpeg-turbo,libpng,libxcb,motif,util-linux,zlib
xpr.dep:libX11,libXau,libXdmcp,libXmu,libxcb
xprop.dep:libX11,libXau,libXdmcp,libxcb
xpyb.dep:libXau,libXdmcp,libxcb
xrandr.dep:libX11,libXau,libXdmcp,libXext,libXrandr,libXrender,libxcb
xrdb.dep:libX11,libXau,libXdmcp,libXmu,libxcb
xrefresh.dep:libX11,libXau,libXdmcp,libxcb
xsane.dep:atk,bzip2,cairo,eudev,expat,fontconfig,freetype,gdk-pixbuf2,gimp,glib2,gtk+2,harfbuzz,lcms2,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXi,libXinerama,libXrandr,libXrender,libXxf86vm,libdrm,libexif,libffi,libgphoto2,libieee1284,libjpeg-turbo,libpng,libtiff,libtool,libusb,libxcb,libxshmfence,mesa,pango,pixman,sane,v4l-utils,xz,zlib
xscreensaver.dep:atk,bzip2,cairo,expat,fontconfig,freetype,gcc,gcc-g++,gdk-pixbuf2,glib2,glu,gtk+2,harfbuzz,libICE,libSM,libX11,libXau,libXcomposite,libXcursor,libXdamage,libXdmcp,libXext,libXfixes,libXft,libXi,libXinerama,libXmu,libXpm,libXrandr,libXrender,libXt,libXxf86misc,libXxf86vm,libdrm,libffi,libglade,libjpeg-turbo,libpng,libxcb,libxml2,libxshmfence,mesa,pango,pixman,util-linux,xz,zlib
xset.dep:libX11,libXau,libXdmcp,libXext,libXfontcache,libXmu,libXxf86misc,libxcb
xsetroot.dep:libX11,libXau,libXcursor,libXdmcp,libXfixes,libXmu,libXrender,libxcb
xsm.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libxcb,util-linux
xstdcmap.dep:libICE,libSM,libX11,libXau,libXdmcp,libXext,libXmu,libXt,libxcb,util-linux
xterm.dep:bzip2,expat,fontconfig,freetype,glib2,harfbuzz,libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXft,libXinerama,libXmu,libXpm,libXrender,libXt,libpng,libtermcap,libxcb,utempter,util-linux,zlib
xv.dep:jasper,libX11,libXau,libXdmcp,libjpeg-turbo,libpng,libtiff,libxcb,xz,zlib
xvidtune.dep:libICE,libSM,libX11,libXau,libXaw,libXdmcp,libXext,libXmu,libXpm,libXt,libXxf86vm,libxcb,util-linux
xvinfo.dep:libX11,libXau,libXdmcp,libXext,libXv,libxcb
xwd.dep:libX11,libXau,libXdmcp,libxcb,libxkbfile
xwininfo.dep:libXau,libXdmcp,libxcb
xwud.dep:libX11,libXau,libXdmcp,libxcb
yptools.dep:gdbm
ytalk.dep:ncurses
zeroconf-ioslave.dep:acl,attica,attr,bzip2,eudev,expat,fontconfig,freetype,gamin,gcc,gcc-g++,glib2,harfbuzz,kdelibs,libICE,libSM,libX11,libXau,libXcursor,libXdmcp,libXext,libXfixes,libXft,libXi,libXpm,libXrender,libXtst,libdbusmenu-qt,libffi,libpng,libxcb,libxml2,qca,qt,soprano,strigi,util-linux,xz,zlib
zsh.dep:gdbm,ncurses
]]

--[[ 
get deps:
  wget -r -np -l 1 http://slackware.uk/salix/x86_64/slackware-14.2/deps/
then in dep subdir
  grep "" *.dep >alldeps
  
]]


data.base02 = [[
aaa_base
aaa_elflibs
aaa_terminfo
acl
acpid
at
attr
bash
bc
bin
bzip2
ca-certificates
coreutils
cpio
cpufrequtils
cryptsetup
dcron
devs
dialog
diffutils
dmidecode
dosfstools
e2fsprogs
etc
eudev
file
findutils
gawk
gettext
glibc
glibc-zoneinfo
gnupg
gpgme
gpm
gptfdisk
grep
groff
gzip
hdparm
hostname
hwdata
infozip
inotify-tools
iptables
kbd
kernel-firmware
kernel-generic
kernel-huge
kernel-modules
kmod
less
lftp
libcgroup
libgudev
lsof
lvm2
lynx
man
man-pages
mc
mcelog
mkinitrd
network-scripts
openssh
openssl
os-prober
pciutils
pkgtools
procps-ng
rsync
screen
sdparm
sed
shadow
slackpkg
sudo
sysfsutils
sysklogd
syslinux
sysvinit
sysvinit-functions
sysvinit-scripts
tar
time
usbutils
util-linux
wget
which
xz
]]

function load_list(fname)
	local s= data[fname]	
	local t = he.lines(s)
	local pt = list()
	for i, l in ipairs(t) do
		l = he.strip(l)
		if (#l > 0) and not (l:sub(1,1) == "#") then 
			pt:insert(l) 
		end
	end
	return pt
end

function load_dep_tbl(fname)	
	local s= data[fname]
	s = s:gsub("openssl|openssl%-solibs", "openssl")
	local t = he.lines(s)
--~ 	print("dep lines", #t)
	local dt = {}
	allpkgd = {}
	for i, l in ipairs(t) do
		if l:find("|") then
			print("==|", l)
		end
		p, d = l:match("(%S-)%.dep:(%S+)")
		if p then
			local dl = he.split(d, ",")
			dt[p] = dl
			for i, v in ipairs(dl) do allpkgd[v] = 1 end
		end
	end
--~ 	print("packages", he.count(dt)-1, he.count(dt.allpkgd))
	return dt
end

df = "alldeps01"; dt = load_dep_tbl(df); print("dt loaded ("..df..").")

function loadnoarch(fname)
	-- ls | grep noarch
	local s= he.fget(fname)	
	s = s:gsub("(%d+dpi)", "ZZZ%1")
	local t = he.lines(s)
	print("lines in noarch", #t)
	local pt = list()
	for i,v in ipairs(t) do
		
		local p = v:gsub("%-%d.+$", "")
		p = p:gsub("ZZZ(%d+dpi)", "%1")
		pt:insert(p)
	end
--~ 	for i=1, #t do
--~ 		print(he.rpad(pt[i], 20), t[i])
--~ 	end
	return pt
end


function toint(s)
	local siz
	m = s:match("(.+)M")
	k = s:match("(.+)K")
	if m then siz = tonumber(m) * 1024 * 1024
	elseif k then siz = tonumber(k) * 1024
	else siz = tonumber(s)
	end
	return siz and math.floor(siz) 
end


function load_psizes()
	-- grep "UNCOMPRESSED PACKAGE SIZE" * >pkgsiz
	local s= he.fget("pkgsiz")	
	s = s:gsub("(%d+dpi)", "ZZZ%1")
	local t = he.lines(s)
	local pst = {}
	for i,v in ipairs(t) do
		local p, s = v:match("^(%S-)%-%d.+SIZE:%s+(%S+)")
		if p then 
			p = p:gsub("ZZZ(%d+dpi)", "%1")
			if not toint(s) then print("sz??", v) end
			if not pst[p] then
				pst[p] = toint(s)
			else
				print("dupl??", v)
			end
		else 
			print("match??", v)
		end
	end
--~ 	print("pkgsiz:", #t, he.count(pst))
	return pst
end

function make_psizes()
	local pst = load_psizes()
	t = list()
	for i,k in ipairs(he.sortedkeys(pst)) do 
		t:insert(he.rpad(k, 30,'.') .. he.ntos(pst[k], nil, 12))
	end
	he.fput("psizes", t:concat('\n'))	
end

function append_deps(pl, dt)
	local at = list()
	for i, p in ipairs(bt) do
		at:uextend({p})
		if dt[p] then 
			at:uextend(dt[p]) 
			if dt[p]:has"python" then print("py:", p) end
		end
	end
	table.sort(at)
	return at
end

function make_base_deps(bfn)
	bl = load_list(bfn)
	local al = list()
	for i, p in ipairs(bl) do
		al:uextend({p})
		if dt[p] then 
			al:uextend(dt[p]) 
			if dt[p]:has"python" then print("py:", p) end
		end
	end
	table.sort(al)
	return al
end

function islist(x)
	return type(x) == "table" and getmetatable(x) == list
end

function depof(x)
	local dol = list()
	for p, dl in pairs(dt) do
		if not islist(dl) then print("??", p) end
		if dl:has(x) then dol:insert(p) end
	end
	dol:sort()
	return dol
end

--~ print(depof'python':concat'  ')


al = make_base_deps("base02"); he.fputlines("basedep.02a", al)




