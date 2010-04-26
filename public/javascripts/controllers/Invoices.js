var Invoices = $E(Resources, function() {
  arguments.callee.super('invoice');
});

Application.onLoad.add($D(null, function() {
  this.invoices = new Invoices();
}));
