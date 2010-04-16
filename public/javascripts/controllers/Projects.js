var Projects = $E(Resources, function() {
  arguments.callee.super('project');
});

Application.onLoad.add($D(null, function() {
  this.projects = new Projects();
}));
