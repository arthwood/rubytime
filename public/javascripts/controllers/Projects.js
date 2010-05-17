var Projects = $E(Resources, function() {
  arguments.callee.$super('project');
  
  this.initAddNewHourlyRateDC = this.initAddNewHourlyRate.bind(this);
  this.onAddNewHourlyRateDC = this.onAddNewHourlyRate.bind(this);
  this.onAddNewHourlyRateSuccessD = $D(this, this.onAddNewHourlyRateSuccess);
  this.onAddNewHourlyRateCancelDC = this.onAddNewHourlyRateCancel.bind(this);
  this.onAddNewHourlyRateSubmitDC = this.onAddNewHourlyRateSubmit.bind(this);
  this.onCreateHourlyRateSuccessD = $D(this, this.onCreateHourlyRateSuccess);
  this.currentLink = null;
  this.currentForm = null;
}, {
  onEditSuccess: function(ajax) {
    arguments.callee.$super(ajax);
    
    $$('.role a').each(this.initAddNewHourlyRateDC);
  },
  
  initAddNewHourlyRate: function(i) {
    i.onclick = this.onAddNewHourlyRateDC;
  },
  
  onAddNewHourlyRate: function(e) {
    var a = e.currentTarget;
    
    this.currentLink = a;
    
    $get(a.href, null, this.onAddNewHourlyRateSuccessD);
    
    return false;
  },
  
  onAddNewHourlyRateSuccess: function(ajax) {
    this.currentLink.next().setContent(ajax.getResponseText());
    this.currentLink.hide();
    this.initNewHourlyRateForm();
  },
  
  onAddNewHourlyRateCancel: function(ajax) {
    this.currentLink.next().setContent('');
    this.currentLink.show();
    
    return false;
  },
  
  initNewHourlyRateForm: function() {
    var form = this.currentLink.next().down('form').first();
    var cancel = form.down('.last a').first();
    
    cancel.onclick = this.onAddNewHourlyRateCancelDC;
    
    var datepicker = form.down('.datepicker').first();
    
    app.datePicker.initField(datepicker);
    
    form.onsubmit = this.onAddNewHourlyRateSubmitDC;
  },
  
  onAddNewHourlyRateSubmit: function(e) {
    var form = e.currentTarget;
    
    $post(form.action, form.serialize(), this.onCreateHourlyRateSuccessD);
    
    return false;
  },
  
  onCreateHourlyRateSuccess: function(ajax) {
    var json = ajax.getResponseText().toJson();
    
    if (json.success) {
      this.currentLink.prev().setContent(json.html);
      this.currentLink.next().setContent('');
      this.currentLink.show();
    }
    else {
      this.currentLink.next().setContent(json.html);;
    }
  }
});

Application.onLoad.add($D(null, function() {
  this.projects = new Projects();
}));
