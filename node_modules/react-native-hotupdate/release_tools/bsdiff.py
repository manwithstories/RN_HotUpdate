#!/usr/bin/python
import sys, getopt, bsdiff4, hashlib, json

def main(argv):
    originfilepath = ''
    targetfilepath = ''
    patchesfilepath = ''
    try:
        opts, args = getopt.getopt(argv, "ho:t:p:", ["origin file=", "target file="])
    except getopt.GetoptError:
        print 'generatePatch -o <origin file path> -t <target file path> -p <patches>'
    for opt, arg in opts:
        if opt == '-h':
            print 'generatePatch -o <origin file path> -t <target file path> -p <patches>'
            sys.exit(2)
        elif opt == '-o':
            originfilepath = arg
        elif opt == '-t':
            targetfilepath = arg
        elif opt == '-p':
            patchesfilepath = arg


    generatePatch(originfilepath, targetfilepath, patchesfilepath)


def generatePatch(originfilepath, targetfilepath, patchesfilepath):
    # start to diff
    patch = bsdiff4.file_diff(originfilepath, targetfilepath, patchesfilepath)

    # create info json
    patchsJsonFilePath = patchesfilepath + '.json'
    patchsJsonFile = open(patchsJsonFilePath, 'w')
    patchFileMd5 = hashlib.md5(open(patchesfilepath, 'r').read()).hexdigest()
    originFileMd5 = hashlib.md5(open(originfilepath, 'r').read()).hexdigest()
    targetFileMd5 = hashlib.md5(open(targetfilepath, 'r').read()).hexdigest()
    outputJson = json.dumps({'originFileMd5': originFileMd5, 'targetFileMd5': targetFileMd5, 'patchFileMd5': patchFileMd5})

    # write info
    patchsJsonFile.seek(0)
    patchsJsonFile.write(outputJson)
    patchsJsonFile.close();

    print 'patch file is ', patchesfilepath


if __name__ == "__main__":
    main(sys.argv[1:])
