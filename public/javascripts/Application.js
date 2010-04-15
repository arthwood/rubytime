var Application = function() {
  this.flash = new Flash();
  this.datePicker = new DatePicker();
  this.helper = new Helper();
  this.onResize = new Event('Application.onResize');

  window.onresize = $DC(this, this._onResize);
};

Application.prototype = {
  _onResize: function(e) {
    this.onResize.fire(e);
  }
};

ArtJs.globalize();
ArtJs.doInjection();

Application.onLoad = new Event('Application:onLoad');

window.onload = function() {
  this.app = new Application();
  
  Application.onLoad.fire();
};
