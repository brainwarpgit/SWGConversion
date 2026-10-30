# Conversion tracker

Repository-local browser tracker with Core3 game-account login. Python 3.10+ and the
installed `mariadb` command-line client are required; no Python packages are needed.
There is no separate tracker account/password database.

## Connection setup

The tracker reads **only** `conversion-tracker/private/game.json` for its game database
connection. This ignored file contains secrets; keep permissions at 0600 and the private
directory at 0700. Do not paste its contents into chat, logs or Git.

For a current-repository config with simple literal DB assignments, initialize it once:

```sh
python3 conversion-tracker/app.py --configure-game MMOCoreORB/bin/conf/config-local.lua
```

This copies DBHost, DBPort, DBName, DBUser, DBPass and DBSecret without executing Lua.
It refuses to overwrite an existing file or read a source outside this repository.
It does not evaluate includes or config-local.lua overrides. Ensure that the copied
values match the **running game server**, particularly DBSecret. Use config.lua instead
only if the server has no local configuration. Adjust the ignored
JSON file locally if the running configuration differs. Fields are `host`, `port`,
`database`, `user`, `password`, `secret` and `registration_enabled` (boolean).
No connection password appears in command-line arguments or application error messages.

The game database user needs SELECT on `accounts` and `account_bans`. Registration
also needs INSERT and LOCK TABLES on `accounts`, with the SELECT privilege needed for
its duplicate check. A dedicated database user with these limited privileges is preferred;
creating that user is an operator action. The tracker does not change existing account
passwords, grants, game schemas or admin levels. It uses TCP; keep the database local or
on a protected connection. Do not use an unencrypted database connection over the Internet.

Only active, unbanned game accounts can log in. Current account activity, bans, password
fingerprint and admin level are checked on every authenticated request. Password reset,
deactivation, ban or session expiry invalidates access. Admin level **exactly 15** grants
tracker administration. All other accounts are regular users. There is no first-user
admin escalation or default admin password; use an existing game administrator.
If the game database has no accounts yet, register your own account in the browser,
then have the server operator explicitly grant that account game admin level 15.
Registration itself always creates a regular account and cannot grant admin access.

The adapter matches `MMOCoreORB/src/server/login/account/AccountManager.cpp`: salted
SHA256(DBSecret + password + salt), or legacy SHA1(password) when salt is empty. It never
upgrades or changes existing hashes. Account bans follow the active expiry check in
`AccountImplementation.cpp`. External SWGRealms authentication is not supported by this
adapter; use it only with the inspected local Core3 accounts schema.

## Start and browser access

```sh
python3 conversion-tracker/app.py
```

