from fn_impl.userGroup import *

app = initialize_app()


def printAllValues(data) -> str:
    returnStr = ""
    if type(data) == dict:
        for value in data.values():
            if(type(value) == dict):
                returnStr += printAllValues(value)
            else:
                returnStr += " "
                returnStr += value
    elif type(data) == str:
        returnStr += " "
        returnStr += data
    return returnStr
def printAllKeys(data) -> str:
    returnStr = ""
    if type(data) == dict:
        for key, value in data.items():
            if(type(value) == dict):
                returnStr += " "
                returnStr += key
                returnStr += printAllValues(value)
            else:
                returnStr += " "
                returnStr += key
    elif type(data) == str:
        returnStr += "data was string"
    return returnStr
def getMemberData(data) -> dict:
    memberData = {}
    membersDict = data.get("members")
    if(data.get("members") != None and type(data.get("members")) == dict):
        for userID, userDict in membersDict.items():
            memberData[userID] = userDict.get("isMember")
    return memberData
def getNumMembers(data) -> int:
    numMembers = 0
    membersDict = data.get("members")
    if(data.get("members") != None and type(data.get("members")) == dict):
        for userDict in membersDict.values():
            if userDict.get("isMember") == 1 or userDict.get("isMember") == 2:
                numMembers += 1
    return numMembers