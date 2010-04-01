var NewActivity = function() {
  this.container = $('new_activity');
  this.menu = $('menu');
  this.addNewActivity = $$('.add_activity').first();
  this.cancelNewActivity = this.container.down('.item.last a').first();
  this.addNewActivity.onclick = $DC(this, this.onAddNewActivity);
  this.cancelNewActivity.onclick = $DC(this, this.onCancelNewActivity);

  app.onResize.add($D(this, this.onResize));

  this.updateLayout();
}

NewActivity.prototype = {
  onResize: function(e) {
    this.updateLayout();
  },

  updateLayout: function() {
    var w = this.container.getSize().x;
    var rect = this.menu.getLayout();

    this.container.setPosition(rect.getRightBottom().sub(new Point(w, 0)));
  },

  onAddNewActivity: function(e) {
    this.container.toggle();

    return false;
  },
  
  onCancelNewActivity: function(e) {
    this.container.hide();

    return false;
  }
};

Application.onLoad.add($D(null, function() {
  this.newActivity = new NewActivity();
}))
