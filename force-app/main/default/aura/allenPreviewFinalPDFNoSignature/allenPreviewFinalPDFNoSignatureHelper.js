({
    defineURL : function(component) {
        // set param to method
        var recId = component.get("v.recordId");
        component.set('v.urlFinal','/apex/closingStatementFinalPdfNoSignature?id='+recId+'&type=Final');
    }
})