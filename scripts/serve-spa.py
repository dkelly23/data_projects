import functools, http.server, os, socketserver, sys
raiz = sys.argv[1]; puerto = int(sys.argv[2])
class H(http.server.SimpleHTTPRequestHandler):
    def send_head(self):
        ruta = self.translate_path(self.path)
        if not os.path.exists(ruta) or os.path.isdir(ruta) and not os.path.exists(os.path.join(ruta,"index.html")):
            self.path = "/index.html"
        return super().send_head()
socketserver.TCPServer.allow_reuse_address = True
with socketserver.TCPServer(("", puerto), functools.partial(H, directory=raiz)) as s:
    s.serve_forever()
