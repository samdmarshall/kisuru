
# =======
# Imports
# =======

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

  CreateTable_Bookmarks = sql"""CREATE TABLE IF NOT EXISTS bookmarks (
    id          INTEGER   PRIMARY KEY AUTOINCREMENT,
    name        TEXT      NOT NULL UNIQUE,
    url         TEXT      NOT NULL UNIQUE
  )"""

  CreateTable_Tags = sql"""CREATE TABLE IF NOT EXISTS tags (
    id            INTEGER   PRIMARY KEY AUTOINCREMENT,
    name          TEXT      NOT NULL UNIQUE
  )"""

  CreateTable_BookmarkTags = sql"""CREATE TABLE IF NOT EXISTS bookmark_tags (
    bookmark_id   INTEGER,
    tag_id        INTEGER,

    PRIMARY KEY (bookmark_id, tag_id),

    FOREIGN KEY (bookmark_id)
      REFERENCES bookmarks (id)
         ON DELETE CASCADE
         ON UPDATE NO ACTION,

    FOREIGN KEY (tag_id)
      REFERENCES tags (id)
         ON DELETE NO ACTION
         ON UPDATE NO ACTION
  )"""

  InsertTable_Bookmarks = sql"""INSERT INTO bookmarks (name, url) VALUES (?, ?)"""
  InsertTable_Tags = sql"""INSERT INTO tags (name) VALUES (?)"""
  InsertTable_BookmarkTags = sql"""INSERT INTO bookmark_tags (bookmark_id, tag_id) VALUES (?, ?)"""

  SelectIdentifier_Bookmarks_Name = sql"""SELECT id FROM bookmarks WHERE name IS (?)"""
  SelectIdentifier_Bookmarks_Url = sql"""SELECT id FROM bookmarks WHERE url IS (?)"""
  SelectIdentifier_Tags = sql"""SELECT id FROM tags WHERE name IS (?)"""
  SelectIdentifier_BookmarkTags_Bookmark = sql"""SELECT tag_id FROM bookmark_tags WHERE bookmark_id IS (?)"""
  SelectIdentifier_BookmarkTags_Tag = sql"""SELECT bookmark_id FROM bookmark_tags WHERE tag_id IS (?)"""

  SelectLatestIdentifier_Bookmarks = sql"""SELECT seq FROM sqlite_sequence WHERE name='bookmarks'"""
  SelectLatestIdentifier_Tags = sql"""SELECT seq FROM sqlite_sequence WHERE name='tags'"""

  GetObject_Bookmarks_Id = sql"""SELECT id,name,url FROM bookmarks WHERE id IS (?)"""
  GetObject_Bookmarks_Name = sql"""SELECT id,name,url FROM bookmarks WHERE name IS (?)"""
  GetObject_Bookmarks_Url = sql"""SELECT id,name,url FROM bookmarks WHERE url IS (?)"""
  GetObject_Tags = sql"""SELECT id,name FROM tags WHERE name IS (?)"""

  DeleteObject_Bookmarks = sql"""DELETE FROM bookmarks WHERE id IS (?)"""
  DeleteObject_Tags = sql"""DELETE FROM tags WHERE id IS (?)"""
  Delete_BookmarkTags_Bookmark = sql"""DELETE FROM bookmark_tags WHERE bookmark_id IS (?)"""
  Delete_BookmarkTags_Tag = sql"""DELETE FROM bookmark_tags WHERE tag_id IS (?)"""

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
  for row in db.rows(sql"SELECT tag_id FROM bookmark_tags WHERE bookmark_id IS (?)", result.id):
    let tag_name = db.getValue(sql"SELECT name FROM tags WHERE id IS (?)", row[0])
    let tag = newTag(row[0],  tag_name)
    result.tags.add(tag)
#
#
proc findBookmarkByName*(db: DbConn, name: string): Bookmark =
  let entity = db.getRow(GetObject_Bookmarks_Name, name)
  result = newBookmark(entity[0], entity[1], entity[2])
  for row in db.rows(sql"SELECT tag_id FROM bookmark_tags WHERE bookmark_id IS (?)", result.id):
    let tag_name = db.getValue(sql"SELECT name FROM tags WHERE id IS (?)", row[0])
    let tag = newTag(row[0],  tag_name)
    result.tags.add(tag)

#
#
proc findBookmarkByUrl*(db: DbConn, url: string): Bookmark =
  let entity = db.getRow(GetObject_Bookmarks_Url, url)
  result = newBookmark(entity[0], entity[1], entity[2])
  for row in db.rows(sql"SELECT tag_id FROM bookmark_tags WHERE bookmark_id IS (?)", result.id):
    let tag_name = db.getValue(sql"SELECT name FROM tags WHERE id IS (?)", row[0])
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
proc insertEntry*(db: DbConn, bookmark: Bookmark): bool =
  let bookmark_id = db.tryInsertID(InsertTable_Bookmarks, bookmark.name, bookmark.url)

  for tag in bookmark.tags:
    let id_str = db.getValue(SelectIdentifier_Tags, tag)
    var tag_id: int64
    discard parseInt(id_str, cast[var int](tag_id))
    if tag_id == 0:
      tag_id = db.tryInsertID(InsertTable_Tags, tag)
    result = db.tryExec(InsertTable_BookmarkTags, bookmark_id, tag_id)
    if not result:
      echo fmt"failed to link bookmark: {bookmark_id} to tag: {tag_id}"


#
#
iterator listTags*(db: DbConn): Tag =
  for row in db.rows(sql"SELECT id,name FROM tags"):
    yield newTag(row[0], row[1])

#
#
iterator listBookmarks*(db: DbConn): Bookmark =
  for row in db.rows(sql"SELECT id,name,url FROM bookmarks"):
    var bookmark = newBookmark(row[0], row[1], row[2])
    for row in db.rows(sql"SELECT tag_id FROM bookmark_tags WHERE bookmark_id IS (?)", bookmark.id):
      let tag_name = db.getValue(sql"SELECT name FROM tags WHERE id IS (?)", row[0])
      let tag = newTag(row[0],  tag_name)
      bookmark.tags.add(tag)
    yield bookmark
