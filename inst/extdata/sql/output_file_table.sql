PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE `output_files` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `file_basename` TEXT,
  `file_dir` TEXT,
  `file_size` TEXT,
  `file_mtime` TEXT,
  `key` TEXT
);
COMMIT;
