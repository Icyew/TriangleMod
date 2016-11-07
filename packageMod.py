#!/usr/bin/python

import sys, getopt, git, os, shutil, re
from os import path
from subprocess import Popen
from distutils import dir_util

def clear_or_create_directory(dirPath):
    if path.exists(dirPath):
        shutil.rmtree(dirPath)
        os.makedirs(dirPath)

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'p:g:sxd')
    except getopt.GetoptError as err:
        print(err)
        usage()
        sys.exit(2)

    modPath = None
    gamePath = None
    scriptsOnly = False
    xmlOnly = False
    debug = False

    for opt, arg in opts:
        if opt == '-p':
            modPath = path.abspath(arg)
        elif opt == '-g':
            gamePath = arg
        elif opt == '-s':
            scriptsOnly = True
        elif opt == '-x':
            xmlOnly = True
        elif opt == '-d':
            debug = True

    if not modPath:
        print('must specify modPath. modPath should have \'Witcher3/content\' as an immediate child')
        sys.exit(2)
    if not gamePath:
        print('must specify gamePath. gamePath is the game\'s root directory')
        sys.exit(2)

    print('modPath: ' + modPath)
    print('gamePath: ' + gamePath)

    tempPath = path.join(modPath, 'temp')
    contentPath = path.join(modPath, 'Witcher3', 'content')
    scriptPath = path.join(contentPath, 'scripts')
    batPath = path.join(modPath, 'pack.bat')
    binPath = path.join(modPath, 'bin')
    studioPath = path.abspath(path.join(modPath, '..', 'ScriptStudio'))
    studioLocal = path.join(studioPath, 'scripts', 'local')
    studioSource = path.join(studioPath, 'scripts', 'source')

    clear_or_create_directory(tempPath)
    clear_or_create_directory(studioSource)
    clear_or_create_directory(studioLocal)

    repo = git.Repo(modPath)
    assert not repo.bare

    branches = [head for head in repo.branches if head.name == 'vanilla']
    assert len(branches) == 1
    diff = repo.git.diff(branches[0], '--name-status').split('\n')
    for line in diff:
        parts = line.split(maxsplit=1)
        assert len(parts) == 2
        status = parts[0]
        relPath = parts[1]
        dirname, basename = path.split(relPath)
        filename, ext = path.splitext(basename)
        if dirname.startswith('Witcher3'):
            assert status in ['A', 'M']
            filePath = path.join(modPath, relPath)
            tempFilePath = path.join(tempPath, relPath)
            if ext == '.xml' and not scriptsOnly:
                os.makedirs(path.join(tempPath, dirname), exist_ok=True)
                shutil.copyfile(filePath, tempFilePath)
            elif ext == '.ws' and not xmlOnly:
                destPath = None
                if not debug:
                    destPath = tempFilePath
                elif status == 'A':
                    destPath = re.sub(scriptPath, studioLocal, filePath, count=1)
                elif status == 'M':
                    destPath = re.sub(scriptPath, studioSource, filePath, count=1)
                assert destPath != None
                destDir, destBaseName = path.split(destPath)
                os.makedirs(destDir, exist_ok=True)
                shutil.copyfile(filePath, destPath)
            print(status, relPath)

    tempBinPath = path.join(tempPath, 'bin')
    shutil.copytree(binPath, tempBinPath)

    print('Necessary files have been copied to temp folder!')

    modName = 'mod1111Triangle'

    dir_util.copy_tree(tempBinPath, path.join(gamePath, 'bin'))
    shutil.rmtree(tempBinPath)

    gameModPath = path.join(gamePath, 'Mods', modName)
    gameScriptPath = path.join(gamePath, 'Mods', modName, 'content', 'scripts')
    tempScriptPath = re.sub(modPath, tempPath, scriptPath)
    if path.exists(tempScriptPath):
        shutil.rmtree(gameScriptPath, ignore_errors=True)
        shutil.copytree(tempScriptPath, gameScriptPath)
        shutil.rmtree(tempScriptPath)

    print('Script and bin files copied to game folder!')

    if not scriptsOnly:
        p = Popen(path.join(modPath, 'pack.bat'))
        p.wait()

    print('Finished!')


if __name__ == '__main__':
    main()