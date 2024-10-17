({
    processResults : function(results, returnFields, searchText) {
        
        var regEx = null;
        if (searchText != null && searchText.length> 0) {
            searchText= searchText.replace('*','');
            regEx = new RegExp(searchText, 'gi');
        }
        
        for (var i = 0; i < results.length; i++) {
            
            results[i]['Field0'] = results[i][returnFields[0]].replace(regEx,'<mark>$&</mark>');
            
            for(var j = 1; j < returnFields.length; j++){
                var fieldValue = results[i][returnFields[j]];
                var fieldIndex= 'Field'+j;
                if (fieldValue) {
                    results[i][fieldIndex] = (results[i][fieldIndex] || '') + ' • ' + fieldValue;
                }
            }
            if (results[i]['Field1']) {
                results[i]['Field1'] = results[i]['Field1'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
            if (results[i]['Field2']) {
                results[i]['Field2'] = results[i]['Field2'].substring(3).replace(regEx,'<mark>$&</mark>');
            }
            
            if (results[i]['Field3']) {
                results[i]['Field3'] = results[i]['Field2'].substring(3).replace(regEx,'<mark>$&</mark>');
                
            }
            
        }
        return results;
    }
})