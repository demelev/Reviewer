// Generated by CoffeeScript 1.10.0
(function() {
  var Response, responses;

  Response = (function() {
    function Response(data) {
      alert(JSON.stringify(data));
    }

    return Response;

  })();

  responses = {
    parse: function(data) {
      var response;
      return response = new Response(data);
    }
  };

}).call(this);
