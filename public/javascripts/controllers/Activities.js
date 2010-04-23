var Activities = $E(Resources, function() {
  arguments.callee.super('activity');
  
  this.sideForm = null;
  this.initAddNewLink = null;
  this.onAddNew = null;
  this.onAddNewSuccess = null;
  
  this.filterUserSelect = $('activity_filter_user_id');
  this.filterUserSelect.onchange = this.onUserSelect.bind(this);
  this.filterProject = $('activity_filter_project_id');
  this.filterDateFrom = $('activity_filter_from');
  this.filterDateTo = $('activity_filter_to');
  this.period = $('activity_filter_period');
  this.period.onchange = this.onPeriod.bind(this);
  this.onProjectsSuccessD = $D(this, this.onProjectsSuccess);
  this.projectToOptionDC = this.projectToOption.bind(this);
}, {
  onEditSuccess: function(ajax) {
    newActivity.onEdit(this, $P(ajax.getResponseText()));
  },
  
  onUserSelect: function(e) {
    $get('projects.json', {user_id: e.currentTarget.value}, this.onProjectsSuccessD);
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
    
  },
  
  onProjectsSuccess: function(ajax) {
    var selectAllOption = $B('option', {value: 0}, 'All projects...');
    
    this.filterProject.innerHTML = selectAllOption + this.buildProjectOptions(eval(ajax.getResponseText()));
  },
  
  buildProjectOptions: function(data) {
    return data.map(this.projectToOptionDC).join('');
  },
  
  projectToOption: function(i, idx) {
    return $B('option', {value: i.id}, i.name);
  },

  /**
   * NewActivity's controller implementation
   */
  getCurrentUserId: function() {
    return null;
  },
  
  onNewActivitySuccess: function(activity) {
    
  },
  
  onEditActivitySuccess: function(activity) {
    
  }
});

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
  this.newActivity.controller = this.activities;
}));
