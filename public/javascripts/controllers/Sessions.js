var Sessions = function() {
};

Sessions.prototype = {
};

Application.onLoad.add($D(null, function() {
  this.sessions = new Sessions();
}));
