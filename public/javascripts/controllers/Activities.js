var Activities = $E(Resources, function() {
  arguments.callee.super('activity');
  
  this.sideForm = null;
  this.initAddNewLink = null;
  this.onAddNew = null;
  this.onAddNewSuccess = null;
  
  this.filterUserSelect = $('activity_filter_user_id');
  this.filterUserSelect.onchange = this.onUserSelect.bind(this);
  this.filterProject = $('activity_filter_project_id');
  this.onProjectsD = $D(this, this.onProjects);
  this.filterDateFrom = $('activity_filter_from');
  this.filterDateTo = $('activity_filter_to');
  this.period = $('activity_filter_period');
  this.period.onchange = this.onPeriod.bind(this);
}, {
  onEditSuccess: function(ajax) {
    newActivity.onEdit(this, $P(ajax.getResponseText()));
  },
  
  onUserSelect: function(e) {
    var select = e.currentTarget;
    
    app.helper.onProjectsLoad.add(this.onProjectsD);
    app.helper.getProjects(e.currentTarget.value);
  },
  
  onProjects: function(projects) {
    this.filterProject.innerHTML = projects;
    app.helper.onProjectsLoad.remove(this.onProjectsD);
  },
  
  onPeriod: function(e) {
    var select = e.currentTarget;
    
    if (select.selectedIndex > 0) {
      var arr = select.value.split('/');
    
      this.filterDateFrom.value = arr.first();
      this.filterDateTo.value = arr.second();
    }
  },
  
  onEditActivitySuccess: function(activity) {
    
  }
});

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
}));
