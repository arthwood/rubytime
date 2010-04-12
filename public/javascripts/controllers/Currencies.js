var Currencies = function() {
  this.onEditDC = $DC(this, this.onEdit);
  this.onRemoveDC = $DC(this, this.onRemove);
  this.onEditSuccessD = $D(this, this.onEditSuccess);
  this.onDeleteSuccessD = $D(this, this.onDeleteSuccess);
  this.listing = $$('.listing').first();
  this.sideForm = $$('.side_form').first();
  this.onPrefixChangeDC = $DC(this, this.onPrefixChange);
  this.onSymbolChangeDC = $DC(this, this.onSymbolChange);
  $$('.listing td.actions').each($DC(this, this.initActions));
  this.initExample();
}

Currencies.prototype = {
  initActions: function(i) {
    var elements = i.elements();
    var edit = elements.first();
    var remove = elements.second();
    
    edit.onclick = this.onEditDC;
    remove.onclick = this.onRemoveDC;
  },
  
  onEdit: function(e) {
    $get(e.currentTarget.href, this.onEditSuccessD);
    
    return false;
  },
  
  onRemove: function(e) {
    if (confirm('Really remove this currency?')) {
      $del(e.currentTarget.href, null, this.onDeleteSuccessD);
    }
    
    return false;
  },
  
  onEditSuccess: function(ajax) {
    this.sideForm.innerHTML = ajax.getResponseText();
    this.initExample();
    this.updateExample();
  },
  
  onDeleteSuccess: function(ajax) {
    this.listing.innerHTML = ajax.getResponseText();
    
    app.flash.show('info', 'Currency successfully deleted!');
  },
  
  initExample: function() {
    this.example = this.sideForm.down('.example .input').first();
    this.symbol = $('currency_symbol');
    this.symbol.onchange = this.onSymbolChangeDC;
    this.currencyPrefix = $('currency_prefix');
    this.currencyPrefix.onchange = this.onPrefixChangeDC;
  },
  
  onPrefixChange: function(e) {
    this.updateExample();
  },
  
  onSymbolChange: function(e) {
    this.updateExample();
  },
  
  updateExample: function() {
    var arr = ['45.99', this.symbol.value];
    
    this.currencyPrefix.checked && arr.reverse();
    
    this.example.innerHTML = arr.join(''); 
  }
};

Application.onLoad.add($D(null, function() {
  this.currencies = new Currencies();
}));
