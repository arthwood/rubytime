var Clients = $E(Resources, function() {
  arguments.callee.super('client');
});

Application.onLoad.add($D(null, function() {
  this.clients = new Clients();
}));
