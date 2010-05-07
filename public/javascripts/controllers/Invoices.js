var Invoices = $E(Resources, function() {
  arguments.callee.super('invoice');
  
  this.pendingRowDC = this.pendingRow.bind(this);
  this.refreshRowDC = this.refreshRow.bind(this);
  this.showHideDCArray = [ArtJs.ElementUtils.showDC, ArtJs.ElementUtils.hideDC];
  this.oddEvenArray = ['odd', 'even'];

  var filters = $('submenu').elements();

  filters.first().onclick = this.onAllFilter.bind(this);
  filters.second().onclick = this.onIssuedFilter.bind(this);
  filters.third().onclick = this.onPendingFilter.bind(this);
}, {
  onAddNewSuccess: function(ajax) {
    arguments.callee.super(ajax);
    
    this.initForm();
  },
  
  onEditSuccess: function(ajax) {
    arguments.callee.super(ajax);
    
    this.initForm();
  },
  
  initForm: function() {
    var datepicker = this.sideForm.down('.datepicker').first();
    
    app.datePicker.initField(datepicker);
  },
  
  onAllFilter: function(e) {
    this.getRows().each(ArtJs.ElementUtils.showDC);
    this.refreshRows();
    
    return false;
  },
  
  onIssuedFilter: function(e) {
    this.onIssued(true);
    this.refreshRows();
    
    return false;
  },
  
  onPendingFilter: function(e) {
    this.onIssued(false);
    this.refreshRows();
    
    return false;
  },
  
  onIssued: function(issued) {
    var tr = this.getRows();
    var issuedRows = tr.reject(this.pendingRowDC);
    var pendingRows = tr.select(this.pendingRowDC);
    
    issuedRows.each(this.showHideDCArray[Number(!issued)]);
    pendingRows.each(this.showHideDCArray[Number(issued)]);
  },
  
  pendingRow: function(tr) {
    return tr.elements()[3].getContent().blank();
  },
  
  getRows: function() {
    return this.listing.down('tr').slice(1);
  },
  
  getVisibleRows: function() {
    return this.getRows().reject(ArtJs.ElementUtils.isHiddenDC);
  },
  
  refreshRows: function() {
    this.getVisibleRows().eachPair(this.refreshRowDC);
  },
  
  refreshRow: function(idx, e) {
    var b = Boolean(idx % 2);

    e.removeClass(this.oddEvenArray[Number(!b)]);
    e.addClass(this.oddEvenArray[Number(b)]);
  }
});

Application.onLoad.add($D(null, function() {
  this.invoices = new Invoices();
}));
