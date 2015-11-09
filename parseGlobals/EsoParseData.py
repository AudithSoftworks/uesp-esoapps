import EsoEnvironment
import EsoLuaFile
import EsoFunctionInfo

    # Modify below constants to point to relevant files/paths
INPUT_GLOBAL_FILENAME = "/cygdrive/d/esoexport/gamemnf-1.8/globals.txt"
INPUT_LUA_PATH = "/cygdrive/d/esoexport/gamemnf-1.8/esoui/"
OUTPUT_PATH = "/cygdrive/d/esoexport/apidata/output/100013/"

    # Set to your specific Google CSE ID if you want site search
GOOGLE_SEARCH_ENGINE_ID = "012503365948233236492:dsuicagnjii"

esoEnvironment = EsoEnvironment.CEsoEnvironment(GOOGLE_SEARCH_ENGINE_ID)
esoEnvironment.LoadGlobals(INPUT_GLOBAL_FILENAME)
esoEnvironment.LoadLuaFiles(INPUT_LUA_PATH)
esoEnvironment.CreateAll(OUTPUT_PATH)

# TODO
# - Automatically create/update API version page
# - Sort call data better?
# - Object tree?
# - Function call values?
# - Include file size in directory files
# - Better directory format
# - Include XML and other files in directory lists
# - Common header/toolbar
