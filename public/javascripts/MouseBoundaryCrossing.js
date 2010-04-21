var MouseBoundaryCrossing = {
  update: function(evt, landmark) {
    evt = evt || window.event;
    
    var eventType = evt.type;
    
    this.landmark = landmark;
    this.inLandmark = false;
    this.leftLandmark = false;
    this.enteredLandmark = false;
    
    switch (eventType) {
      case 'mouseout':
        this.toElement = evt.relatedTarget || evt.toElement;
        this.fromElement = evt.target || evt.srcElement;
  
        break;
      case 'mouseover':
        this.toElement = evt.target || evt.srcElement;
        this.fromElement = evt.relatedTarget || evt.fromElement;
  
        break;
      default:
        throw (new Error('Event type "' + eventType + '" is irrelevant'));
    }
    
    if (!this.toElement || !this.fromElement) {
      throw (new Error('Event target(s) undefined'));
    }
    
    var from = this.findLandmark(this.fromElement);
    var to = this.findLandmark(this.toElement);
    
    if (from == landmark && to == landmark) {
      this.inLandmark = true;
    }
    else if (from == landmark && to != landmark) {
      this.leftLandmark = true;
      this.inLandmark = (eventType == 'mouseout');
    }
    else if (from != landmark && to == landmark) {
      this.enteredLandmark = true;
      this.inLandmark = (eventType == 'mouseover');
    }
  },

  findLandmark: function(e) {
    while (e.nodeType == 1) {
      if (e == this.landmark) return e;
      e = e.parentNode;
    }
  }
};

var $MBC = MouseBoundaryCrossing;
