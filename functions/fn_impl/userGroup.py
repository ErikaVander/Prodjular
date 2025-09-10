# The Cloud Functions for Firebase SDK to create Cloud Functions and set up triggers.
from firebase_functions import db_fn, https_fn

# The Firebase Admin SDK to access the Firebase Realtime Database.
from firebase_admin import initialize_app, db

import time

@db_fn.on_value_created(reference="/groups/{groupID}/members/{userID}")
def create_value_somewhere_else_group(event: db_fn.Event[db_fn.Change]) -> None:
    name = db.reference(event.reference).parent.parent.child("name").get()
    adminRef = db.reference(event.reference).parent.parent.child("admin")
    key = event.reference.split("/")
    print("will attempt adding new group data to newly added user")
    db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("numOfMembers").set(len(event.data.values()))
    if(key[-1] == adminRef.child("userID").get()):
        db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("isAdmin").set("true")
    else:
        db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("isAdmin").set("false")
        db.reference("groups").child(key[-3]).child("pendingMembers").child(key[-1]).delete()
        db.reference("users").child(adminRef.child("userID").get()).child("notifications").push({"header":"Member Added", "content":"Someone accepted your invitation to " + name, "timestamp":str(time.time())})
    db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("name").set(name)
    db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("adminName").set(adminRef.child("name").get())

@db_fn.on_value_created(reference="/groups/{groupID}/pendingMembers/{userID}")
def create_value_somewhere_else_pending_group(event: db_fn.Event[db_fn.Change]) -> None:
    key = event.reference.split("/")
    print("will attempt adding new group data to newly invited user")
    db.reference("users").child(key[-1]).child("pendingGroups").child(key[-3]).child("numOfMembers").set(len(event.data.values()))
    name = db.reference(event.reference).parent.parent.child("name").get()
    db.reference("users").child(key[-1]).child("pendingGroups").child(key[-3]).child("name").set(name)
    admin = db.reference(event.reference).parent.parent.child("admin").child("name").get()
    db.reference("users").child(key[-1]).child("pendingGroups").child(key[-3]).child("adminName").set(admin)
    db.reference("users").child(key[-1]).child("notifications").push({"header":"Group Invitation", "content":"You have been invited to a group called " + name + " group", "timestamp":str(time.time())})

@db_fn.on_value_deleted(reference="/groups/{groupID}/members/{userID}")
def delete_value_somewhere_else_group(event: db_fn.Event[db_fn.Change]) -> None:
    key = event.reference.split("/")
    print("will attempt deleting group data from user that was removed")
    db.reference("users").child(key[-1]).child("groups").child(key[-3]).delete()

@db_fn.on_value_deleted(reference="/groups/{groupID}/pendingMembers/{userID}")
def delete_value_somewhere_else_pending_group(event: db_fn.Event[db_fn.Change]) -> None:
    key = event.reference.split("/")
    print("will attempt deleting group data from pending user that was removed")
    db.reference("users").child(key[-1]).child("pendingGroups").child(key[-3]).delete()

@db_fn.on_value_deleted(reference="/groups/{groupID}")
def delete_value_somewhere_else_when_group_deleted(event: db_fn.Event[db_fn.Change]) -> None:
    key = event.reference.split("/")
    print("will attempt deleting group data from all pending members")
    for userID in event.data.get("pendingMembers"):
        db.reference("users").child(userID).child("pendingGroups").child(key[-3]).delete()
    for userID in event.data.get("members"):
        db.reference("users").child(userID).child("groups").child(key[-3]).delete()

# @db_fn.on_value_updated(reference="/groups/{groupID}/members/{userID}/isMember")
# def update_value_somewhere_else(event: db_fn.Event[db_fn.Change]) -> None:
#     key = event.reference.split("/")

#     print("will attempt updating group data in users node")
#     print("userID = " + key[-2] + " isMember = " + str(event.data.after))
#     db.reference("users").child(key[-2]).child("groups").child(key[-4]).child("isMember").set(event.data.after)
#     # db.reference("users").child(key[-1]).child("groups").child(key[-3]).child("name").set(event.data.after.get("name"))

#     if(event.data.after == 1):
#         admin = db.reference(event.reference).parent.parent.parent.child("admin").child("userID").get()
#         name = db.reference(event.reference).parent.parent.parent.child("name").get()
#         db.reference("users").child(admin).child("notifications").child("header").set("Member Added")
#         db.reference("users").child(admin).child("notifications").child("content").set("Someone accepted your invitation to " + name)