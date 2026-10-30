#!/usr/bin/env python3
"""Conversion tracker with Core3 account login and admin-reviewed testing."""
import argparse
from contextvars import ContextVar
import hashlib
import hmac
import ssl
import time
from accounts import GameAccounts, Unavailable, configure
import workflow
import views
from contextlib import contextmanager
from datetime import datetime, timezone
from html import escape
from http.cookies import SimpleCookie, CookieError
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
from pathlib import Path
import secrets
import sqlite3
from urllib.parse import parse_qs

ROOT = Path(__file__).resolve().parent
DB = ROOT / 'private' / 'tracker.sqlite3'
STATES = ('Planned', 'In progress', 'Ready to test', 'Needs fixes', 'Verified')
FIELDS = ('title', 'planet', 'category', 'behavior', 'dependencies', 'source_refs',
          'change_refs', 'test_steps', 'notes')
LABELS = dict(title='Title', planet='Planet / area', category='Content type',
              behavior='Intended behavior / acceptance criteria',
              dependencies='Dependencies / blockers', source_refs='Source references',
              change_refs='Implementation / change references',
              test_steps='In-game test steps', notes='Notes / approved adaptations')
TOKEN = secrets.token_urlsafe(32)
CSRF = ContextVar("csrf", default=TOKEN)
USER = ContextVar("user", default=None)
ACCOUNTS = GameAccounts()


def now():
    return datetime.now(timezone.utc).isoformat(timespec='seconds')


@contextmanager
def connect():
    db = sqlite3.connect(DB, timeout=15)
    db.row_factory = sqlite3.Row
    db.execute('PRAGMA foreign_keys=ON')
    try:
        with db:
            yield db
    finally:
        db.close()


def initialize():
    DB.parent.mkdir(mode=0o700, exist_ok=True)
    # Never silently initialize an unknown existing database.
    with connect() as db:
        version = db.execute('PRAGMA user_version').fetchone()[0]
        tables = db.execute("SELECT name FROM sqlite_master WHERE type='table'").fetchall()
        if version not in (1, 2) and (version != 0 or tables):
            raise RuntimeError('Unknown tracker schema; preserve the database and inspect it first.')
        if version in (1, 2):
            return
        db.executescript('''
            CREATE TABLE items (
                id INTEGER PRIMARY KEY,
                title TEXT NOT NULL, planet TEXT NOT NULL, category TEXT NOT NULL,
                status TEXT NOT NULL CHECK(status IN
                    ('Planned','In progress','Ready to test','Needs fixes','Verified')),
                behavior TEXT NOT NULL, dependencies TEXT NOT NULL,
                source_refs TEXT NOT NULL, change_refs TEXT NOT NULL,
                test_steps TEXT NOT NULL, notes TEXT NOT NULL,
                revision INTEGER NOT NULL DEFAULT 1,
                created TEXT NOT NULL, updated TEXT NOT NULL);
            CREATE TABLE revisions (
                item_id INTEGER NOT NULL REFERENCES items(id),
                revision INTEGER NOT NULL, recorded TEXT NOT NULL,
                snapshot TEXT NOT NULL, PRIMARY KEY(item_id, revision));
            CREATE TABLE results (
                id INTEGER PRIMARY KEY, item_id INTEGER NOT NULL REFERENCES items(id),
                item_revision INTEGER NOT NULL, tester TEXT NOT NULL,
                tested_at TEXT NOT NULL, submitted_at TEXT NOT NULL,
                build TEXT NOT NULL, outcome TEXT NOT NULL CHECK(outcome IN ('Pass','Fail')),
                complete_scope INTEGER NOT NULL CHECK(complete_scope IN (0,1)),
                comments TEXT NOT NULL,
                FOREIGN KEY(item_id, item_revision) REFERENCES revisions(item_id, revision));
            CREATE TRIGGER preserve_results_update BEFORE UPDATE ON results
                BEGIN SELECT RAISE(ABORT, 'Test results are append-only'); END;
            CREATE TRIGGER preserve_results_delete BEFORE DELETE ON results
                BEGIN SELECT RAISE(ABORT, 'Test results are append-only'); END;
            CREATE TRIGGER preserve_revisions_update BEFORE UPDATE ON revisions
                BEGIN SELECT RAISE(ABORT, 'Revision history is append-only'); END;
            CREATE TRIGGER preserve_revisions_delete BEFORE DELETE ON revisions
                BEGIN SELECT RAISE(ABORT, 'Revision history is append-only'); END;
            PRAGMA user_version=1;
        ''')
    DB.chmod(0o600)


