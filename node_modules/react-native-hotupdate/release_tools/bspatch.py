#!/usr/bin/python
import sys, getopt,bsdiff4


def main(argv):
    patchFilePath = ''
    originFilePath = ''
    try:
        opts, args = getopt.getopt(argv, "hp:o:", ["patchFilePath =", "originFilePath ="])
    except getopt.GetoptError:
        print 'bspatch -o <originFilePath> -p <patchFilePath>'
    for opt, arg in opts:
        if opt == '-h':
            print 'bspatch -o <originFilePath> -p <patchFilePath>'
            sys.exit(2)
        elif opt == '-p':
            patchFilePath = arg
        elif opt == '-o':
            originFilePath = arg

    print 'patchFilePath is ', patchFilePath
    print 'originFilePath is ', originFilePath

    bsdiff4.file_patch(originFilePath, originFilePath, patchFilePath)

    print '#### originfile is replaced #####'

if __name__ == "__main__":
    main(sys.argv[1:])
