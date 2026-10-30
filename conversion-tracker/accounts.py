"""Core3 account adapter using the installed MariaDB client; never executes Lua."""
import hashlib
import hmac
import json
import os
from pathlib import Path
import re
import secrets
import subprocess

ROOT = Path(__file__).resolve().parent
CONFIG = ROOT / 'private' / 'game.json'


class Unavailable(RuntimeError):
    pass


def literal(value):
    # Input data is a UTF-8 hex literal, never SQL syntax or shell text.
    return "CONVERT(X'%s' USING utf8mb4)" % str(value).encode('utf-8').hex()


class GameAccounts:
    def __init__(self, path=CONFIG):
        self.path = path

    def settings(self):
        try:
            cfg = json.loads(self.path.read_text())
            if not all(k in cfg for k in ('host', 'port', 'database', 'user', 'password', 'secret')):
                raise ValueError()
            return cfg
        except (OSError, ValueError):
            raise Unavailable('Game account connection is not configured. See the tracker README.') from None

    def query(self, sql):
        cfg = self.settings()
        env = {**os.environ, 'MYSQL_PWD': cfg['password']}
        command = ['mariadb', '--no-defaults', '--protocol=TCP', '--connect-timeout=5',
                   '--host', str(cfg['host']), '--port', str(int(cfg['port'])),
                   '--user', str(cfg['user']), '--database', str(cfg['database']),
                   '--default-character-set=utf8mb4', '--batch', '--raw', '--skip-column-names']
        try:
            result = subprocess.run(command, input=sql, text=True, capture_output=True,
                                    env=env, timeout=10, check=False)
        except (OSError, subprocess.TimeoutExpired):
            raise Unavailable('Game account database is unavailable; no tracker login or registration was completed.') from None
        if result.returncode:
            # Never return SQL, stderr, credentials or hashes to a browser/log.
            raise Unavailable('Game account database request failed. Check connection, schema and database privileges.')
        try:
            return [json.loads(line) for line in result.stdout.splitlines() if line.strip()]
        except ValueError:
            raise Unavailable('Unexpected game database response.') from None

    def find(self, *, username=None, account_id=None):
        where = 'a.username=' + literal(username) if username is not None else 'a.account_id=' + str(int(account_id))
        rows = self.query("SELECT JSON_OBJECT('id',a.account_id,'username',a.username,"
                          "'password',a.password,'salt',a.salt,'active',a.active,'admin_level',a.admin_level,"
                          "'banned',EXISTS(SELECT 1 FROM account_bans b WHERE b.account_id=a.account_id "
                          "AND b.expires>UNIX_TIMESTAMP())) FROM accounts a WHERE " + where + ' LIMIT 2;')
        if len(rows) > 1:
            raise Unavailable('Duplicate game username found; an administrator must resolve it before login.')
        return rows[0] if rows else None

    def authenticate(self, username, password):
        row = self.find(username=username)
        if not row or not row['active'] or row['banned']:
            return None
        salt = row['salt'] or ''
        digest = (hashlib.sha256((self.settings()['secret'] + password + salt).encode()).hexdigest()
                  if salt else hashlib.sha1(password.encode()).hexdigest())
        return row if hmac.compare_digest(digest, row['password']) else None

    def current(self, account_id):
        row = self.find(account_id=account_id)
        return row if row and row['active'] and not row['banned'] else None

    def register(self, username, password, confirmation):
        if not re.fullmatch(r'[A-Za-z0-9_]{3,32}', username):
            raise ValueError('Username must be 3–32 ASCII letters, numbers or underscores.')
        if not 10 <= len(password) <= 64 or not password.isascii() or any(ord(c) < 32 or ord(c) > 126 for c in password):
            raise ValueError('Password must contain 10–64 printable ASCII characters for game-client compatibility.')
        if password != confirmation:
            raise ValueError('Passwords do not match.')
        cfg = self.settings()
        if not cfg.get('registration_enabled', False):
            raise ValueError('Browser game-account registration is disabled.')
        salt = secrets.token_hex(16)  # accounts.salt is varchar(32)
        digest = hashlib.sha256((cfg['secret'] + password + salt).encode()).hexdigest()
        # The stock schema has no unique username index and uses MyISAM. Hold the
        # table lock through the duplicate check and insertion, including other clients.
        rows = self.query('LOCK TABLES accounts WRITE; '
                          'SET @tracker_exists=(SELECT COUNT(*) FROM accounts WHERE username=' + literal(username) + '); '
                          'INSERT INTO accounts(username,password,station_id,salt,active,admin_level) '
                          f'SELECT {literal(username)},{literal(digest)},{secrets.randbelow(2**31)},'
                          f'{literal(salt)},1,0 WHERE @tracker_exists=0; '
                          "SELECT JSON_OBJECT('created',ROW_COUNT()); UNLOCK TABLES;")
        if not rows or rows[0]['created'] != 1:
            raise ValueError('That username is unavailable. Choose another or log in to your existing account.')


def configure(source):
    repo = ROOT.parent.resolve()
    source = Path(source).resolve()
    if not source.is_relative_to(repo):
        raise ValueError('Configuration source must be inside the current repository.')
    text = source.read_text()
    cfg = {}
    for key, target in [('DBHost','host'), ('DBPort','port'), ('DBName','database'),
                        ('DBUser','user'), ('DBPass','password'), ('DBSecret','secret')]:
        pattern = rf'^\s*{key}\s*=\s*(?:"([^"\\]*)"|\x27([^\x27\\]*)\x27|(\d+))\s*[,;]?\s*(?:--[^\n]*)?$'
        matches = re.findall(pattern, text, flags=re.M)
        if len(matches) != 1:
            raise ValueError(f'{key} must have one simple literal assignment; configure private/game.json manually for overrides.')
        parts = matches[0]
        cfg[target] = int(parts[2]) if parts[2] else parts[0] or parts[1]
    cfg['registration_enabled'] = True
    CONFIG.parent.mkdir(mode=0o700, exist_ok=True)
    # Refuse to overwrite a configured connection.
    fd = os.open(CONFIG, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    with os.fdopen(fd, 'w') as handle:
        json.dump(cfg, handle, indent=2)
        handle.write('\n')
