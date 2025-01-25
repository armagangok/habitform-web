const _activeAllDebugMode = false;

abstract final class KDebug {
  // enables debug mode for print
  static const debugModeEnabled = _activeAllDebugMode;

  static const rateDebugMode = _activeAllDebugMode;
}


// Sitemap: https://www.hurriyet.com.tr/sitemaps/newssitemap.xml
// User-agent:*
// Disallow: /ad/
// Disallow: /api/
// Disallow: /arkadasimamektup/
// Disallow: /okurtemsilcisi/
// Disallow: /widgets/
// Disallow: /_includes/
// Disallow: /_othernews/
// Disallow: /_test/
// Disallow: /_includescms/
// Disallow: /arama/

// User-agent: Flipboard
// User-agent: FlipboardProxy
// Allow: /api/

// User-agent: GPTBot
// Disallow: /