var Activities = $E(Resources, function() {
  this.results = $('results');
  this.filterForm = $$('.filter form').first();
  this.filterForm.onsubmit = this.onFilter.bind(this, true);
  this.onFilterSuccessD = $D(this, this.onFilterSuccess);
  this.filterUserSelect = $('activity_filter_user_id');
  
  if (this.filterUserSelect) {
    this.filterUserSelect.onchange = this.onUserSelect.bind(this, true);
    this.filterProject = $('activity_filter_project_id');
  }
  
  this.usersVisible = true;
  
  this.actions = $('activities_actions');
  
  if (this.actions) {
    var links = this.actions.down('a');
    
    this.toggleUsers = links.first();
    this.toggleUsers.onclick = this.onToggleUsers.bind(this, true);
    this.exportCSV = links.second();
    this.exportPDF = links.third();
    this.exportCSV.onclick = this.exportPDF.onclick = this.onExport.bind(this, true);
    this.trToIdDC = this.trToId.bind(this);
  }
  
  this.onProjectsSuccessD = $D(this, this.onProjectsSuccess);
  this.projectToOptionDC = this.projectToOption.bind(this);
  
  this.filterDateFrom = $('activity_filter_from');
  this.filterDateTo = $('activity_filter_to');
  this.period = $('activity_filter_period');
  this.period.onchange = this.onPeriod.bind(this, true);
  this.initSelectAllDC = this.initSelectAll.bind(this);
  this.onSelectAllChangeDC = this.onSelectAllChange.bind(this, true);
  this.selectActivityDC = this.selectActivity.bind(this);
  this.onCreateInvoiceFormSubmitDC = this.onCreateInvoiceFormSubmit.bind(this, true);
  this.onCreateInvoiceFormSubmitSuccessD = $D(this, this.onCreateInvoiceFormSubmitSuccess);
  this.onAddToInvoiceFormSubmitDC = this.onAddToInvoiceFormSubmit.bind(this, true);
  this.onAddToInvoiceFormSubmitSuccessD = $D(this, this.onAddToInvoiceFormSubmitSuccess);
  this.selectCheckedDC = this.selectChecked.bind(this);
  this.checkboxToActivityIdDC = this.checkboxToActivityId.bind(this);
  this.markActivityAsInvalidDC = this.markActivityAsInvalid.bind(this);
  
  arguments.callee.$super('activity');
  
  // nullify not used properties and methods
  this.sideForm = null;
  this.initAddNewLink = null;
  this.onAddNew = null;
  this.onAddNewSuccess = null;
}, {
  onFilter: function(f) {
    this.search();
    
    return false;
  },
  
  search: function() {
    $post(this.filterForm.action, this.filterForm.serialize(), this.onFilterSuccessD);
  },
  
  onFilterSuccess: function(ajax) {
    this.results.setContent(ajax.getResponseText());
    
    if (this.actions) {
      this.actions.setVisible(!this.results.firstElement().hasClass('no_results'));
      this.updateUsersVisibility();
    }
    
    this.initResults();
  },
  
  initResults: function(i) {
    this.init();
    
    $$('.listing input[type=checkbox,name=select_all]').each(this.initSelectAllDC);
    
    var forms = this.results.down('form');
    var createInvoiceForm = forms.first();
    var addToInvoiceForm = forms.second();
    
    createInvoiceForm && (createInvoiceForm.onsubmit = this.onCreateInvoiceFormSubmitDC);
    addToInvoiceForm && (addToInvoiceForm.onsubmit = this.onAddToInvoiceFormSubmitDC);
  },
  
  initSelectAll: function(i) {
    var chbs = this.getCheckboxes(i);
    
    i.onchange = this.onSelectAllChangeDC;
    i.setVisible(!chbs.empty());
  },
  
  getCheckboxes: function(chb) {
    return chb.up('table').down('.activity input[type=checkbox,name=select]');
  },
  
  onSelectAllChange: function(chb) {
    this.selectActivityDC.delegate.args = [chb.checked];
    
    this.getCheckboxes(chb).each(this.selectActivityDC);
  },
  
  selectActivity: function(i, checked) {
    i.checked = checked;
  },
  
  onEditSuccess: function(ajax) {
    var body = ajax.getResponseText();
    
    if (body.empty()) {
      app.flash.show('error', "Couldn't edit that activity");
    }
    else {
      newActivity.onEdit($P(body));
    }
  },
  
  onUserSelect: function(select) {
    $get('projects.json', {user_id: select.value}, this.onProjectsSuccessD);
  },
  
  onPeriod: function(select) {
    var arr = (select.selectedIndex > 0) ? select.value.split('/') : ['', ''];
    
    this.filterDateFrom.value = arr.first();
    this.filterDateTo.value = arr.second();
  },
  
  onProjectsSuccess: function(ajax) {
    var option = new ElementBuilder('option', {value: ''}, 'All projects...');
    
    this.filterProject.setContent(option.toString() + this.buildProjectOptions(eval(ajax.getResponseText())));
  },
  
  buildProjectOptions: function(data) {
    return data.map(this.projectToOptionDC).join('');
  },
  
  projectToOption: function(i, idx) {
    var option = new ElementBuilder('option', {value: i.id}, i.name);
    
    return option.toString();
  },

  /**
   * NewActivity's controller implementation
   */
  onNewActivitySuccess: function(json) {
    // Search only if any search has been performed
    if ($$('.clients').first()) {
      this.search();
    }
  },
  
  onEditActivitySuccess: function(json) {
    this.search();
  },
  
  onCreateInvoiceFormSubmit: function(form) {
    return this.onInvoiceFormSubmit(form);
  },
  
  onAddToInvoiceFormSubmit: function(form) {
    return this.onInvoiceFormSubmit(form);
  },
  
  onInvoiceFormSubmit: function(form) {
    var activityIds = this.selectedActivityIds();
    
    if (activityIds.empty()) {
      app.flash.show('warning', 'Please select at least one activity.');
      
      return false;
    }
    
    $post(form.action, form.serialize().merge({activity_ids: activityIds}), this.onCreateInvoiceFormSubmitSuccessD);
    
    return false;
  },
  
  selectedActivityIds: function() {
    return $$('input[name=select]').select(this.selectCheckedDC).map(this.checkboxToActivityIdDC);
  },
  
  selectChecked: function(i) {
    return i.checked;
  },
  
  checkboxToActivityId: function(i) {
    return i.up('.activity').id.split('_').last();
  },
  
  onCreateInvoiceFormSubmitSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    
    if (json.success) {
      app.flash.show('info', 'Activities successfully invoiced!');
      
      this.search();
    }
    else {
      app.flash.show('error', json.error);
      json.bad_activities.each(this.markActivityAsInvalidDC);
    }
  },
  
  onAddToInvoiceFormSubmitSuccess: function(ajax) {
    app.flash.show('info', 'Activities successfully invoiced!');
    
    this.search();
  },
  
  markActivityAsInvalid: function(id) {
    $('activity_' + id).addClass('invalid');
  },
  
  onToggleUsers: function(a) {
    this.usersVisible = !this.usersVisible;
    this.updateUsersVisibility();
    
    return false;
  },
  
  updateUsersVisibility: function() {
    var label = this.usersVisible ? 'hide users' : 'show users';
    var dc = this.usersVisible ? ElementUtils.showDC : ElementUtils.hideDC;
    
    this.toggleUsers.setContent(label);
    $$('.users').each(dc);
  },
  
  onExport: function(a) {
    var url = a.href.split('?').first();
    var ids = this.results.down('tr.activity').map(this.trToIdDC);
    var idsQuery = ArtJs.ObjectUtils.toQueryString({ids: ids});
    
    var hideUsers = Number(!this.usersVisible);
    
    a.href = url + '?' + idsQuery + '&hide_users=' + hideUsers;
    
    return true;
  },
  
  trToId: function(i) {
    return i.id.split('_').second();
  }
});

Application.onLoad.add($D(null, function() {
  this.activities = new Activities();
  this.newActivity && (this.newActivity.controller = this.activities);
}));
