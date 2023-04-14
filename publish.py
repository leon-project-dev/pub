from argparse import ArgumentError
from ast import Raise
from fnmatch import fnmatch
import os
import shutil
import sys
from typing import List, Tuple


def GetFileFolderCount(path: str) -> int:    
    dirs = os.listdir(path)    
    total = 0
    for dir in dirs:
        if os.path.isdir(os.path.join(path, dir)):
            total += 1
    
    return total


def GetNewFolderName(path: str) -> str:
    dirs = []    
    
    for dir in os.listdir(path):
        if os.path.isdir(os.path.join(path, dir)):
            dirs.append(dir)
    
    if len(dirs) == 0:
        return ""
        
    dirs.sort(key=lambda dir: os.path.getmtime(os.path.join(path, dir)))

    return dirs[-1]

# 删除老的文件夹
def DeleteOldFolder(path: str):
    dirs = []
    for dir in os.listdir(path):
        if os.path.isdir(os.path.join(path, dir)):
            dirs.append(dir)
    
    if len(dirs) == 0:
        return
        
    dirs.sort(key=lambda dir: os.path.getmtime(os.path.join(path, dir)), reverse=True)

    shutil.rmtree(os.path.join(path, dirs[-1]))

def DeleteNewFolder(path: str):
    dirs = []
    for dir in os.listdir(path):
        if os.path.isdir(os.path.join(path, dir)):
            dirs.append(dir)
    
    if len(dirs) == 0:
        return
        
    dirs.sort(key=lambda dir: os.path.getmtime(os.path.join(path, dir)), reverse=False)

    shutil.rmtree(os.path.join(path, dirs[-1]))

# 保存版本
def SaveVersion(filePath: str, content: str):
    fs = open(filePath, "w+")
    fs.write(content)
    fs.close()

# 文件夹命名规则： 日期-版本号  版本号：1.1.1.1
# 返回前面是大版本，后面是小版本
def GetVersion(folderName: str):
    names = folderName.split('_')
    if len(names) != 2:
        raise RuntimeError(f'folder name illegal, folder: {folderName}')
    
    verStr = names[1]
    # 检测version的合法性
    vers = verStr.split('.')
    if len(vers) != 4:
        raise RuntimeError(f'folder name illegal, folder: {folderName}' )

    return f'{vers[0]}.{vers[1]}.{vers[2]}', vers[3]    

# argv[0]： 检测的文件夹路径
# argv[1]:  当前文件夹最多允许存在的文件夹个数
if __name__ == "__main__":
    if len(sys.argv) != 4:
        raise ArgumentError("参数个数不合法, 参数个数应该为2个, argv[0] 应该为需要检测的文件夹路径, argv[1] 为当前文件夹最多允许存在的文件夹个数, argv[2] 版本文件路径")


    checkDir = sys.argv[1]
    dirTotal = int(sys.argv[2])
    remoteVersonPath = sys.argv[3]

    if not os.path.exists(checkDir):
        print(f'{checkDir} not exist, is frist publish')
        SaveVersion(remoteVersonPath ,"1.0.0.1")                                # 当前文件夹目录不存在，说明第一次发布
    else:

        folders = GetFileFolderCount(checkDir)
        if folders == 0:                # 当前夹子没有版本文件，为第一次发布
            print(f'{checkDir} exist, but no child dir, is frist publish')
            SaveVersion(remoteVersonPath ,"1.0.0.1")
        else:
            

            # 检查当前文件夹的文件夹个数
            if folders >= dirTotal:
                DeleteOldFolder(checkDir)           # 刪除最老的文件夾        
    
            # 获取最新的版本号 保存到文件夹 
            dirName = GetNewFolderName(checkDir)
            # 解析文件夹名字返回版本号 ? 文件夹的命名方式
            mainVesion, revisionVersion = GetVersion(dirName)
            
            # 将主版本和修订版本写到文件中
            SaveVersion(remoteVersonPath ,f'{mainVesion}.{ int(revisionVersion) + 1}')    
            print("!!!run success!!!")



