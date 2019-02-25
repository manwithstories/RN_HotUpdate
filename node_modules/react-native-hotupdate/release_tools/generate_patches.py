#!/usr/bin/python
from contextlib import closing
from zipfile import ZipFile, ZIP_DEFLATED
import os
import subprocess
import shutil
import bsdiff

def main():
    release_repository_path = 'release_repository'
    dirs = mylistdir(release_repository_path)
    dirs.sort(key=lambda x, : int(x.replace('v', '').replace('.', '')))


    baseDir = './'+release_repository_path+'/'

    if len(dirs) > 0:
        nextFolderName = dirs[0]
        nextDir = baseDir + dirs[0]
        lastDir = dirs[-1]

        # androidImg = baseDir+lastDir+"/bundle/android/assets/img"
        # iosImg = baseDir+lastDir+"/bundle/ios/assets/img"
        # copyAssets(androidImg, iosImg)

        # create zip
        for folder in dirs:
            originFileAndroid = baseDir + folder + '/bundle/android/'
            originFileIos = baseDir + folder + '/bundle/ios/'

            androidZipFile = baseDir + folder + '/bundle/' + 'android.zip'
            iosZipFile = baseDir + folder + '/bundle/' + 'ios.zip'

            #create android zip file
            zipdir(originFileAndroid, androidZipFile)

            #create android zip file
            zipdir(originFileIos, iosZipFile)

            targetFileAndroid = baseDir + lastDir + '/bundle/android.zip'
            patchesFileAndroid = baseDir + lastDir + '/patches/android/' + nextFolderName + '_' + lastDir

            targetFileIos = baseDir + lastDir + '/bundle/ios.zip'
            patchesFileIos = baseDir + lastDir + '/patches/ios/' + nextFolderName + '_' + lastDir

            nextFolderName = folder
            nextDir = baseDir + folder

        print('create zip file done')

        # create patches files
        nextFolderName = dirs[0]
        nextDir = baseDir + dirs[0]
        for folder in dirs[1:]:
            androidZipFile = nextDir + '/bundle/' + 'android.zip'
            iosZipFile = nextDir + '/bundle/' + 'ios.zip'

            targetFileAndroid = baseDir + lastDir + '/bundle/android.zip'
            patchesFileAndroid = baseDir + lastDir + '/patches/android/' + nextFolderName + '_' + lastDir

            targetFileIos = baseDir + lastDir + '/bundle/ios.zip'
            patchesFileIos = baseDir + lastDir + '/patches/ios/' + nextFolderName + '_' + lastDir

            bsdiff.generatePatch(androidZipFile, targetFileAndroid, patchesFileAndroid)
            bsdiff.generatePatch(iosZipFile, targetFileIos, patchesFileIos)
            # shellAndroid = './node_modules/react-native-hotupdate/release_tools/bsdiff.py -o ' + androidZipFile + ' -t ' + targetFileAndroid + ' -p ' + patchesFileAndroid
            # shellIos = './node_modules/react-native-hotupdate/release_tools/bsdiff.py -o ' + iosZipFile + ' -t ' + targetFileIos + ' -p ' + patchesFileIos
            #
            # subprocess.Popen(shellAndroid, shell=True, stdout=subprocess.PIPE).stdout.read()
            # subprocess.Popen(shellIos, shell=True, stdout=subprocess.PIPE).stdout.read()
            nextFolderName = folder
            nextDir = baseDir + folder

        print('create patches file done')

def copyAssets(androidDir, iosDir):
    if os.path.exists(androidDir):
        shutil.rmtree(androidDir)
    if os.path.exists(iosDir):
        shutil.rmtree(iosDir)
    # copy img froder
    shutil.copytree('img', androidDir)
    shutil.copytree('img', iosDir)
    print('copy imgage resouce done')


def mylistdir(directory):
    """A specialized version of os.listdir() that ignores files that
    start with a leading period."""
    filelist = os.listdir(directory)
    return [x for x in filelist if not (x.startswith('.'))]


def zipdir(basedir, archivename):
    assert os.path.isdir(basedir)
    with closing(ZipFile(archivename, "w", ZIP_DEFLATED)) as z:
        for root, dirs, files in os.walk(basedir):
            #NOTE: ignore empty directories
            for fn in files:
                absfn = os.path.join(root, fn)
                zfn = absfn[len(basedir)+len(os.sep)-1:] #XXX: relative path
                z.write(absfn, zfn)

if __name__ == "__main__":
    main()
