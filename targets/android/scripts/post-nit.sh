project_name=$1
app_name=$2
pkg_name=$3
apk_name=$4
debug=$5
deploy=$6
version=$7

ADIR=${MNIT_DIR}/targets/android/

ini_cwd=`pwd`
cd obj/android

cp ${ADIR}/templates/jni/Android.mk jni/Android.mk
cp ${ADIR}/templates/jni/nit_compile/Android.mk jni/nit_compile/Android.mk
cp ${ADIR}/templates/default.properties default.properties

ln -fs ${ADIR}/lib/libpng/jni jni/libpng
ln -fs ../../assets assets

if [ $debug ]; then
	${ADIR}/scripts/name.sh "${app_name}-debug" "${pkg_name}.debug" $version
else
	${ADIR}/scripts/name.sh ${app_name} "${pkg_name}.release" $version
fi
if [ ! $? ]; then
	echo FAILED: ${ADIR}/scripts/name.sh
	exit $?
fi

if [ $debug ]; then
	export NDK_DEBUG=1
fi
ndk-build -j 2 # compile native lib
if [ ! $? ]; then
	echo FAILED: ndk-build -j 2
	exit $?
fi
ant -q debug # generate apk
if [ ! $? ]; then
	echo FAILED: ant -q debug
	exit $?
fi

if [ $deploy ]; then
	adb uninstall ${pkg_name}.debug
	echo adb uninstall ${pkg_name}.debug
	adb install bin/${apk_name}-debug.apk
	if [ ! $? ]; then
		echo FAILED: adb install bin/${apk_name}
		exit $?
	fi
fi

cd $ini_pwd

