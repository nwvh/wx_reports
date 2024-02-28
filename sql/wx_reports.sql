-- If you're not going to use the "Statistics" feature, you don't need to import this, just make sure the option is disabled in the config.

CREATE TABLE IF NOT EXISTS wx_reports (
  admin_identifier varchar(99) COLLATE utf8mb4_bin NOT NULL,
  admin_name varchar(99) COLLATE utf8mb4_bin NOT NULL,
  resolved_reports INT DEFAULT 0,
  replied_reports INT DEFAULT 0,
  PRIMARY KEY (admin_identifier)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;