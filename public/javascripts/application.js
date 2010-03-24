var Application = function() {
  ArtJs.globalize();
  ArtJs.doInjection();
};

window.onload = function() {
  this.app = new Application();
};
