project_name=$1
app_name=$2
pkg_name=$3
apk_name=$4
debug=$5
deploy=$6
version=$7

and_path=obj/android/

if [ -e $and_path ]; then
	android update project --name $project_name --target 4 --path $and_path
else
	android create project --name $project_name --target 4 --path $and_path --package $pkg_name --activity app_name
fi

mkdir -p ${and_path}/jni/out
ln -fs ${NIT_DIR} ${and_path}/jni/out/nit
ln -fs ${MNIT_DIR} ${and_path}/jni/out/mnit
