// Generated by CoffeeScript 1.6.3
(function() {
  var i, link, socket, _i, _len, _ref;

  socket = io.connect('http://localhost', {
    port: 3000
  });

  _ref = document.querySelectorAll('a[href]');
  for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
    link = _ref[i];
    if (link.toString().substring(0, 'javascript:'.length - 1) !== 'javascript:') {
      link.setAttribute('data-role', "lc-" + i);
      socket.emit('url.add', {
        href: link.toString(),
        n: i
      });
    }
  }

  socket.on('url.status', function(data) {
    var span;
    if ((data != null) && (data.status != null) && (data.n != null)) {
      span = document.createElement('span');
      span.className = "status HTTP" + data.status;
      span.appendChild(document.createTextNode(data.status));
      link = document.querySelector("[data-role=lc-" + data.n + "]");
      return link.parentNode.insertBefore(span, link);
    }
  });

}).call(this);