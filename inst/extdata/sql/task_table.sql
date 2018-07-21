PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE `task_info` (
  `id` INTEGER PRIMARY KEY AUTOINCREMENT,
  `msgid` REAL,
  `key` TEXT,
  `status` TEXT,
  `log` TEXT
);
COMMIT;