Open [http://127.0.0.1:8765](http://127.0.0.1:8765). Leave the command running; Ctrl+C
stops it. `--port 8766` selects another port. It does not automatically start on login.
The default listener is local only. For another computer, forward through SSH:

```sh
ssh -N -L 8765:127.0.0.1:8765 YOUR_USER@YOUR_SERVER
```

Then open that localhost address on the other computer. Use matching forwarded/server
port numbers. Local HTTP is for loopback/SSH only. Session cookies are HttpOnly and
SameSite=Strict; HTTPS also sets Secure. Sessions expire after eight hours. Logout
revokes the server-side session. Login and registration are rate-limited in SQLite
(40 login attempts/IP/15 minutes, 10/username/15 minutes, 5 registrations/IP/hour).
Forms use session-specific CSRF protection; cross-origin POSTs and unknown Hosts fail.

For direct LAN access, supply a trusted TLS certificate and private key and an explicit
browser host, for example (replace these paths and hostname with your actual values):

```sh
python3 conversion-tracker/app.py --bind 0.0.0.0 --port 8765 \
  --public-host tracker.example.test:8765 \
  --tls-cert /absolute/path/to/certificate.pem \
  --tls-key /absolute/path/to/private-key.pem
```

A non-loopback listener is refused without TLS and an explicit host. Do not bypass
certificate validation. No LAN/public listener, certificate, DNS or firewall change is
set up automatically. Python's built-in server is intended for a small trusted server
community, not unrestricted Internet traffic; agree an Internet deployment separately.

## Registration and AutoReg

The login page links to **Register game account**. Browser registrations create active
game accounts immediately, with admin_level 0, a random station ID and a 32-character
random salt. No admin approval is required for registration. `registration_enabled`
can disable this form's write operation. Existing users use their existing accounts.

New usernames allow 3–32 ASCII letters, digits or underscores; passwords require
10–64 printable ASCII characters and confirmation for compatibility with the game's
ASCII login packet. Password whitespace is preserved. Passwords are never stored in
tracker SQLite, forms/history or application logs. MariaDB receives only the salted
hash. The stock accounts table lacks a unique username index and uses MyISAM, so the
adapter locks the table across duplicate checking and insertion. Existing duplicate
usernames are rejected for login rather than selecting an arbitrary account.

**Before disabling game autoregistration:** verify the connection and DBSecret, register
a real account through the browser, log into the tracker, and have the user confirm
game login with that account. Only then set `AutoReg = 0` in the effective Core3 config
(prefer your local override) and apply it using your normal server restart workflow.
The tracker does not change config.lua or start/restart Core3. If the live database
connection has not been verified, do not assume browser registration is operational.

## Roles and review

- Regular users can browse/filter items, read tests, submit in-game Pass/Fail evidence
  for Ready to test/Verified items, and submit bug reports. Identity comes from their
  authenticated game account, never a submitted tester-name field.
- Only admins can create/edit conversion items, move them to Ready to test, or approve
  or reject test evidence and bug reports. These rules are enforced on each endpoint.
- Every test result, including an admin's own result, enters **Pending admin review**.
  Submission alone changes neither completion nor item status. An admin records a
  decision and comments in Admin review. Only an approved complete-scope Pass for the
  exact current item revision can mark Verified. Approved Fail marks Needs fixes;
  approved partial Pass leaves status unchanged. Rejection leaves status unchanged.
- Approvals of stale evidence are refused. After edits, submit a fresh test against
  the current item revision; prior evidence and decisions remain visible. Duplicate
  reviews are refused. Review history is append-only.
- Bug reports preserve title, category, location, build, description, reproduction
  steps and expected/actual behavior. Authors can see their own pending/rejected
  reports; admins see all; other users see approved reports.
- When approving a bug, link an existing item to avoid duplicate work. If no item is
  supplied, approval creates one **Planned** item from the report, with investigation
  as the next action. Approval alone does not mark it implemented, ready or verified.
  Admins investigate/fix it and mark Ready to test before users submit test evidence.
  A bug's linked item's status tracks progress; there is no duplicate completion flag.

## Item workflow

Use one record per independently testable change. Keep ordinary fixes and notes on
that record. The five item statuses remain Planned, In progress, Ready to test, Needs
fixes and Verified. Admins cannot select Verified directly in the item editor.

Each item contains planet/area, type, intended behavior/acceptance criteria, dependencies,
source and change references, notes/adaptations and tests. Write one test step per line
including the expected result; the detail page numbers the steps. Ready to test requires
test instructions and a change reference. Notes should state remaining issues and the
next concrete action. Test evidence requires actual UTC test time, build/revision,
outcome, comments and whether the entire acceptance scope was observed in-game.

Search by ID/title/behavior; filter by planet, type or status. Requirements and detail
history stay off the main list. Every item edit preserves a snapshot and invalidates
previous verification. Stale edit/submission forms fail instead of overwriting changes.
Dependencies are plain text: admins must manually reopen affected items when a related
change invalidates tests. No gameplay items are pre-populated.

## Storage, migration and backup

All tracker records, sessions, rate limits and audit history live in the ignored
`private/tracker.sqlite3`. Secrets and game-account hashes never go in that database;
sessions store a one-way credential fingerprint so password changes revoke access.
No account credentials or sessions are imported from elsewhere. No old repository is
read by this application.

Schema 1 upgrades once to schema 2, preserving items, original results and snapshots.
Before migration, an SQLite online backup is saved as `private/pre-auth-*.sqlite3`.
Old anonymous Verified items return to Ready to test because their results were not
admin-reviewed. Their original verification history remains preserved. Unknown schemas
are refused. The current repository's initial tracker contained zero items/results.

Back up the private directory securely. For a simple consistent copy, stop the tracker,
copy the database and connection configuration to secure storage, then restart. Restore
only while stopped and preserve the displaced files first. Source code in Git is not a
backup of the database. Private connection files and backups contain secrets and must
not be shared publicly. No delete endpoints exist; requirements/results/bug reports,
review decisions and audit records cannot be overwritten through the application.

## Validation boundary

Isolated HTTP/MariaDB/SQLite checks exercise tracker registration, roles and review
behavior. They do not establish live game connectivity, compatibility with a differently
configured server, actual game login, or any in-game conversion result. No Core3 build,
restart, gameplay conversion, TRE rebuild or commit is performed by this tracker.
