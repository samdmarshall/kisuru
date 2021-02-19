
# =======
# Imports
# =======

import logging
import strtabs
import db_sqlite
import strformat
import parseutils

#import kisurupkg/ [ config, models ]
import "config.nim"
import "models.nim"

# ===============
# Internal Layout
# ===============

const
  TableName_Bookmarks = "bookmarks"
  TableName_Tags = "tags"
  TableName_BookmarkTags = "bookmark_tags"

  KeyName_Bookmarks_Id = "id"
  KeyName_Bookmarks_Name = "name"
  KeyName_Bookmarks_Url = "url"

  KeyName_Tags_Id = "id"
  KeyName_Tags_Name = "name"

  KeyName_BookmarkTags_BookmarkId = "bookmark_id"
  KeyName_BookmarkTags_TagId = "tag_id"

  CreateTable_Bookmarks = sql(fmt"""CREATE TABLE IF NOT EXISTS {TableName_Bookmarks} (
    {KeyName_Bookmarks_Id}          INTEGER   PRIMARY KEY AUTOINCREMENT,
    {KeyName_Bookmarks_Name}        TEXT      NOT NULL UNIQUE,
    {KeyName_Bookmarks_Url}         TEXT      NOT NULL UNIQUE
  )""")

  CreateTable_Tags = sql(fmt"""CREATE TABLE IF NOT EXISTS {TableName_Tags} (
    {KeyName_Tags_Id}            INTEGER   PRIMARY KEY AUTOINCREMENT,
    {KeyName_Tags_Name}          TEXT      NOT NULL UNIQUE
  )""")

  CreateTable_BookmarkTags = sql(fmt"""CREATE TABLE IF NOT EXISTS {TableName_BookmarkTags} (
    {KeyName_BookmarkTags_BookmarkId}   INTEGER,
    {KeyName_BookmarkTags_TagId}        INTEGER,

    PRIMARY KEY ({KeyName_BookmarkTags_BookmarkId}, {KeyName_BookmarkTags_TagId}),

    FOREIGN KEY ({KeyName_BookmarkTags_BookmarkId})
        REFERENCES {TableName_Bookmarks} ({KeyName_Bookmarks_Id})
         ON DELETE CASCADE
         ON UPDATE NO ACTION,

    FOREIGN KEY ({KeyName_BookmarkTags_TagId})
      REFERENCES {TableName_Tags} ({KeyName_Tags_Id})
         ON DELETE NO ACTION
         ON UPDATE NO ACTION
  )""")

  InsertTable_Bookmarks = sql(fmt"""INSERT INTO {TableName_Bookmarks} ({KeyName_Bookmarks_Name}, {KeyName_Bookmarks_Url}) VALUES (?, ?)""")
  InsertTable_Tags = sql(fmt"""INSERT INTO {TableName_Tags} ({KeyName_Tags_Name}) VALUES (?)""")
  InsertTable_BookmarkTags = sql(fmt"""INSERT INTO {TableName_BookmarkTags} ({KeyName_BookmarkTags_BookmarkId}, {KeyName_BookmarkTags_TagId}) VALUES (?, ?)""")

  SelectIdentifier_Bookmarks_Name = sql(fmt"""SELECT {KeyName_Bookmarks_Id} FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Name} IS (?)""")
  SelectIdentifier_Bookmarks_Url = sql(fmt"""SELECT {KeyName_Bookmarks_Id} FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Url} IS (?)""")
  SelectIdentifier_Tags = sql(fmt"""SELECT {KeyName_Tags_Id} FROM {TableName_Tags} WHERE {KeyName_Tags_Name} IS (?)""")
  SelectIdentifier_BookmarkTags_Bookmark = sql(fmt"""SELECT {KeyName_BookmarkTags_TagId} FROM {TableName_BookmarkTags} WHERE {KeyName_BookmarkTags_BookmarkId} IS (?)""")
  SelectIdentifier_BookmarkTags_Tag = sql(fmt"""SELECT {KeyName_BookmarkTags_BookmarkId} FROM {TableName_BookmarkTags} WHERE {KeyName_BookmarkTags_TagId} IS (?)""")

  SelectLatestIdentifier_Bookmarks = sql(fmt"""SELECT seq FROM sqlite_sequence WHERE name='{TableName_Bookmarks}'""")
  SelectLatestIdentifier_Tags = sql(fmt"""SELECT seq FROM sqlite_sequence WHERE name='{TableName_Tags}'""")

  GetAll_Bookmarks = sql(fmt"""SELECT {KeyName_Bookmarks_Id},{KeyName_Bookmarks_Name},{KeyName_Bookmarks_Url} FROM {TableName_Bookmarks}""")
  GetObject_Bookmarks_Id = sql(fmt"""SELECT {KeyName_Bookmarks_Id},{KeyName_Bookmarks_Name},{KeyName_Bookmarks_Url} FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Id} IS (?)""")
  GetObject_Bookmarks_Name = sql(fmt"""SELECT {KeyName_Bookmarks_Id},{KeyName_Bookmarks_Name},{KeyName_Bookmarks_Url} FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Name} IS (?)""")
  GetObject_Bookmarks_Url = sql(fmt"""SELECT {KeyName_Bookmarks_Id},{KeyName_Bookmarks_Name},{KeyName_Bookmarks_Url} FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Url} IS (?)""")
  GetAll_Tags = sql(fmt"""SELECT {KeyName_Tags_Id},{KeyName_Tags_Name} FROM {TableName_Tags}""")
  GetObject_Tags = sql(fmt"""SELECT {KeyName_Tags_Id},{KeyName_Tags_Name} FROM {TableName_Tags} WHERE {KeyName_Tags_Name} IS (?)""")
  GetObject_Tags_Id = sql(fmt"""SELECT {KeyName_Tags_Name} FROM {TableName_Tags} WHERE {KeyName_Tags_Id} IS (?)""")

  DeleteObject_Bookmarks = sql(fmt"""DELETE FROM {TableName_Bookmarks} WHERE {KeyName_Bookmarks_Id} IS (?)""")
  DeleteObject_Tags = sql(fmt"""DELETE FROM {TableName_Tags} WHERE {KeyName_Tags_Id} IS (?)""")
  Delete_BookmarkTags_Bookmark = sql(fmt"""DELETE FROM {TableName_BookmarkTags} WHERE {KeyName_BookmarkTags_BookmarkId} IS (?)""")
  Delete_BookmarkTags_Tag = sql(fmt"""DELETE FROM {TableName_BookmarkTags} WHERE {KeyName_BookmarkTags_TagId} IS (?)""")

