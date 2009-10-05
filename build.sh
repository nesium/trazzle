#!/bin/bash
 
while getopts ":t:p:" Option
do
  case $Option in
    p ) project=$OPTARG;;
    t ) tag=$OPTARG;;
  esac
done
shift $(($OPTIND - 1))
 
if [ "$project" == "" ]; then
	echo "No project specified"
	exit
fi
 
if [ "$tag" == "" ]; then
	echo "No tag specified"
	exit
fi

# Configuration
current_dir=`pwd`
final_builds=~/Desktop/release_builds
code_folder="$current_dir/Application"
build_folder=$code_folder/build
diskimage_folder=$final_builds/$project
 
if [ ! -d  $final_builds ]; then
	mkdir $final_builds
fi

if [ ! -d  $diskimage_folder ]; then
	mkdir $diskimage_folder
fi

# clean up
if [ -d $build_folder ]; then
	rm -rf $build_folder
fi

cd $code_folder
 
git pull origin master
git fetch --tags
git checkout $tag
 
sed -i "" 's/__VERSION__/'$tag'/g' Resources/Info.plist
 
echo building project
xcodebuild -target $project -configuration Release OBJROOT=$build_folder SYMROOT=$build_folder clean
xcodebuild -target $project -configuration Release OBJROOT=$build_folder SYMROOT=$build_folder OTHER_CFLAGS=""
 
if [ $? != 0 ]; then
	echo "Bad build for $project"
	say "bad build!"
else
 
	#ok, let's index the documentation if we've got it.
	#/Developer/Applications/Utilities/Help\ Indexer.app/Contents/MacOS/Help\ Indexer "/tmp/buildapp/build/Release/BuildApp.app/Contents/Resources/English.lproj/BuildAppHelp"
 
	mv $build_folder/Release/$project.app $final_builds
	#mv $build_folder/Release/$project.app $diskimage_folder
 
	# make the zip file
	cd $final_builds
	zip -r "${project}_${tag}.zip" $project.app
	rm -rf $project.app
	
	#cd $final_builds
	#hdiutil create -srcfolder $diskimage_folder -volname "$project $tag" -format UDBZ "${project}_${tag}.dmg"
	#rm -rf $project.app
	rm -rf $diskimage_folder
 
	open $final_builds
	say "done building"
 
fi
 
cd $code_folder
git checkout Resources/Info.plist
rm -rf $build_folder
git checkout master