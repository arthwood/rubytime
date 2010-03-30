var Layout = function() {
  window.onresize = $DC(this, this.onResize);
  
  this.menu = $('menu');
  this.newActivityContainer = $('new_activity');
  
  this.update();
}

Layout.prototype = {
  onResize: function(e) {
    this.update();
  },
  
  update: function() {
    if (this.newActivityContainer) {
      var w = this.newActivityContainer.getSize().x;
      var rect = this.menu.getLayout();
      
      this.newActivityContainer.setPosition(rect.getRightBottom().sub(new Point(w, 0)));
    }
  }
};
