-- Backup the emailLog table before updating
-- Exporting the table to a SQL file allows you to restore the data if needed.
-- Example: Use the following command to export the emailLog table to a SQL file.
-- mysqldump -u [username] -p [database_name] emailLog > emailLog_backup.sql;

UPDATE emailLog
SET subject = TO_BASE64(subject);

UPDATE emailLog
SET password = TO_BASE64(password);

UPDATE emailLog
SET passwordClue = TO_BASE64(passwordClue);