def remember(db, item_id):
    row = db.execute('SELECT * FROM items WHERE id=?', (item_id,)).fetchone()
    db.execute('INSERT INTO revisions VALUES (?,?,?,?)',
               (item_id, row['revision'], now(), json.dumps(dict(row))))


def h(value):
    return escape(str(value), quote=True)


def block(value):
    return '<div class="prose">' + h(value or '—') + '</div>'


def hidden(name, value):
    return f'<input type="hidden" name="{h(name)}" value="{h(value)}">'


def form_start(action):
    return f'<form method="post" action="{h(action)}">' + hidden('csrf', CSRF.get())


def options(values, selected):
    return ''.join(f'<option value="{h(v)}" {"selected" if v == selected else ""}>{h(v)}</option>' for v in values)


def layout(title, body):
    user = USER.get()
    navigation = ('<nav><a href="/">Items</a><a href="/bugs">Bug reports</a>'
                  + ('<a href="/reviews">Admin review</a>' if workflow.is_admin(user) else '')
                  + '<span>' + h(user['username']) + (' · Admin' if workflow.is_admin(user) else '') + '</span>'
                  + form_start('/logout') + '<button>Log out</button></form></nav>') if user else '<nav><a href="/login">Log in</a><a href="/register">Register game account</a></nav>'
    return f'''<!doctype html><html lang="en"><head><meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>{h(title)} · SWG Conversion</title><link rel="stylesheet" href="/style.css"></head>
    <body><header><a href="/">SWG <strong>Conversion tracker</strong></a>
    <span>One playable slice at a time</span></header><main>{navigation}{body}</main>
    <footer>Admin-reviewed in-game evidence · Test results describe the exact revision tested · Dates stored in UTC</footer></body></html>'''


def item_form(item=None):
    item = dict(item) if item else {**dict.fromkeys(FIELDS, ''), 'status': 'Planned'}
    editing = 'id' in item
    body = '<a href="/">← All items</a><h1>' + ('Edit item' if editing else 'New conversion item') + '</h1>'
    body += '<p>Describe one independently testable change. Keep fixes on this item.</p>'
    body += form_start(f'/items/{item["id"]}/edit' if editing else '/items/new')
    if editing:
        body += hidden('revision', item['revision'])
    for name in FIELDS:
        required = name in ('title', 'planet', 'category', 'behavior')
        body += f'<label for="{name}">{LABELS[name]}{" *" if required else ""}</label>'
        if name in ('title', 'planet', 'category'):
            body += f'<input id="{name}" name="{name}" maxlength="200" value="{h(item[name])}" {"required" if required else ""}>'
        else:
            if name == 'test_steps':
                body += '<p class="hint">One step per line, including the expected result. The detail page numbers them.</p>'
            body += f'<textarea id="{name}" name="{name}" rows="4" maxlength="20000" {"required" if required else ""}>{h(item[name])}</textarea>'
    selected = 'Ready to test' if item['status'] == 'Verified' else item['status']
    body += '<label for="status">Status</label><select id="status" name="status">' + options(STATES[:-1], selected) + '</select>'
    body += '<p class="hint">Ready to test requires test steps and a change reference. Verified requires a complete passing in-game result. Editing a verified item requires retesting.</p>'
    body += '<button>Save item</button></form>'
    return body


