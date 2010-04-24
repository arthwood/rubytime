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
  this.activityTemplate = $('activity_template');
}, {
  onEditSuccess: function(ajax) {
    newActivity.onEdit($P(ajax.getResponseText()));
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
    var projectElement = $('project_' + activity.project_id);
    
    // TODO: when there is no results
    
    if (!projectElement) {
      var clientClone = this.activityTemplate.down('.client').first().clone();
      
      projectElement = clientClone.down('.project').first();
      projectElement.id = 'project_' + activity.project_id;
      
      clientClone.putAtBottom($$('.listing').first().down('.clients').first());
    }
    
    var activityClone = this.activityTemplate.down('tr').second().clone();
    var cols = activityClone.down('td');
    
    activityClone.title = activity.comments;
    
    cols[0].setContent(activity.date);
    cols[1].setContent(activity.user.name);
    cols[2].setContent(activity.time_spent);
    
    var actions = cols[3].down('a');
    
    actions.first().onclick = this.onEditDC;
    actions.second().onclick = this.onDeleteDC;
    
    activityClone.putAtBottom(projectElement.down('tbody').first());
  },
  
  onEditActivitySuccess: function(activity) {
    
  }
});

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
  this.newActivity.controller = this.activities;
}));
