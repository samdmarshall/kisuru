
# =======
# Imports
# =======

import db_sqlite
import strformat

#import tomepkg/config
import "config.nim"

# ===============
# Internal Layout
# ===============

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
proc initDatabase*(config: Configuration) =
  let db_path = config.dbPath()
  let db = open(db_path, "", "", "")
