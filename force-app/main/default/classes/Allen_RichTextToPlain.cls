/*
 * Name      	: Allen_RichTextToPlain
 * Author       : Jon Otis
 * Description  : Strips HTML markup from a rich text string. Added for use in Flow "Matter Team to Alert",
 *                to help with including Litify Notes content in Chatter posts.
 * Maintenance History  : New
 * 09/27/2021
 */

public class Allen_RichTextToPlain {

    @InvocableMethod(label='Rich Text to Plain Text' description='Converts all HTML tags in a rich text string to spaces.' category='Other')
    public static List<String> stripMarkup(List<String> inputs){
        List<String> outputs = New List<String>();

        // Replace all HTML tags (substrings within < > brackets) with single spaces and add to outputs
        for(String input : inputs) {
            String convert = input.replaceAll('<[^>]+>',' '); 
            outputs.add(convert);
        }
        
        return outputs;
    }
    
}