def listing(db, query):
    filters = {k: query.get(k, [''])[0][:200] for k in ('q', 'planet', 'category', 'status')}
    where, args = [], []
    if filters['q']:
        where.append('(title LIKE ? OR behavior LIKE ? OR CAST(id AS TEXT)=?)')
        args.extend(('%' + filters['q'] + '%', '%' + filters['q'] + '%', filters['q']))
    for field in ('planet', 'category', 'status'):
        if filters[field]:
            where.append(field + '=?')
            args.append(filters[field])
    rows = db.execute('SELECT * FROM items' + (' WHERE ' + ' AND '.join(where) if where else '') + ' ORDER BY updated DESC,id DESC', args).fetchall()
    body = '<div class="heading"><div><h1>Conversion items</h1><p>Choose a bounded change. Follow its tests. Keep the evidence.</p></div>' + ('<a class="button" href="/items/new">+ New item</a>' if workflow.is_admin(USER.get()) else '') + '</div>'
    body += '<nav><a href="/">All items</a><a href="/?status=Ready+to+test">Ready to test</a><a href="/?status=Needs+fixes">Needs fixes</a></nav>'
    body += '<form method="get" class="filters"><label>Search<input name="q" placeholder="ID, title or behavior" value="' + h(filters['q']) + '"></label>'
    for field, label in (('planet', 'Planet / area'), ('category', 'Type'), ('status', 'Status')):
        vals = STATES if field == 'status' else [r[0] for r in db.execute(f'SELECT DISTINCT {field} FROM items ORDER BY {field}')]
        body += f'<label>{label}<select name="{field}"><option value="">All</option>{options(vals, filters[field])}</select></label>'
    body += '<button>Filter</button></form>'
    body += f'<p class="hint">{len(rows)} item(s)</p><div class="table-wrap"><table><thead><tr><th>ID / title</th><th>Planet / area</th><th>Type</th><th>Status</th></tr></thead><tbody>'
    for row in rows:
        body += f'<tr><td><a href="/items/{row["id"]}">#{row["id"]} {h(row["title"])}</a></td><td>{h(row["planet"])}</td><td>{h(row["category"])}</td><td><span class="badge">{h(row["status"])}</span></td></tr>'
    body += '</tbody></table></div>'
    if not rows:
        body += '<section><h2>No matching items</h2><p>Create a meaningful conversion item when its scope is selected. No gameplay work has been pre-populated.</p></section>'
    return body


def detail(db, item):
    iid = item['id']
    body = f'<a href="/">← All items</a><div class="heading"><div><p class="hint">#{iid} · {h(item["planet"])} · {h(item["category"])}</p><h1>{h(item["title"])}</h1></div>{edit_link(iid)}</div>'
    body += f'<p><span class="badge">{h(item["status"])}</span> · Revision {item["revision"]}</p>'
    for field in ('behavior', 'dependencies', 'source_refs', 'change_refs'):
        body += f'<section><h2>{LABELS[field]}</h2>{block(item[field])}</section>'
    linked_bugs = db.execute("SELECT b.id,b.title FROM bugs b JOIN bug_reviews r ON r.bug_id=b.id WHERE r.item_id=? AND r.decision='Approved'", (iid,)).fetchall()
    if linked_bugs:
        body += '<section><h2>Approved bug reports</h2>' + ''.join(f'<p><a href="/bugs/{b["id"]}">#{b["id"]} {h(b["title"])}</a> — original reproduction steps and observations</p>' for b in linked_bugs) + '</section>'
    steps = [line.strip() for line in item['test_steps'].splitlines() if line.strip()]
    body += '<section><h2>In-game test steps and expected results</h2>'
    body += '<ol>' + ''.join('<li>' + h(s) + '</li>' for s in steps) + '</ol>' if steps else '<p>No test steps recorded yet.</p>'
    body += '</section><section><h2>Notes / approved adaptations</h2>' + block(item['notes']) + '</section>'
    if item['status'] in ('Ready to test', 'Verified'):
        body += '<section><h2>Record an in-game test result</h2><p>Only record testing actually performed. Requirements remain unchanged.</p>'
        body += form_start(f'/items/{iid}/results') + hidden('revision', item['revision'])
        body += '<p>Submitting as <strong>' + h(USER.get()['username']) + '</strong></p>'
        for name, label, kind in (('tested_at', 'Test date / time (UTC)', 'datetime-local'), ('build', 'Tested build / Git revision', 'text')):
            body += f'<label for="{name}">{label}</label><input id="{name}" name="{name}" type="{kind}" maxlength="200" required>'
        body += '<label for="outcome">Outcome</label><select id="outcome" name="outcome"><option>Fail</option><option>Pass</option></select>'
        body += '<label class="check"><input type="checkbox" name="complete_scope" value="yes"> I tested every acceptance criterion and required dependency in-game.</label>'
        body += '<label for="comments">Comments / observed results / limitations</label><textarea id="comments" name="comments" rows="4" maxlength="20000" required></textarea>'
        body += '<p class="hint">Results remain pending until an admin reviews them. Only an approved complete Pass can mark this revision Verified. Approved Fail marks it Needs fixes. Results cannot be edited or deleted.</p><button>Record result</button></form></section>'
    else:
        body += '<p>Testing opens when an admin marks this item Ready to test. You can <a href="/bugs/new">report a bug</a> now.</p>'
    body += '<section><h2>Test history</h2>'
    results = db.execute('SELECT * FROM results WHERE item_id=? ORDER BY id DESC', (iid,)).fetchall()
    for result in results:
        review = db.execute('SELECT * FROM result_reviews WHERE result_id=?', (result['id'],)).fetchone()
        review_text = ('<p><strong>' + h(review['decision']) + '</strong> by ' + h(review['reviewer']) + ' · ' + h(review['reviewed_at']) + '</p>' + block(review['comments'])) if review else '<p><strong>Pending admin review</strong></p>'
        body += f'<article><h3>{h(result["outcome"])} · {h(result["tester"])} · revision {result["item_revision"]}</h3><p class="hint">Tested {h(result["tested_at"])} · build {h(result["build"])} · {"Complete scope" if result["complete_scope"] else "Partial scope"} · submitted {h(result["submitted_at"])}</p>{block(result["comments"])}{review_text}</article>'
    if not results:
        body += '<p>No in-game results recorded.</p>'
    body += '</section><section><h2>Item history</h2><p class="hint">Previous requirements and notes are preserved for each revision.</p>'
    for revision in db.execute('SELECT * FROM revisions WHERE item_id=? ORDER BY revision DESC', (iid,)):
        snap = json.loads(revision['snapshot'])
        body += f'<details><summary>Revision {revision["revision"]} · {h(revision["recorded"])} · {h(snap["status"])}</summary>'
        for field in FIELDS:
            body += f'<h3>{LABELS[field]}</h3>{block(snap[field])}'
        body += '</details>'
    return body + '</section>'


