"""Small server-rendered account, bug and review pages."""
import workflow


def account_form(mode, form_start):
    register = mode == 'register'
    title = 'Register game account' if register else 'Log in'
    body = f'<h1>{title}</h1><p>' + ('Your account activates immediately and works in the game and tracker.' if register else 'Use your existing game username and password.') + '</p>'
    body += form_start('/' + mode)
    body += '<label for="username">Username</label><input id="username" name="username" autocomplete="username" maxlength="32" required>'
    body += '<label for="password">Password</label><input id="password" name="password" type="password" autocomplete="' + ('new-password' if register else 'current-password') + '" maxlength="256" required>'
    if register:
        body += '<p class="hint">Username: 3–32 letters, numbers or underscores. Password: 10–64 printable ASCII characters.</p><label for="confirmation">Confirm password</label><input id="confirmation" name="confirmation" type="password" autocomplete="new-password" maxlength="256" required>'
    return body + f'<button>{title}</button></form>'


def bug_form(form_start):
    body = '<h1>Report a game bug</h1><p>Reports enter admin review. Approval does not imply that a fix has been implemented or tested.</p>' + form_start('/bugs/new')
    for field, label in [('title','Title'),('category','Category'),('location','Planet / location'),('build','Tested game build / revision'),('item_id','Related conversion item ID (optional)')]:
        body += f'<label for="{field}">{label}</label><input id="{field}" name="{field}" maxlength="200" {"required" if field != "item_id" else ""}>'
    for field, label in [('description','Description'),('steps','Steps to reproduce'),('expected','Expected behavior'),('actual','Actual behavior')]:
        body += f'<label for="{field}">{label}</label><textarea id="{field}" name="{field}" rows="4" maxlength="20000" required></textarea>'
    return body + '<button>Submit for admin review</button></form>'


def bugs(db, user, h):
    admin = workflow.is_admin(user)
    rows = db.execute('SELECT b.*,r.decision,r.item_id AS linked_item FROM bugs b LEFT JOIN bug_reviews r ON r.bug_id=b.id ' +
                      ('' if admin else "WHERE b.author_id=? OR r.decision='Approved' ") + 'ORDER BY b.id DESC', () if admin else (user['id'],)).fetchall()
    body = '<div class="heading"><h1>Bug reports</h1><a class="button" href="/bugs/new">Report a bug</a></div><p>Your reports and approved reports are shown here.</p><table><thead><tr><th>Report</th><th>Location</th><th>Review</th><th>Conversion item</th></tr></thead><tbody>'
    for row in rows:
        body += f'<tr><td><a href="/bugs/{row["id"]}">#{row["id"]} {h(row["title"])}</a></td><td>{h(row["location"])}</td><td>{h(row["decision"] or "Pending")}</td><td>' + (f'<a href="/items/{row["linked_item"]}">#{row["linked_item"]}</a>' if row['linked_item'] else '—') + '</td></tr>'
    return body + '</tbody></table>'


def bug_detail(db, bug, h, block):
    body = f'<a href="/bugs">← Bug reports</a><h1>#{bug["id"]} {h(bug["title"])}</h1><p>Submitted by {h(bug["author"])} · {h(bug["created"])}</p>'
    for field, label in [('category','Category'),('location','Location'),('build','Tested build'),('description','Description'),('steps','Reproduction steps'),('expected','Expected behavior'),('actual','Actual behavior')]:
        body += f'<section><h2>{label}</h2>{block(bug[field])}</section>'
    review = db.execute('SELECT * FROM bug_reviews WHERE bug_id=?', (bug['id'],)).fetchone()
    if review:
        body += '<section><h2>' + h(review['decision']) + '</h2><p>Reviewed by ' + h(review['reviewer']) + ' · ' + h(review['reviewed_at']) + '</p>' + block(review['comments'])
        if review['item_id']:
            body += f'<p><a href="/items/{review["item_id"]}">Conversion item #{review["item_id"]}</a> — follow the item status for testing availability.</p>'
        body += '</section>'
    else:
        body += '<p><strong>Pending admin review</strong></p>'
    return body


def reviews(db, h, block, form_start, hidden):
    body = '<h1>Admin review</h1><p>Review original requirements and submitted evidence before confirming completion. Stale evidence cannot verify changed content.</p><h2>Pending test results</h2>'
    rows = db.execute('SELECT r.*,i.title,i.revision AS current_revision FROM results r JOIN items i ON i.id=r.item_id LEFT JOIN result_reviews v ON v.result_id=r.id WHERE v.id IS NULL ORDER BY r.id').fetchall()
    if not rows:
        body += '<p>No pending test results.</p>'
    for row in rows:
        body += f'<article><h3><a href="/items/{row["item_id"]}">#{row["item_id"]} {h(row["title"])}</a> — {h(row["outcome"])}</h3><p>Tester: {h(row["tester"])} · tested {h(row["tested_at"])} · build {h(row["build"])} · tested item revision {row["item_revision"]} / current {row["current_revision"]} · {"Complete scope" if row["complete_scope"] else "Partial scope"}</p>{block(row["comments"])}'
        body += form_start(f'/reviews/results/{row["id"]}') + hidden('revision', row['current_revision'])
        body += '<label>Decision<select name="decision"><option>Rejected</option><option>Approved</option></select></label><label>Review comments<textarea name="comments" required maxlength="20000"></textarea></label><button>Save decision</button></form></article>'
    body += '<h2>Pending bug reports</h2>'
    rows = db.execute('SELECT b.* FROM bugs b LEFT JOIN bug_reviews r ON r.bug_id=b.id WHERE r.id IS NULL ORDER BY b.id').fetchall()
    if not rows:
        body += '<p>No pending bug reports.</p>'
    for row in rows:
        body += f'<article><h3><a href="/bugs/{row["id"]}">Bug #{row["id"]}: {h(row["title"])}</a></h3><p>By {h(row["author"])} · {h(row["location"])}</p>{block(row["description"])}'
        body += form_start(f'/reviews/bugs/{row["id"]}')
        body += '<label>Decision<select name="decision"><option>Rejected</option><option>Approved</option></select></label>'
        body += '<label>Link to existing conversion item ID (blank creates one Planned item on approval)<input name="item_id" inputmode="numeric" value="' + h(row['item_id'] or '') + '"></label>'
        body += '<label>Review comments / next action<textarea name="comments" required maxlength="20000"></textarea></label><button>Save decision</button></form></article>'
    return body
