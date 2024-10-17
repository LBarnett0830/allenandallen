({
    init : function(component, event, helper) {
        var recId = component.get("v.recordId");
        component.set('v.urlPDF','/apex/SODOnMatterPDF?id='+recId);
        
    }
})