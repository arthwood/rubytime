var Users = function() {
  this.userType = $('user_type');
  this.userRole = $('user_role_id');
  /*this.userRoleItem = this.userRole.up('.item').first();
  this.client = $('user_client_id');
  this.clientItem = this.client.up('.item').first();
  
  this.selects = [this.userRoleItem, this.clientItem];

  this.userType.onchange = $DC(this, this.onUserTypeChange);

  this.updateSelect();*/
}

Users.prototype = {
  onUserTypeChange: function(e) {
    this.updateSelect();
  },

  updateSelect: function() {
    var value = parseInt(this.userType.value)
    
    this.selects[value].show();
    this.selects.reverse()[value].hide();
  }
};

Application.onLoad.add($D(null, function() {
  this.users = new Users();
}))
