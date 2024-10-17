({
    defineURL : function(component) {
        // set param to method
        var recId = component.get("v.recordId");
        component.set('v.urlRough','/apex/closingStatementPdf?id='+recId+'&type=Rough');
        component.set('v.urlFinal','/apex/closingStatementFinalPdf?id='+recId+'&type=Final');
    }
})