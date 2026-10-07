-- Application schema only; jobs.Provider initializes its own engine table.
CREATE TABLE IF NOT EXISTS portable_records (id INTEGER PRIMARY KEY, principal TEXT NOT NULL, body TEXT NOT NULL, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS device_reports (id INTEGER PRIMARY KEY, principal TEXT NOT NULL, firmware_version TEXT NOT NULL, hardware_revision TEXT, uptime_seconds INTEGER NOT NULL, error_code INTEGER, created_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS report_deliveries (event_id TEXT PRIMARY KEY, report_id INTEGER NOT NULL, attempt INTEGER NOT NULL);
