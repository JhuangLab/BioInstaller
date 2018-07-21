PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE `upload_data` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `file_name` TEXT,
  `file_path` TEXT,
  `file_size` TEXT,
  `file_type` TEXT,
  `genome_version` TEXT,
  `upload_time` TEXT,
  `md5` TEXT,
  `description` TEXT
);
COMMIT;
