#!/bin/bash

echo "enter the directory name for the website"

read dirName

cd ../$dirName

echo 'do you want to do create a wp specific gitignore '
        read confirmation
	if  [ $confirmation = "y" ]||[ $confirmation = "yes" ] ; then
        echo "please enter the theme directory name"
	read themeDirName
echo "# Ignore everything in the root except the \"wp-content\" directory.
/*
!.gitignore
!wp-content/
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
Icon?
ehthumbs.db
Thumbs.db
/.project
.ftpquota 
# Ignore everything in the \"wp-content\" directory, except the \"mu-plugins\"
# and \"themes\" directories.
wp-content/*
!wp-content/plugins/
!wp-content/themes/
!wp-content/mu-plugins/
 
# Ignore everything in the \"plugins\" directory, except the plugins you
# specify (see the commented-out examples for hints on how to do this.)
wp-content/plugins/*
#!wp-content/plugins/my-single-file-plugin.php
#!wp-content/plugins/my-directory-plugin/
 
# Ignore everything in the \"themes\" directory, except the themes you
# specify (see the commented-out example for a hint on how to do this.)
wp-content/themes/*
!wp-content/themes/$themeDirName/
wp-content/themes/$themeDirName/error_log

" > .gitignore

echo 'gitignore created'
fi

git init
git config core.fileMode false
git status

echo 'do you want to do a initial commit '
	read confirmation
	if  [ $confirmation = "y" ]||[ $confirmation = "yes" ] ; then
		git add .
		git commit -m 'intial commit'
		echo "committed"
	fi

echo 'do you want to add a remote origin'
	read confirmation
	if  [ $confirmation = "y" ]||[ $confirmation = "yes" ] ; then
		echo "enter the bitbucket url provided"
		read bitBucketUrl
		git remote add origin $bitBucketUrl
		echo 'added'
		echo 'do you want to push to origin'
        	read confirmation
        	if  [ $confirmation = "y" ]||[ $confirmation = "yes" ] ; then
                	git push origin --all
                	echo 'pushed'
        	fi
	fi
