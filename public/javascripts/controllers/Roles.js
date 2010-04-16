var Roles = $E(Resources, function() {
  arguments.callee.super('role');
});

Application.onLoad.add($D(null, function() {
  this.roles = new Roles();
}));
