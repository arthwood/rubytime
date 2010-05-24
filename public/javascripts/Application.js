var Application = function() {
  this.flash = new Flash($('flash'), '/images/flash');
  this.datePicker = new DatePicker(1);
  this.onResize = new CustomEvent('Application::onResize');

  window.onresize = this._onResize.bind(this);
};

Application.prototype = {
  _onResize: function(e) {
    this.onResize.fire(e);
  }
};

ArtJs.globalize();
ArtJs.doInjection();

Application.onLoad = new CustomEvent('Application:onLoad');

window.onload = function() {
  this.app = new Application();
  
  Application.onLoad.fire();
};
