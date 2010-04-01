var Users = function() {
}

Users.prototype = {
};

Application.onLoad.add($D(null, function() {
  this.users = new Users();
}))
