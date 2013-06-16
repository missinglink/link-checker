// Generated by CoffeeScript 1.6.3
(function() {
  var decorateLink, emitLinks, getDecorator, jsLinkFilter, socket;

  socket = io.connect('http://localhost', {
    port: 3000
  });

  jsLinkFilter = function(link) {
    return link.substring(0, javascript.length - 1) !== javascript;
  };

  emitLinks = function(link) {
    return socket.emit('url.add', {
      href: link
    });
  };

  document.querySelectorAll('a[href]').filter(jsLinkFilter).map(emitLinks);

  decorateLink = function(link, status) {
    var span;
    span = document.createElement('span');
    span.className = "status HTTP" + status;
    span.innerHtml = status;
    return link.appendChild(span);
  };

  getDecorator = function(data) {
    return function(link) {
      if (data.url === link) {
        return decorateLink(link, data.status);
      }
    };
  };

  socket.on('url.status', function(data) {
    return document.querySelectorAll('a[href]').map(getDecorator(data));
  });

}).call(this);