#[

  === Finished ===

  CREATE TABLE IF NOT EXISTS bookmarks (
    identifier  INTEGER   PRIMARY KEY AUTOINCREMENT,
    name        TEXT      NOT NULL UNIQUE,
    url         TEXT      NOT NULL UNIQUE
  );

  CREATE TABLE IF NOT EXISTS tags (
    identifier    INTEGER   PRIMARY KEY AUTOINCREMENT,
    name          TEXT      NOT NULL UNIQUE
  );

  CREATE TABLE IF NOT EXISTS bookmark_tags (
    bookmark_identifier   INTEGER,
    tag_identifier        INTEGER,
    
    PRIMARY KEY (bookmark_identifier, tag_identifier),

    FOREIGN KEY (bookmark_identifier) 
      REFERENCES bookmarks (identifier) 
         ON DELETE CASCADE 
         ON UPDATE NO ACTION,

    FOREIGN KEY (tag_identifier) 
      REFERENCES tags (identifier) 
         ON DELETE NO ACTION 
         ON UPDATE NO ACTION  
  )

  SELECT id FROM bookmarks WHERE name IS "";
  SELECT tag_id FROM bookmark_tags WHERE bookmark_id IN ();
  SELECT name FROM tags WHERE id IN ();


  SELECT id FROM tags WHERE name IS "";
  SELECT bookmark_id FROM bookmark_tags WHERE tag_id IN ();
  SELECT id,name,url FROM bookmarks WHERE id IN ();
]#


#[

  === Unfinished ===

  CREATE TABLE IF NOT EXISTS timestamps (
    identifier    INTEGER   PRIMARY KEY AUTOINCREMENT,
    created       BLOB      NOT NULL,
    modified      BLOB      NOT NULL

  )

  CREATE TABLE IF NOT EXISTS bookmark_timestamps (
    bookmark_identifier     INTEGER,
    timestamp_identifier    INTEGER,

    PRIMARY KEY (bookmark_identifier, timestamp_identifier),

    FOREIGN KEY (bookmark_identifier)
      REFERENCES bookmarks (identifier)
        ON DELETE CASCADE
        ON UPDATE 
  )


  CREATE TRIGGER IF NOT EXISTS update_bookmark_entry UPDATE OF * ON bookmarks

]#

# =========
# Functions
# =========

#
#
proc initDatabase*(config: Configuration): DbConn =
  let db_path = config.dbPath()
  result = open(db_path, "", "", "")
  let created_table_bookmarks = result.tryExec(CreateTable_Bookmarks)
  let created_table_tags = result.tryExec(CreateTable_Tags)
  let created_table_bookmarktags = result.tryExec(CreateTable_BookmarkTags)

