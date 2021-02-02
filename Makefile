
DEST=/tmp/androidbuild
APPNAME=skeleton
DOMAIN=com/example
PACKAGE=${DOMAIN}/${APPNAME}
# e.g. USERLIBS=:myfile.jar:myfile2.jar
USERLIBS=
SRCDIR=src/${PACKAGE}
JARFILE=/usr/lib/android-sdk/platforms/android-19/android.jar
AAPT=/usr/bin/aapt
APKSIGNER=/usr/bin/apksigner
DX=/usr/lib/android-sdk/build-tools/27.0.1/dx
JAVAC=/usr/bin/javac
KOTLINC=/opt/kotlin/kotlinc/bin/kotlinc 
ZIPALIGN=/usr/bin/zipalign
PASSWORDTXT=~/src/android/private/password.txt
KEYSTORE=~/src/android/private/my.keystore
DEBUGKEYSTORE=~/.android/debug.keystore

all: unsigned

release: ${DEST}/bin/${APPNAME}.release.apk
debug: ${DEST}/bin/${APPNAME}.debug.apk
unsigned: ${DEST}/bin/${APPNAME}.unsigned.apk

${DEST}/bin/${APPNAME}.unsigned.apk: ${DEST}/classes.dex
	mkdir -p ${DEST}/bin
	${AAPT} package -f -m -F ${DEST}/bin/${APPNAME}.unaligned.apk -M ${DEST}/AndroidManifest.xml -S ${DEST}/res -I ${JARFILE}
	cd ${DEST} ; ${AAPT} add ${DEST}/bin/${APPNAME}.unaligned.apk classes.dex
	${ZIPALIGN} -f 4 ${DEST}/bin/${APPNAME}.unaligned.apk ${DEST}/bin/${APPNAME}.unsigned.apk
	ls -l ${DEST}/bin/${APPNAME}.unsigned.apk

${DEST}/bin/${APPNAME}.debug.apk: ${DEST}/bin/${APPNAME}.unsigned.apk
	cp ${DEST}/bin/${APPNAME}.unsigned.apk ${DEST}/bin/${APPNAME}.tosign.apk
	${APKSIGNER} sign --ks ${DEBUGKEYSTORE} -ks-pass pass:android ${DEST}/bin/${APPNAME}.tosign.apk
	mv ${DEST}/bin/${APPNAME}.tosign.apk ${DEST}/bin/${APPNAME}.debug.apk
	ls -l ${DEST}/bin/${APPNAME}.debug.apk

${DEST}/bin/${APPNAME}.release.apk: ${DEST}/bin/${APPNAME}.unsigned.apk
	cp ${DEST}/bin/${APPNAME}.unsigned.apk ${DEST}/bin/${APPNAME}.tosign.apk
	echo -n "Enter this password: " | cat - ${PASSWORDTXT}
	${APKSIGNER} sign --ks ${KEYSTORE} ${DEST}/bin/${APPNAME}.tosign.apk
	mv ${DEST}/bin/${APPNAME}.tosign.apk ${DEST}/bin/${APPNAME}.release.apk
	ls -l ${DEST}/bin/${APPNAME}.release.apk

${DEST}/${SRCDIR}/R.java: ${DEST}/AndroidManifest.xml
	mkdir -p ${DEST}/res/drawable
	mkdir -p ${DEST}/res/layout
	mkdir -p ${DEST}/res/values
	mkdir -p ${DEST}/${SRCDIR}
	cp icon.png ${DEST}/res/drawable/
	cp main.xml ${DEST}/res/layout/
	cp strings.xml ${DEST}/res/values/
	cp *.kt ${DEST}/${SRCDIR}/
	${AAPT} package -f -m -J ${DEST}/src -M ${DEST}/AndroidManifest.xml -S ${DEST}/res -I ${JARFILE}

${DEST}/obj/${PACKAGE}/Main.class: ${DEST}/${SRCDIR}/R.java
	${JAVAC} -source 8 -target 8 -d ${DEST}/obj -classpath ${DEST}/src${USERLIBS} -bootclasspath ${JARFILE} ${DEST}/${SRCDIR}/*.java
	${KOTLINC} -classpath ${JARFILE}:${DEST}/obj/${PACKAGE} -d ${DEST}/obj ${DEST}/src/${PACKAGE}/*.kt

${DEST}/classes.dex: ${DEST}/obj/${PACKAGE}/Main.class
	${DX} --dex --output=${DEST}/classes.dex ${DEST}/obj

${DEST}/AndroidManifest.xml: AndroidManifest.xml
	mkdir -p ${DEST}
	cp AndroidManifest.xml ${DEST}/AndroidManifest.xml

heart:
	scp /tmp/androidbuild/bin/skeleton.debug.apk heart:public_html/apk/
clean:
	rm -rf /tmp/androidbuild
jesus:
	tar -jcf - . | jesus android.skel-kotlin.tar.bz2
.PHONY: jesus
