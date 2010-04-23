var Helper = function() {
  this.onProjectsLoad = new CustomEvent('Helper::onProjectsLoad');
  this.onProjectsSuccessD = $D(this, this.onProjectsSuccess);
  this.projectToOptionDC = $DC(this, this.projectToOption);
};

Helper.prototype = {
  getProjects: function(userId) {
    $get('projects.json', {user_id: userId}, this.onProjectsSuccessD);
  },
  
  onProjectsSuccess: function(ajax) {
    this.onProjectsLoad.fire(this.buildProjectOptions(eval(ajax.getResponseText())));
  },
  
  buildProjectOptions: function(data) {
    return data.map(this.projectToOptionDC).join('');
  },
  
  projectToOption: function(i, idx) {
    return $B('option', {value: i.id}, i.name);
  }
};
