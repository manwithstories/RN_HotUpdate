#!/usr/bin/python
import os
import json
import subprocess
import json
import shutil

def main():
    release_repository_path = 'release_repository'
    package_json_path = 'package.json'

    makedir(release_repository_path)

    package_json_file = open(package_json_path, 'r')
    package_json_str = package_json_file.read()

    package_json = json.loads(package_json_str)

    # get package json, version
    version = package_json['version']

    release_file_path = release_repository_path+'/v'+version

    isContinue = 'y';
    if os.path.exists(release_file_path):
        isContinue = raw_input("version:"+version+" already exists, are you sure to override? (y/n)");

    if isContinue != 'y':
        return

    rnbundle_file_path = release_file_path + '/bundle'
    patches_file_path = release_file_path + '/patches'

    patches_android_file_path = patches_file_path + '/android'
    patches_ios_file_path = patches_file_path + '/ios'

    rnbundle_android_file_path = rnbundle_file_path + '/android'
    rnbundle_ios_file_path = rnbundle_file_path + '/ios'

    ios_info = rnbundle_ios_file_path + '/info.json'
    android_info = rnbundle_android_file_path + '/info.json'



    makedir(release_file_path)
    makedir(rnbundle_file_path)
    makedir(rnbundle_android_file_path)
    makedir(rnbundle_ios_file_path)
    makedir(patches_file_path)
    makedir(patches_android_file_path)
    makedir(patches_ios_file_path)

    outputJson = json.dumps({'version': version})

    json_info_file = open(ios_info, 'w')
    json_info_file.seek(0)
    json_info_file.write(outputJson)
    json_info_file.close();

    json_info_file = open(android_info, 'w')
    json_info_file.seek(0)
    json_info_file.write(outputJson)
    json_info_file.close();


    android_bundle_file_path = rnbundle_android_file_path + '/index.android.jsbundle'
    ios_bundle_file_path = rnbundle_ios_file_path + '/index.ios.jsbundle'

    npm_shell_android = 'react-native bundle --platform android --dev false --entry-file ./index.android.js --bundle-output '+android_bundle_file_path+' --assets-dest '+rnbundle_android_file_path
    npm_shell_ios = 'react-native bundle --platform ios --dev false --entry-file ./index.ios.js --bundle-output '+ios_bundle_file_path+' --assets-dest '+rnbundle_ios_file_path

    print('generate folders complete! wainting for execture bundle...');
    output = subprocess.Popen(npm_shell_android, shell=True, stdout=subprocess.PIPE).stdout.read()
    print(output)

    output = subprocess.Popen(npm_shell_ios, shell=True, stdout=subprocess.PIPE).stdout.read()
    print(output)

    output = subprocess.Popen('npm run bundle-patches', shell=True, stdout=subprocess.PIPE).stdout.read()
    print(output)

    print('all done')


def makedir(dir):
    if(os.path.isdir(dir)):
        pass
    else:
        print('create folder '+dir)
        os.mkdir(dir)

if __name__ == "__main__":
    main()