def edit_link(iid):
    return f'<a class="button" href="/items/{iid}/edit">Edit item</a>' if workflow.is_admin(USER.get()) else ''


class Handler(BaseHTTPRequestHandler):
    def setup(self):
        super().setup()
        self.connection.settimeout(20)
        self.cookie_header = None
        self.user = None
        self.session_hash = None

    def send_page(self, status, title, body):
        self.respond(status, layout(title, body).encode(), 'text/html; charset=utf-8')

    def respond(self, status, data, content_type, location=None):
        self.send_response(status)
        self.send_header('Content-Type', content_type)
        self.send_header('Content-Length', str(len(data)))
        self.send_header('Cache-Control', 'no-store')
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('Referrer-Policy', 'same-origin')
        self.send_header('Content-Security-Policy', "default-src 'none'; style-src 'self'; form-action 'self'; base-uri 'none'; frame-ancestors 'none'")
        secure = '; Secure' if isinstance(self.connection, ssl.SSLSocket) else ''
        self.send_header('Set-Cookie', f'tracker_csrf={CSRF.get()}; HttpOnly; SameSite=Strict; Path=/{secure}')
        if self.cookie_header:
            self.send_header('Set-Cookie', self.cookie_header + secure)
        if location:
            self.send_header('Location', location)
        self.end_headers()
        self.wfile.write(data)

    def redirect(self, path):
        self.respond(303, b'', 'text/plain', path)

    def valid_host(self):
        return self.headers.get('Host') in self.server.allowed_hosts

    def load_user(self):
        USER.set(None)
        CSRF.set(TOKEN)
        cookies = SimpleCookie(self.headers.get('Cookie', ''))
        cookie = cookies.get('tracker_session')
        if not cookie or len(cookie.value) > 100:
            return
        token_hash = workflow.digest(cookie.value)
        with connect() as db:
            session = db.execute('SELECT * FROM sessions WHERE token_hash=? AND expires>?', (token_hash, time.time())).fetchone()
        if session:
            user = ACCOUNTS.current(session['account_id'])
            if user and hmac.compare_digest(session['credential_stamp'], workflow.credential_stamp(user)):
                self.user = user
                self.session_hash = token_hash
                USER.set(user)
                CSRF.set(session['csrf'])

    def require_user(self, admin=False):
        if not self.user:
            raise PermissionError('Log in with your game account first.')
        if admin and not workflow.is_admin(self.user):
            raise PermissionError('Administrator access required.')

    def do_GET(self):
        try:
            if not self.valid_host():
                raise PermissionError('Use the configured tracker address.')
            self.load_user()
            path, _, query = self.path.partition('?')
            if path == '/style.css':
                return self.respond(200, (ROOT / 'style.css').read_bytes(), 'text/css; charset=utf-8')
            if path in ('/login', '/register'):
                if self.user:
                    return self.redirect('/')
                body = views.account_form(path[1:], form_start)
                try:
                    ACCOUNTS.find(username='')
                except Unavailable:
                    body = '<p class="notice"><strong>Game database connection needs attention.</strong> Login and registration are unavailable until an administrator updates the private connection settings.</p>' + body
                if path == '/login' and parse_qs(query).get('registered') == ['1']:
                    body = '<p class="notice">Game account created and active. You can log in now.</p>' + body
                return self.send_page(200, path[1:].title(), body)
            if not self.user:
                return self.redirect('/login')
            with connect() as db:
                if path == '/':
                    return self.send_page(200, 'Items', listing(db, parse_qs(query)))
                if path == '/items/new':
                    self.require_user(admin=True)
                    return self.send_page(200, 'New item', item_form())
                if path == '/bugs':
                    return self.send_page(200, 'Bug reports', views.bugs(db, self.user, h))
                if path == '/bugs/new':
                    return self.send_page(200, 'Report a bug', views.bug_form(form_start))
                if path == '/reviews':
                    self.require_user(admin=True)
                    return self.send_page(200, 'Admin review', views.reviews(db, h, block, form_start, hidden))
                parts = path.strip('/').split('/')
                if len(parts) == 2 and parts[0] == 'bugs' and parts[1].isdigit():
                    bug = db.execute('SELECT * FROM bugs WHERE id=?', (int(parts[1]),)).fetchone()
                    if bug:
                        approved = db.execute("SELECT 1 FROM bug_reviews WHERE bug_id=? AND decision='Approved'", (bug['id'],)).fetchone()
                        if not workflow.is_admin(self.user) and bug['author_id'] != self.user['id'] and not approved:
                            raise PermissionError('This report is awaiting admin review.')
                        return self.send_page(200, bug['title'], views.bug_detail(db, bug, h, block))
                if len(parts) in (2, 3) and parts[0] == 'items' and parts[1].isdigit():
                    row = db.execute('SELECT * FROM items WHERE id=?', (int(parts[1]),)).fetchone()
                    if row and (len(parts) == 2 or parts[2] == 'edit'):
                        if len(parts) == 3:
                            self.require_user(admin=True)
                        return self.send_page(200, row['title'], detail(db, row) if len(parts) == 2 else item_form(row))
            self.send_page(404, 'Not found', '<h1>Not found</h1><a href="/">All items</a>')
        except PermissionError as exc:
            self.send_page(403, 'Access denied', '<h1>Access denied</h1>' + block(str(exc)))
        except Unavailable as exc:
            self.send_page(503, 'Accounts unavailable', '<h1>Game accounts unavailable</h1>' + block(str(exc)))
        except (ValueError, CookieError):
            self.send_page(400, 'Invalid request', '<h1>Invalid request</h1>')
        except sqlite3.Error:
            self.send_page(500, 'Storage error', '<h1>Unable to read tracker storage.</h1>')

    def do_POST(self):
        try:
            if not self.valid_host():
                raise PermissionError('Use the configured tracker address.')
            self.load_user()
            size = int(self.headers.get('Content-Length', '0'))
            if not 0 < size <= 250000 or self.headers.get_content_type() != 'application/x-www-form-urlencoded':
                raise ValueError('Expected a form smaller than 250 KB.')
            data = {k: (v[0] if k in ('password', 'confirmation') else v[0].strip())
                    for k, v in parse_qs(self.rfile.read(size).decode(), keep_blank_values=True, max_num_fields=50).items()}
            cookies = SimpleCookie(self.headers.get('Cookie', ''))
            if not hmac.compare_digest(data.get('csrf', ''), CSRF.get()) or 'tracker_csrf' not in cookies or not hmac.compare_digest(cookies['tracker_csrf'].value, CSRF.get()):
                raise PermissionError('Form expired. Reload the page before submitting.')
            origin = self.headers.get('Origin')
            scheme = 'https' if isinstance(self.connection, ssl.SSLSocket) else 'http'
            if origin and origin != scheme + '://' + self.headers['Host']:
                raise PermissionError('Cross-origin form submission rejected.')
            if any(len(v) > 20000 for v in data.values()):
                raise ValueError('A field exceeds 20,000 characters.')
            path = self.path
            if path in ('/login', '/register'):
                if self.user:
                    return self.redirect('/')
                username, password = data.get('username', ''), data.get('password', '')
                with connect() as db:
                    db.execute('BEGIN IMMEDIATE')
                    allowed = workflow.limit(db, path + ':ip:' + self.client_address[0], 40 if path == '/login' else 5, 900 if path == '/login' else 3600)
                    if path == '/login':
                        allowed = workflow.limit(db, 'login:name:' + username.casefold(), 10, 900) and allowed
                if not allowed:
                    return self.send_page(429, 'Please wait', '<h1>Too many attempts</h1><p>Try again later.</p>')
                if not username or len(username) > 32 or not password or len(password) > 256:
                    raise ValueError('Enter a valid username and password.')
                if path == '/register':
                    ACCOUNTS.register(username, password, data.get('confirmation', ''))
                    with connect() as db:
                        workflow.audit(db, {'id': None, 'username': username}, 'Game account registered')
                    return self.redirect('/login?registered=1')
                user = ACCOUNTS.authenticate(username, password)
                if not user:
                    return self.send_page(401, 'Login failed', '<h1>Login failed</h1><p>Username/password is incorrect, or this game account is inactive or banned.</p><a href="/login">Try again</a>')
                with connect() as db:
                    token = workflow.new_session(db, user)
                    workflow.audit(db, user, 'Logged in')
                self.cookie_header = f'tracker_session={token}; HttpOnly; SameSite=Strict; Path=/; Max-Age=28800'
                return self.redirect('/')
            self.require_user()
            if path == '/logout':
                with connect() as db:
                    db.execute('DELETE FROM sessions WHERE token_hash=?', (self.session_hash,))
                self.cookie_header = 'tracker_session=; HttpOnly; SameSite=Strict; Path=/; Max-Age=0'
                return self.redirect('/login')
            parts = path.strip('/').split('/')
            with connect() as db:
                db.execute('BEGIN IMMEDIATE')
                if parts == ['items', 'new']:
                    self.require_user(admin=True)
                    values = self.validate_item(data)
                    stamp = now()
                    cursor = db.execute(f'INSERT INTO items ({",".join(FIELDS)},status,created,updated) VALUES ({",".join("?" for _ in range(len(FIELDS)+3))})', (*values, data['status'], stamp, stamp))
                    iid = cursor.lastrowid
                    remember(db, iid)
                    workflow.audit(db, self.user, 'Created item', iid)
                    target = f'/items/{iid}'
                elif len(parts) == 3 and parts[0] == 'items' and parts[1].isdigit() and parts[2] in ('edit', 'results'):
                    if parts[2] == 'edit':
                        self.require_user(admin=True)
                    iid = int(parts[1])
                    row = db.execute('SELECT * FROM items WHERE id=?', (iid,)).fetchone()
                    if not row:
                        raise ValueError('Item not found.')
                    if str(row['revision']) != data.get('revision'):
                        return self.send_page(409, 'Item changed', f'<h1>Item changed while this form was open</h1><p>Nothing was saved. Copy your text before reloading.</p><a href="/items/{iid}">Reload current item</a>')
                    if parts[2] == 'edit':
                        values = self.validate_item(data)
                        db.execute(f'UPDATE items SET {",".join(f"{f}=?" for f in FIELDS)},status=?,revision=revision+1,updated=? WHERE id=?', (*values, data['status'], now(), iid))
                        remember(db, iid)
                        workflow.audit(db, self.user, 'Edited item; earlier test approvals do not verify this revision', iid)
                    else:
                        data['tester'] = self.user['username']
                        rid = self.add_result(db, row, data)
                        db.execute('INSERT INTO result_authors VALUES(?,?)', (rid, self.user['id']))
                        workflow.audit(db, self.user, 'Submitted test for review', iid, rid)
                    target = f'/items/{iid}'
                elif parts == ['bugs', 'new']:
                    target = self.submit_bug(db, data)
                elif len(parts) == 3 and parts[0] == 'reviews' and parts[1] in ('results', 'bugs') and parts[2].isdigit():
                    self.require_user(admin=True)
                    record_id = int(parts[2])
                    if parts[1] == 'results':
                        workflow.review_result(db, self.user, record_id, data.get('decision'), data.get('comments', ''), data.get('revision'), remember)
                    else:
                        self.review_bug(db, record_id, data)
                    target = '/reviews'
                else:
                    raise ValueError('Unknown form action.')
            self.redirect(target)
        except PermissionError as exc:
            self.send_page(403, 'Access denied', '<h1>Access denied</h1>' + block(str(exc)))
        except (ValueError, UnicodeError, CookieError) as exc:
            self.send_page(400, 'Check form', '<h1>Check the form</h1>' + block(str(exc)) + '<p>Use your browser’s Back button to correct the form.</p>')
        except Unavailable as exc:
            self.send_page(503, 'Game accounts unavailable', '<h1>Game accounts unavailable</h1>' + block(str(exc)))
        except sqlite3.Error:
            self.send_page(500, 'Storage error', '<h1>Unable to save tracker data</h1><p>Preserve your text and check database access and free space. If registering a game account, try logging in before retrying registration.</p>')

    def submit_bug(self, db, data):
        fields = ('title', 'category', 'location', 'description', 'steps', 'expected', 'actual', 'build')
        if any(not data.get(f) for f in fields):
            raise ValueError('Complete all required bug report fields.')
        if any(len(data[f]) > 200 for f in ('title', 'category', 'location', 'build')):
            raise ValueError('Bug title, category, location and build must be 200 characters or fewer.')
        iid = self.optional_item(db, data.get('item_id'))
        cursor = db.execute(f'INSERT INTO bugs(author_id,author,{",".join(fields)},item_id,created) VALUES({",".join("?" for _ in range(len(fields)+4))})',
                            (self.user['id'], self.user['username'], *(data[f] for f in fields), iid, now()))
        workflow.audit(db, self.user, 'Submitted bug for review', iid, cursor.lastrowid)
        return f'/bugs/{cursor.lastrowid}'

    @staticmethod
    def optional_item(db, value):
        if not value:
            return None
        if not value.isdigit() or len(value) > 15 or not db.execute('SELECT 1 FROM items WHERE id=?', (int(value),)).fetchone():
            raise ValueError('Related conversion item does not exist.')
        return int(value)

    def review_bug(self, db, bug_id, data):
        decision, comments = data.get('decision'), data.get('comments', '')
        if decision not in ('Approved', 'Rejected') or not comments:
            raise ValueError('Choose Approve or Reject and explain the decision.')
        bug = db.execute('SELECT * FROM bugs WHERE id=?', (bug_id,)).fetchone()
        if not bug or db.execute('SELECT 1 FROM bug_reviews WHERE bug_id=?', (bug_id,)).fetchone():
            raise ValueError('Bug not found or already reviewed.')
        iid = None
        if decision == 'Approved':
            iid = self.optional_item(db, data.get('item_id'))
            if not iid:
                values = dict.fromkeys(FIELDS, '')
                values.update(title=bug['title'], planet=bug['location'], category=bug['category'], behavior=bug['expected'],
                              dependencies='Investigate source, target and dependencies before implementation.',
                              test_steps=f'Follow the full reproduction steps in approved bug #{bug_id} (linked on this item). Expected: the intended behavior / acceptance criteria above are met.',
                              notes=f'Approved bug #{bug_id}; see the linked original report and admin decision for full details.\nNext action: investigate the reported issue and define final fix-specific acceptance tests before marking Ready to test.')
                cursor = db.execute(f'INSERT INTO items ({",".join(FIELDS)},status,created,updated) VALUES ({",".join("?" for _ in range(len(FIELDS)+3))})',
                                    (*(values[f] for f in FIELDS), 'Planned', now(), now()))
                iid = cursor.lastrowid
                remember(db, iid)
        db.execute('INSERT INTO bug_reviews(bug_id,decision,reviewer_id,reviewer,reviewed_at,comments,item_id) VALUES(?,?,?,?,?,?,?)',
                   (bug_id, decision, self.user['id'], self.user['username'], now(), comments, iid))
        workflow.audit(db, self.user, 'Bug ' + decision.lower(), iid, bug_id, comments)

    @staticmethod
    def validate_item(data):
        for field in ('title', 'planet', 'category', 'behavior'):
            if not data.get(field):
                raise ValueError(LABELS[field] + ' is required.')
        if any(len(data.get(f, '')) > 200 for f in ('title', 'planet', 'category')):
            raise ValueError('Title, planet and type must be 200 characters or fewer.')
        if data.get('status') not in STATES[:-1]:
            raise ValueError('Verified is set only by a complete passing in-game result.')
        if data['status'] == 'Ready to test' and (not data.get('test_steps') or not data.get('change_refs')):
            raise ValueError('Ready to test requires in-game test steps and an implementation/change reference.')
        return tuple(data.get(f, '') for f in FIELDS)

    @staticmethod
    def add_result(db, row, data):
        for field in ('tester', 'tested_at', 'build', 'comments'):
            if not data.get(field):
                raise ValueError('Tester, test date, build/revision and comments are required.')
        if len(data['tester']) > 200 or len(data['build']) > 200:
            raise ValueError('Tester and build must be 200 characters or fewer.')
        tested = datetime.fromisoformat(data['tested_at'])
        if tested.tzinfo is None:
            tested = tested.replace(tzinfo=timezone.utc)
        if tested > datetime.now(timezone.utc):
            raise ValueError('Test date cannot be in the future.')
        if data.get('outcome') not in ('Pass', 'Fail'):
            raise ValueError('Choose Pass or Fail.')
        complete = data.get('complete_scope') == 'yes'
        if row['status'] not in ('Ready to test', 'Verified'):
            raise ValueError('This item is not ready for testing. Report a bug or wait for the admin to mark it Ready to test.')
        cursor = db.execute('INSERT INTO results (item_id,item_revision,tester,tested_at,submitted_at,build,outcome,complete_scope,comments) VALUES (?,?,?,?,?,?,?,?,?)',
                   (row['id'], row['revision'], data['tester'], tested.astimezone(timezone.utc).isoformat(timespec='seconds'), now(), data['build'], data['outcome'], int(complete), data['comments']))
        return cursor.lastrowid


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--port', type=int, default=8765)
    parser.add_argument('--configure-game', metavar='CONFIG_LUA', help='Copy literal DB settings from a current-repository config into private/game.json; never overwrite it')
    parser.add_argument('--bind', default='127.0.0.1')
    parser.add_argument('--public-host', help='Exact browser Host header when listening beyond localhost, including port')
    parser.add_argument('--tls-cert')
    parser.add_argument('--tls-key')
    args = parser.parse_args()
    if args.configure_game:
        configure(args.configure_game)
        print('Private game connection configured. No game accounts changed.')
        return
    if args.bind != '127.0.0.1' and not (args.public_host and args.tls_cert and args.tls_key):
        parser.error('A non-loopback listener requires --public-host, --tls-cert and --tls-key.')
    if bool(args.tls_cert) != bool(args.tls_key):
        parser.error('Supply both --tls-cert and --tls-key.')
    initialize()
    workflow.migrate(connect, DB)
    server = ThreadingHTTPServer((args.bind, args.port), Handler)
    server.allowed_hosts = {f'127.0.0.1:{server.server_port}', f'localhost:{server.server_port}'}
    if args.public_host:
        server.allowed_hosts.add(args.public_host)
    if args.tls_cert:
        context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
        context.minimum_version = ssl.TLSVersion.TLSv1_2
        context.load_cert_chain(args.tls_cert, args.tls_key)
        server.socket = context.wrap_socket(server.socket, server_side=True)
    scheme = 'https' if args.tls_cert else 'http'
    print(f'Conversion tracker: {scheme}://{args.public_host or ("127.0.0.1:" + str(server.server_port))}', flush=True)
    print('Game-account login required. Ctrl+C to stop.', flush=True)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == '__main__':
    main()
