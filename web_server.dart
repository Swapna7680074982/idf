import 'dart:io';

final HttpClient _proxyClient = HttpClient()
  ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);

void main() async {
  final buildDir = Directory('c:/projects/idf_diaspa/build/web');
  if (!buildDir.existsSync()) {
    stderr.writeln('Build directory does not exist: ${buildDir.path}');
    exit(1);
  }

  final server = await HttpServer.bind(InternetAddress.anyIPv4, 8080);
  stdout.writeln('Flutter Web is LIVE with Proxy at: http://localhost:8080');

  final Map<String, String> mimeTypes = {
    'html': 'text/html; charset=utf-8',
    'js': 'application/javascript; charset=utf-8',
    'mjs': 'application/javascript; charset=utf-8',
    'wasm': 'application/wasm',
    'css': 'text/css; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'gif': 'image/gif',
    'svg': 'image/svg+xml',
    'ttf': 'font/ttf',
    'otf': 'font/otf',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
    'ico': 'image/x-icon',
  };

  await for (HttpRequest request in server) {
    try {
      request.response.headers.set('Access-Control-Allow-Origin', '*');
      request.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
      request.response.headers.set('Access-Control-Allow-Headers', '*');

      if (request.method == 'OPTIONS') {
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        continue;
      }

      String path = request.uri.path;

      // PROXY API REQUESTS TO BACKEND SERVER
      if (path.startsWith('/api') || path.startsWith('/health') || path.startsWith('/mdrf_activate')) {
        await _proxyRequest(request);
        continue;
      }

      // STATIC FILES
      if (path == '/' || path.isEmpty) {
        path = '/index.html';
      }

      final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
      File file = File('${buildDir.path}/$normalizedPath');

      // If file doesn't exist, fallback to index.html for Flutter Web client routing
      if (!file.existsSync()) {
        file = File('${buildDir.path}/index.html');
      }

      if (file.existsSync()) {
        final ext = file.path.split('.').last.toLowerCase();
        final mime = mimeTypes[ext] ?? 'application/octet-stream';
        request.response.headers.set(HttpHeaders.contentTypeHeader, mime);
        await request.response.addStream(file.openRead());
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not Found');
      }
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.write('Server Error: $e');
    } finally {
      try {
        await request.response.close();
      } catch (_) {}
    }
  }
}

Future<void> _proxyRequest(HttpRequest clientReq) async {
  String targetPath = clientReq.uri.path;
  if (!targetPath.startsWith('/mdrf_activate')) {
    targetPath = '/mdrf_activate$targetPath';
  }

  final targetUri = Uri(
    scheme: 'https',
    host: 'apps.hhclservices.com',
    path: targetPath,
    queryParameters: clientReq.uri.queryParameters.isNotEmpty ? clientReq.uri.queryParameters : null,
  );

  try {
    final upstreamReq = await _proxyClient.openUrl(clientReq.method, targetUri);

    clientReq.headers.forEach((name, values) {
      final n = name.toLowerCase();
      if (n != 'host' && n != 'content-length' && n != 'connection') {
        for (final val in values) {
          upstreamReq.headers.add(name, val);
        }
      }
    });
    upstreamReq.headers.set('host', 'apps.hhclservices.com');

    await upstreamReq.addStream(clientReq);
    final upstreamRes = await upstreamReq.close();

    clientReq.response.statusCode = upstreamRes.statusCode;

    // Single clean CORS header
    clientReq.response.headers.set('Access-Control-Allow-Origin', '*');
    clientReq.response.headers.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    clientReq.response.headers.set('Access-Control-Allow-Headers', '*');

    upstreamRes.headers.forEach((name, values) {
      final n = name.toLowerCase();
      if (n != 'access-control-allow-origin' &&
          n != 'access-control-allow-methods' &&
          n != 'access-control-allow-headers' &&
          n != 'transfer-encoding' &&
          n != 'connection') {
        for (final val in values) {
          clientReq.response.headers.add(name, val);
        }
      }
    });

    await clientReq.response.addStream(upstreamRes);
  } catch (e) {
    clientReq.response.statusCode = HttpStatus.badGateway;
    clientReq.response.write('Proxy error: $e');
  }
}
