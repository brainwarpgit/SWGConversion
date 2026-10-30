"""Tracker schema migration, authenticated sessions and review decisions."""
from datetime import datetime, timezone
import hashlib
import json
import secrets
import time


def migrate(connect, database):
    with connect() as db:
        version = db.execute('PRAGMA user_version').fetchone()[0]
        if version == 2:
            return
        if version != 1:
            raise RuntimeError('Unsupported tracker schema.')
        backup = database.with_name('pre-auth-' + str(time.time_ns()) + '.sqlite3')
        import sqlite3
        with sqlite3.connect(backup) as target:
            db.backup(target)
        backup.chmod(0o600)
        statements = [
            '''CREATE TABLE sessions(token_hash TEXT PRIMARY KEY,account_id INTEGER NOT NULL,
                credential_stamp TEXT NOT NULL,csrf TEXT NOT NULL,expires REAL NOT NULL)''',
            '''CREATE TABLE throttle(key TEXT PRIMARY KEY, count INTEGER NOT NULL,until REAL NOT NULL)''',
            '''CREATE TABLE result_reviews(id INTEGER PRIMARY KEY,result_id INTEGER UNIQUE NOT NULL REFERENCES results(id),
                decision TEXT NOT NULL CHECK(decision IN ('Approved','Rejected')),reviewer_id INTEGER NOT NULL,
                reviewer TEXT NOT NULL,reviewed_at TEXT NOT NULL,comments TEXT NOT NULL)''',
            '''CREATE TABLE result_authors(result_id INTEGER PRIMARY KEY REFERENCES results(id),account_id INTEGER NOT NULL)''',
            '''CREATE TABLE bugs(id INTEGER PRIMARY KEY,author_id INTEGER NOT NULL,author TEXT NOT NULL,
                title TEXT NOT NULL,category TEXT NOT NULL,location TEXT NOT NULL,description TEXT NOT NULL,
                steps TEXT NOT NULL,expected TEXT NOT NULL,actual TEXT NOT NULL,build TEXT NOT NULL,
                item_id INTEGER REFERENCES items(id),created TEXT NOT NULL)''',
            '''CREATE TABLE bug_reviews(id INTEGER PRIMARY KEY,bug_id INTEGER UNIQUE NOT NULL REFERENCES bugs(id),
                decision TEXT NOT NULL CHECK(decision IN ('Approved','Rejected')),reviewer_id INTEGER NOT NULL,
                reviewer TEXT NOT NULL,reviewed_at TEXT NOT NULL,comments TEXT NOT NULL,item_id INTEGER REFERENCES items(id))''',
            '''CREATE TABLE audit(id INTEGER PRIMARY KEY,actor_id INTEGER,actor TEXT NOT NULL,
                action TEXT NOT NULL,item_id INTEGER,record_id INTEGER,recorded TEXT NOT NULL,details TEXT NOT NULL)''',
        ]
        db.execute('BEGIN IMMEDIATE')
        for statement in statements:
            db.execute(statement)
        for table in ('result_reviews', 'result_authors', 'bugs', 'bug_reviews', 'audit'):
            for action in ('UPDATE', 'DELETE'):
                db.execute(f'''CREATE TRIGGER preserve_{table}_{action.lower()} BEFORE {action} ON {table}
                    BEGIN SELECT RAISE(ABORT, 'Review and submission history is append-only'); END''')
        # Anonymous legacy passes are retained as evidence, never grandfathered in
        # as approved completion. Preserve earlier snapshots/results unchanged.
        for row in db.execute("SELECT * FROM items WHERE status='Verified'").fetchall():
            db.execute("UPDATE items SET status='Ready to test',revision=revision+1,updated=? WHERE id=?", (stamp(), row['id']))
            updated = db.execute('SELECT * FROM items WHERE id=?', (row['id'],)).fetchone()
            db.execute('INSERT INTO revisions VALUES (?,?,?,?)', (row['id'], updated['revision'], stamp(), json.dumps(dict(updated))))
            audit(db, None, 'Legacy verification requires admin review', row['id'])
        db.execute('PRAGMA user_version=2')


def stamp():
    return datetime.now(timezone.utc).isoformat(timespec='seconds')


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


def credential_stamp(account):
    return digest(account['password'] + ':' + (account['salt'] or ''))


def audit(db, user, action, item_id=None, record_id=None, details=''):
    db.execute('INSERT INTO audit(actor_id,actor,action,item_id,record_id,recorded,details) VALUES(?,?,?,?,?,?,?)',
               (user['id'] if user else None, user['username'] if user else 'migration', action, item_id, record_id, stamp(), details))


def is_admin(user):
    return bool(user and int(user['admin_level']) == 15)


def new_session(db, user):
    token = secrets.token_urlsafe(32)
    db.execute('DELETE FROM sessions WHERE expires<?', (time.time(),))
    db.execute('INSERT INTO sessions VALUES (?,?,?,?,?)',
               (digest(token), user['id'], credential_stamp(user), secrets.token_urlsafe(32), time.time()+8*3600))
    return token


def limit(db, key, maximum, seconds):
    key = digest(key)
    current = time.time()
    db.execute('DELETE FROM throttle WHERE until<?', (current,))
    row = db.execute('SELECT count FROM throttle WHERE key=?', (key,)).fetchone()
    if row and row['count'] >= maximum:
        return False
    db.execute('INSERT INTO throttle VALUES(?,1,?) ON CONFLICT(key) DO UPDATE SET count=count+1', (key, current+seconds))
    return True


def review_result(db, user, result_id, decision, comments, expected_revision, remember):
    if not is_admin(user):
        raise PermissionError('Administrator access required.')
    if decision not in ('Approved', 'Rejected') or not comments.strip():
        raise ValueError('Choose Approve or Reject and explain the decision.')
    result = db.execute('SELECT * FROM results WHERE id=?', (result_id,)).fetchone()
    if not result:
        raise ValueError('Result not found.')
    if db.execute('SELECT 1 FROM result_reviews WHERE result_id=?', (result_id,)).fetchone():
        raise ValueError('This result has already been reviewed.')
    item = db.execute('SELECT * FROM items WHERE id=?', (result['item_id'],)).fetchone()
    if str(item['revision']) != str(expected_revision):
        raise ValueError('Item changed while the review was open. Reload and review the current revision.')
    status = item['status']
    if decision == 'Approved':
        if result['item_revision'] != item['revision']:
            raise ValueError('This evidence tests an older item revision. Reject it or request a new test of the current revision.')
        if result['outcome'] == 'Fail':
            status = 'Needs fixes'
        elif result['complete_scope']:
            if status not in ('Ready to test', 'Verified'):
                raise ValueError('A complete Pass can verify only an implemented item marked Ready to test.')
            status = 'Verified'
    db.execute('INSERT INTO result_reviews(result_id,decision,reviewer_id,reviewer,reviewed_at,comments) VALUES(?,?,?,?,?,?)',
               (result_id, decision, user['id'], user['username'], stamp(), comments))
    if status != item['status']:
        db.execute('UPDATE items SET status=?,revision=revision+1,updated=? WHERE id=?', (status, stamp(), item['id']))
        remember(db, item['id'])
    audit(db, user, 'Test result ' + decision.lower(), item['id'], result_id, comments)
