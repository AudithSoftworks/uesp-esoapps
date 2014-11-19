import csv
import collections
import os.path
import re
import operator
import sys
import datetime
import shutil
import ntpath
import EsoGlobals
from EsoGlobals import CEsoGlobals
import EsoLuaFile
from EsoLuaFile import CEsoLuaFile
import EsoFunctionInfo


INPUT_GLOBAL_FILENAME = "d:\\esoexport\\goodimages10\\globals_6b.txt"
OUTPUT_PATH = "d:\\temp\\esodata\\"

INPUT_LUA_PATH = "d:\\esoexport\\gamemnf10\\esoui\\"


#esoGlobals = CEsoGlobals()
#esoGlobals.LoadParseFile(INPUT_GLOBAL_FILENAME)
#esoGlobals.Dump(OUTPUT_PATH + "globals.txt")
#esoGlobals.CreateHTML(OUTPUT_PATH + "globals.html")

'''
#esoLuaFile = EsoLuaFile.LoadLuaFile("d:\\esoexport\\gamemnf10\\esoui\\libraries\\zo_menubar\\zo_menubar.lua", "d:\\esoexport\\gamemnf10\\esoui\\")
#esoLuaFile = EsoLuaFile.LoadLuaFile("d:\\esoexport\\gamemnf10\\esoui\\pregame\\statemanager\\pc\\pregamestates.lua", "d:\\esoexport\\gamemnf10\\esoui\\")
#esoLuaFile = EsoLuaFile.LoadLuaFile("d:\\esoexport\\gamemnf10\\esoui\\pregame\\charactercreate\\zo_charactercreate.lua", "d:\\esoexport\\gamemnf10\\esoui\\")
#esoLuaFile = EsoLuaFile.LoadLuaFile("d:\\esoexport\\gamemnf10\\esoui\\libraries\\zo_templates\\optionswindowtemplate.lua", "d:\\esoexport\\gamemnf10\\esoui\\")
esoLuaFile = EsoLuaFile.LoadLuaFile("d:\\esoexport\\gamemnf10\\esoui\\ingame\\slashcommands\\slashcommands.lua", "d:\\esoexport\\gamemnf10\\esoui\\")


esoFunctions = EsoFunctionInfo.FindLuaFunctions(esoLuaFile)

for function in esoFunctions:
    print function.fullName + "(" + ", ".join(function.params) + ")"
    #print function.fullString
    print "\t{0}:{1} to {2}:{3}".format(function.startLinePos, function.startCharPos, function.endLinePos, function.endCharPos)

'''
esoLuaFiles = EsoLuaFile.LoadAllLuaFiles(INPUT_LUA_PATH, INPUT_LUA_PATH)
tokenCount = 0
funcCount = 0

print "Parsing functions from {0} Lua files...".format(len(esoLuaFiles))

for file in esoLuaFiles:
    print file.relFilename
    tokenCount += len(file.GetTokens())
    esoFunctions = EsoFunctionInfo.FindLuaFunctions(file)
    funcCount += len(esoFunctions)

print tokenCount, funcCount