#
#
proc findTag*(db: DbConn, name: string): Tag =
  let row = db.getRow(GetObject_Tags, name)
  result = newTag(row[0], row[1])

#
#
proc findBookmarkById*[T: string|int64|int](db: DbConn, id: T): Bookmark =
  let entity = db.getRow(GetObject_Bookmarks_Id, id)
  result = newBookmark(entity[0], entity[1], entity[2])
  for row in db.rows(SelectIdentifier_BookmarkTags_Bookmark, result.id):
    let tag_name = db.getValue(GetObject_Tags_Id, row[0])
    let tag = newTag(row[0],  tag_name)
    result.tags.add(tag)
#
#
proc findBookmarkByName*(db: DbConn, name: string): Bookmark =
  let entity = db.getRow(GetObject_Bookmarks_Name, name)
  result = newBookmark(entity[0], entity[1], entity[2])
  for row in db.rows(SelectIdentifier_BookmarkTags_Bookmark, result.id):
    let tag_name = db.getValue(GetObject_Tags_Id, row[0])
    let tag = newTag(row[0],  tag_name)
    result.tags.add(tag)

#
#
proc findBookmarkByUrl*(db: DbConn, url: string): Bookmark =
  let entity = db.getRow(GetObject_Bookmarks_Url, url)
  result = newBookmark(entity[0], entity[1], entity[2])
  for row in db.rows(SelectIdentifier_BookmarkTags_Bookmark, result.id):
    let tag_name = db.getValue(GetObject_Tags_Id, row[0])
    let tag = newTag(row[0],  tag_name)
    result.tags.add(tag)

#
#
proc findBookmarksByTag*(db: DbConn, name: string): seq[Bookmark] =
  let tag = db.findTag(name)
  for row in db.rows(SelectIdentifier_BookmarkTags_Tag, tag.id):
    result.add(db.findBookmarkById(row[0]))

#
#
proc findBookmarksByAttributes*(db: DbConn, attributes: StringTableRef): seq[Bookmark] =
  let has_name = attributes.hasKey("name")
  let has_url = attributes.hasKey("url")
  let has_tag = attributes.hasKey("tag")
  # Available Attibutes: Name
  if has_name and not has_url and not has_tag:
    result = @[db.findBookmarkByName(attributes["name"])]
  # Available Attibutes: Url
  if not has_name and has_url and not has_tag:
    result = @[db.findBookmarkByUrl(attributes["url"])]
  # Available Attibutes: Tag
  if not has_name and not has_url and has_tag:
    result = db.findBookmarksByTag(attributes["tag"])
  # Available Attibutes: Name, Url
  if has_name and has_url and not has_tag:
    discard
  # Available Attibutes: Name, Tag
  if has_name and not has_url and has_tag:
    discard
  # Available Attibutes: Name, Url, Tag
  if has_name and has_url and has_tag:
    discard
  # Available Attibutes: Url, Tag
  if not has_name and has_url and has_tag:
    discard


#
#
proc insertEntry*(db: DbConn, bookmark: Bookmark): bool =
  let bookmark_id = db.tryInsertID(InsertTable_Bookmarks, bookmark.name, bookmark.url)

  for tag in bookmark.tags:
    let id_str = db.getValue(SelectIdentifier_Tags, tag.name)
    var tag_id: int64
    discard parseInt(id_str, cast[var int](tag_id))
    if tag_id == 0:
      tag_id = db.tryInsertID(InsertTable_Tags, tag)
    result = db.tryExec(InsertTable_BookmarkTags, bookmark_id, tag_id)
    if not result:
      error(fmt"failed to link bookmark: {bookmark_id} to tag: {tag_id}")

#
#
proc getNextBookmarkId*(db: DbConn): int64 =
  let bookmark_id = db.getValue(SelectLatestIdentifier_Bookmarks)
  discard parseInt(bookmark_id, cast[var int](result))
  result += 1

#
#
proc getNextTagId*(db: DbConn): int64 =
  let tag_id = db.getValue(SelectLatestIdentifier_Tags)
  discard parseInt(tag_id, cast[var int](result))
  result += 1

#
#
iterator listTags*(db: DbConn): Tag =
  for row in db.rows(GetAll_Tags):
    yield newTag(row[0], row[1])

#
#
iterator listBookmarks*(db: DbConn): Bookmark =
  for row in db.rows(GetAll_Bookmarks):
    var bookmark = newBookmark(row[0], row[1], row[2])
    for row in db.rows(SelectIdentifier_BookmarkTags_Bookmark, bookmark.id):
      let tag_name = db.getValue(GetObject_Tags_Id, row[0])
      let tag = newTag(row[0],  tag_name)
      bookmark.tags.add(tag)
    yield bookmark
