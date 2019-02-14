/* Direct export in JSON */
/* Return each table line as a different JSON record */
/* Column 3 values contains non unicode characters that are replaced by (empty) */
SELECT JSON_OBJECT(primaryKey-value VALUE (
  JSON_OBJECT('col1-name' VALUE col1-name,
    'col2-name' VALUE col2-name,
    'col3-name' VALUE REGEXP_REPLACE(col3-name, UNISTR('[\FFFF-\DBFF\DFFF]'), ''))
  )) AS JSON
FROM table-name;

/* Other JSON export format */
/* Return all table lines as single JSON object with multiple records (one for each line) */
/* use RETURNING CLOB parameter to overwrite VARCHAR limitation to 4000 chars */
SELECT JSON_OBJECTAGG(primaryKey-value VALUE (
  JSON_OBJECT('col1-name' VALUE col1-name,
    'col2-name' VALUE col2-name,
    'col3-name' VALUE REGEXP_REPLACE(col3-name, UNISTR('[\FFFF-\DBFF\DFFF]'), ''))
  ) RETURNING CLOB) AS JSON
FROM table-name;
