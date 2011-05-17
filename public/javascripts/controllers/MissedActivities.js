var MissedActivities = function() {
  this.results = $('results');
  this.filterForm = $$('.filter form').first();
  this.filterForm.onsubmit = this.onFilter.bind(this);
  this.onFilterSuccessD = $D(this, this.onFilterSuccess);
  this.filterDateFrom = $('filter_from');
  this.filterDateTo = $('filter_to');
  this.period = $('filter_period');
  this.period.onchange = this.onPeriod.bind(this);
};

MissedActivities.prototype = {
  onPeriod: function(e) {
    var select = e.currentTarget;
    var arr = (select.selectedIndex > 0) ? select.value.split('/') : ['', ''];
    
    this.filterDateFrom.value = arr.first();
    this.filterDateTo.value = arr.second();
  },
  
  onFilter: function(e) {
    this.search();
    
    return false;
  },
  
  search: function() {
    $post(this.filterForm.action, this.filterForm.serialize(), this.onFilterSuccessD);
  },
  
  onFilterSuccess: function(ajax) {
    this.results.setContent(ajax.getResponseText());
  }
};

Application.onLoad.add($D(null, function() {
  this.missedActivities = new MissedActivities();
}));
