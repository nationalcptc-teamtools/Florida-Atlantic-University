#!/usr/bin/env python3
"""
vuln-app.py -- deliberately vulnerable local web target for testing the
cptc2026 scripts (web-recon.sh / web-vuln-tests.sh / cptc-web.sh).

*** LOCAL LAB ONLY. Bind to 127.0.0.1, do not expose. ***

Deliberate bugs:
  1  SQLi      GET /search?q=...            (sqlite3 via string concat)
  2  LFI       GET /file?path=...           (arbitrary file read)
  3  XSS       GET /say?name=<script>...    (reflected, no escape)
  4  SSTI      GET /render?tpl={{7*7}}      (user string rendered as Jinja2)
  5  Exposure  /.git/HEAD / /.env / /admin  (should be non-public)
Run: python3 vuln-app.py   ->  http://127.0.0.1:8080
"""
import sqlite3
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs, unquote
from pathlib import Path

PORT = 8080
FAKE_GIT_HEAD = "ref: refs/heads/main\n"
FAKE_ENV = "DB_URL=sqlite:///app.db\nADMIN_KEY=devonly-1234-deleteme\n"[:1024]
ADMIN_TEXT = "Mock Admin Panel v0.1\n(defaults on: admin/admin)\n"
FILES_ROOT = Path(__file__).resolve().parent / "wwwroot"   # LFI anchor

# -- set up a tiny pretend DB ------------------------------------------------
DB = Path(__file__).resolve().parent / "app.db"
def init_db():
    con = sqlite3.connect(DB)
    con.executescript(
        "CREATE TABLE IF NOT EXISTS notes (id INTEGER PRIMARY KEY, author TEXT, note TEXT);"
        "DELETE FROM notes;"
        "INSERT INTO notes VALUES (1,'alice','first note');"
        "INSERT INTO notes VALUES (2,'bob','second note');"
    )
    con.commit()
    con.close()
init_db()

# -- jinja for the SSTI bug (install if missing) ------------------------------
try:
    from jinja2 import Template as JinjaTpl
    HAVE_JINJA = True
except Exception:
    HAVE_JINJA = False

def page(title, body, extra=""):
    return (f"<html><head><title>{title}</title></head><body>"
            f"<h1>{title}</h1>"
            f"{body}{extra}"
            "<ul><li><a href='/search?q=1'>search</a></li>"
            "<li><a href='/file?path=readme.txt'>file</a></li>"
            "<li><a href='/say?name=guest'>say hello</a></li>"
            "<li><a href='/render?tpl=hello'>render</a></li>"
            "</ul></body></html>")

def handle_get(self, url):
    p = urlparse(url)
    q = parse_qs(p.query)
    if p.path == "/":
        return self._send(200, "text", page("Mock CPTC Lab", ""))
    if p.path == "/search":                       # BUG 1: SQLi
        term = unquote((q.get("q", [""])[0]))
        con = sqlite3.connect(DB)
        # deliberately concatenated -- injectable
        try:
            rows = con.execute(f"SELECT id,note FROM notes WHERE note LIKE '%{term}%'").fetchall()
            body = page("Search", f"<p>results for '{term}': {rows}</p>")
        except Exception as exc:
            body = page("Search", f"<p>DB error: {exc}</p>")   # SQL text leaks
        con.close()
        return self._send(200, "text", body)
    if p.path == "/file":                          # BUG 2: LFI
        target = unquote(q.get("path", [""])[0])
        try:
            data = open(Path(FILES_ROOT) / target, "rb").read() if not target.startswith("/") \
                else open(target, "rb").read()
            return self._send(200, "text", data.decode("utf-8", "replace"))
        except Exception as exc:
            return self._send(404, "text", f"no such file: {target} ({exc})")
    if p.path == "/say":                           # BUG 3: XSS
        name = unquote(q.get("name", ["guest"])[0])
        return self._send(200, "text", page("Hello", f"<p>Hello <b>{name}</b>!</p>"))
    if p.path == "/render":                        # BUG 4: SSTI
        tpl = unquote(q.get("tpl", ["hello"])[0])
        try:
            if HAVE_JINJA:
                out = JinjaTpl(tpl).render()
                return self._send(200, "text", page("Render", f"<p>{out}</p>"))
            return self._send(200, "text", "<p>jinja not installed -- install 'pip3 install Jinja2'</p>")
        except Exception as exc:
            return self._send(200, "text", f"<p>template error: {exc}</p>")
    if p.path == "/.git/HEAD":                     # BUG 5a: exposed git
        return self._send(200, "text", FAKE_GIT_HEAD)
    if p.path == "/.env":                          # BUG 5b: exposed env
        return self._send(200, "text", FAKE_ENV)
    if p.path == "/admin":                         # BUG 5c: exposed admin
        return self._send(200, "text", ADMIN_TEXT)
    if p.path == "/robots.txt":
        return self._send(200, "text", "Disallow: /admin\nDisallow: /.env\n")
    return self._send(404, "text", "not here")

class Handler(BaseHTTPRequestHandler):
    server_version = "MockLabServer/1.0"
    sys_version = ""
    x_powered = "PHP/8.2.1 (fake-leak, exercise X-Powered-By finding)"
    def do_GET(self):
        return handle_get(self, self.path)
    def log_message(self, fmt, *args):
        print(f"[req] {self.address_string()} - {fmt % args}")

    def _send(self, code, ctype, data):
        if isinstance(data, str):
            data = data.encode()
        self.send_response(code)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.send_header("X-Powered-By", self.x_powered)      # deliberate info leak
        self.end_headers()
        self.wfile.write(data)

if __name__ == "__main__":
    FilesRoot = FILES_ROOT
    FilesRoot.mkdir(parents=True, exist_ok=True)
    (FilesRoot / "readme.txt").write_text("hello from webroot!\n")
    srv = HTTPServer(("127.0.0.1", PORT), Handler)
    print(f"[+] vulnerable lab app on http://127.0.0.1:{PORT}  (Ctrl-C to stop)")
    print(f"    bugs: /search?q=  /file?path=  /say?name=  /render?tpl=  /.git/HEAD  /.env  /admin")
    srv.serve_forever()
