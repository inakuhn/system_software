#!/bin/sh
#sigoetti&rabertol
#v3_2 shell skript buildroot
#Varible
MODULSRC="modul-src"
VER="-1.0.0"
END=".tar.gz"
V3BUILDROOTDL="../../V3/embedded/buildroot/dl"

loop_loo(){
	cd $MODULSRC
	for d in * ; do
		if [ -d "$d" ]; then
		# Control will enter here if $DIRECTORY exists.
			tar -zcvf $d$VER$END $d
			cp $d$VER$END $V3BUILDROOTDL
			rm -rf $d$VER$END
		
		fi
	done		
}
link_modul_pacakege(){
	cd ..
	cd V3/embedded/buildroot/package
	ln -s ../../../../V4/modul-package/ ./syso


}


loop_loo

