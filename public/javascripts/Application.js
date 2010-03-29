var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
  
  this.flash = new Flash();
};

Application.prototype = {
};

window.onload = function() {
  this.app = new Application();
};
