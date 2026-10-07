"""Offline D1-shaped host: only the harness's temporary SQLite database.

This is not a D1 emulator/certification. It exercises real example WASM and
managed JSPI glue with SQL rows; the existing adapter/live suites remain separate.
"""
import json
import sqlite3
import sys

request = json.load(sys.stdin)
with sqlite3.connect(sys.argv[1]) as connection:
    connection.row_factory = sqlite3.Row
    if request.get("schema") is not None:
        connection.executescript(request["schema"])
        result = {}
    else:
        before = connection.total_changes
        cursor = connection.execute(request["sql"], request["args"])
        rows = [dict(row) for row in cursor.fetchall()]
        result = {"results": rows, "columns": [column[0] for column in cursor.description or []], "meta": {
            "changes": connection.total_changes - before,
            "last_row_id": cursor.lastrowid or 0,
        }}
print(json.dumps(result))
