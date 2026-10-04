import fcntl
import os
from pathlib import Path
import sqlite3
import sys
import tempfile
from contextlib import closing
from datetime import datetime, timezone


def backup_database(source: Path, directory: Path) -> Path:
    os.umask(0o077)
    directory.mkdir(parents=True, exist_ok=True, mode=0o700)
    directory.chmod(0o700)
    with (directory / ".backup.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        descriptor, temporary = tempfile.mkstemp(prefix=".sqlite-backup-", dir=directory)
        os.close(descriptor)
        try:
            with closing(sqlite3.connect(source.resolve().as_uri() + "?mode=ro", uri=True)) as database:
                with closing(sqlite3.connect(temporary)) as snapshot:
                    database.backup(snapshot)
                    if snapshot.execute("PRAGMA integrity_check").fetchall() != [("ok",)]:
                        raise RuntimeError("SQLite backup failed its integrity check")
                    if snapshot.execute("PRAGMA foreign_key_check").fetchone() is not None:
                        raise RuntimeError("SQLite backup contains invalid foreign keys")
            timestamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%S.%fZ")
            destination = directory / f"sqlite-{timestamp}.db"
            os.replace(temporary, destination)
            return destination
        finally:
            Path(temporary).unlink(missing_ok=True)


if __name__ == "__main__":
    source = Path(sys.argv[1] if len(sys.argv) > 1 else "/home/infiniter/services/shift-distributor/data/sqlite.db")
    directory = Path(sys.argv[2] if len(sys.argv) > 2 else "/home/infiniter/services/shift-distributor/data/backups")
    print(backup_database(source, directory))
