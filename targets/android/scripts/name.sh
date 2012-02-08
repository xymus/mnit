app_name=$1
package=$2
version=$3.`date +%s`
version_code=$3.`date +%s`

mkdir -p res/values
sed "s/APP_NAME/$app_name/" ${MNIT_DIR}/targets/android/templates/res/values/strings.xml > res/values/strings.xml
sed -e "s/APP_NAME/$app_name/" -e "s/PACKAGE/$package/" -e "s/VERSION/$version/" -e "s/VERSION_CODE/$version_code/" ${MNIT_DIR}/targets/android/templates/AndroidManifest.xml > AndroidManifest.xml

