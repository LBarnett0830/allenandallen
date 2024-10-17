@IsTest(SeeAllData=false)
public class Allen_RichTextToPlain_Test {
    
    static testmethod void stripMarkup_test(){
        List<String> testInputs = New List<String>();
        testInputs.add('<p><span style="font-size: 16px; color: rgb(186, 0, 0);">Lorem ipsum dolor sit amet</span>,<i> consectetur adipiscing elit. </i></p><p><b>Sed eget porta tortor.</b></p>');
        testinputs.add('<dl><dt><b>First Law:</b></dt><dd>A robot may not injure a human being or, through inaction, allow a human being to come to harm.</dd><dt><b>Second Law:</b></dt><dd>A robot must obey the orders given it by human beings except where such orders would conflict with the First Law.</dd><dt><b>Third Law:</b></dt><dt class="ql-indent-1">A robot must protect its own existence as long as such protection does not conflict with the First or Second Law.&quot;</dt></dl><p style="text-align: right;">- Handbook of Robotics, 56th Edition, 2058 A.D.&quot;</p><dl><dd><br></dd></dl>');
        
        System.debug(Allen_RichTextToPlain.stripMarkup(testInputs));
        
    }
}