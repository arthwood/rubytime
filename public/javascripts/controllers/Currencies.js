var Currencies = $E(Resources, function() {
  arguments.callee.$super('currency', 'currencies');
  
  this.onPrefixChangeDC = this.onPrefixChange.bind(this);
  this.onSymbolChangeDC = this.onSymbolChange.bind(this);
  
  this.initExample();
  this.updateExample();
}, {
  onEditSuccess: function(ajax) {
    arguments.callee.$super(ajax);
    
    this.initExample();
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
    
    this.example.setContent(arr.join('')); 
  }
});

Application.onLoad.add($D(null, function() {
  this.currencies = new Currencies();
}));
