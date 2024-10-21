@IsTest
public without sharing class TestDataFactory{

    public TestDataFactory(){ }
    private TestDataFactory m_factory;
    public TestDataFactory Instance{
        get {
            if(m_factory == null){
                m_factory = new TestDataFactory();
            }
            return m_factory;
    }
    }


    private static Map<String, Account> createdAccounts = new Map<String, Account>();
    public static final Map<String, Object> USER_PATTERN = new Map<String, Object>{
            'alias' => '',
            'email' => '',
            'emailEncodingKey' => 'UTF-8',
            'languageLocaleKey' => 'en_US',
            'localeSidKey' => 'en_US',
            'name' => 'user',
            'lastName' => 'lastname',
            'communityNickname' => '',
            'profileId' => '',
            'timeZoneSidKey' => 'America/Los_Angeles',
            'userName' => '',
            'domain' => 'domain.com'//local variable

    };
    //public static final String USER_NAME_PATTERN = 'user%';

    private static final Id STANDARD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
    private static final Id SYS_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
    private static final Date CURRENT_DATE = System.today();

    public static void resolutionDamageAndLiensControllerTestSetup(){

        User adminUser = createAdminUser();
        adminUser.Expense_Approval_Limit__c = 0;

        User principalUser = createUserWithName('Principal');
        principalUser.Expense_Approval_Limit__c = 0;

        User litigationUser = createUserWithName('Litigation');
        litigationUser.Expense_Approval_Limit__c = 0;
        tryCommitData(new List<User>{ adminUser, principalUser, litigationUser }, 'User');

        EmailTemplate validEmailTemplate = [SELECT Id, DeveloperName FROM EmailTemplate LIMIT 1];


        List<Account> testAccounts = new List<Account>();
        Account test1 = createAccount('Test');
        test1.litify_pm__Last_Name__c = 'test LastName';

        Account testForProjectAccount = createAccount('Test Account For Project');
        testForProjectAccount.litify_pm__Last_Name__c = 'test NameLast';
        testForProjectAccount.RecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Litify Individual').getRecordTypeId();
        testForProjectAccount.AcctSeed__Accounting_Active__c = true;
        testForProjectAccount.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
        testForProjectAccount.Matter_Vendor__c = true;

        testAccounts.add(test1);
        testAccounts.add(testForProjectAccount);
        tryCommitData(testAccounts, 'Test Accounts');

        Department__c department = createDepartment(adminUser);
        tryCommitData(department, 'Department');

        List<AcctSeed__GL_Account__c> standardGLAccounts = createGLAccounts(department);

        Firm_Ledger_COS_Fee_Revenue_GL_Account__c firmLedger = createLedgerRevenue();
        tryCommitData(firmLedger, 'Firm Ledger COS Fee Revenue GL Account');

        List<AcctSeed__GL_Account__c> firmLedgerAccounts = createLedgerGLAccounts(firmLedger, department);
        firmLedgerAccounts.addAll(standardGLAccounts);
        tryCommitData(firmLedgerAccounts, 'GL Accounts');

        litify_pm__Matter__c matter = createMatter(test1, adminUser);
        tryCommitData(matter, 'Matter');

        litify_pm__Matter_Team_Role__c teamRole = createMatterTeamRole();
        tryCommitData(teamRole, 'MatterTeamRole');

        litify_pm__Matter_Team_Member__c teamMember = createMatterTeamMember(matter, adminUser, teamRole);
        tryCommitData(teamMember, 'MatterTeamMember');

        Map<String, litify_pm__Expense_Type__c> expenseByCategory = createExpenseTypeByCategory();
        tryCommitData(expenseByCategory.values(), 'ExpenseType' );

        List<litify_pm__Expense__c> expenses = createExpenses(expenseByCategory, matter);
        tryCommitData(expenses, 'Expenses');

        Map<String, AcctSeed__Billing_Format__c> billingFormats = createBillingFormats(validEmailTemplate);
        tryCommitData(billingFormats.values(), 'BillingFormats');

        List<AcctSeed__Ledger__c> acctLedgers = createLedgers(billingFormats,firmLedgerAccounts );
        tryCommitData(acctLedgers, 'Ledgers');

        List<AcctSeed__Accounting_Variable__c> accountingVariables = createAccountingVariables();
        tryCommitData(accountingVariables, 'AccountingVariables');

        List<AcctSeed__Accounting_Period__c> accountingPeriods = createAccountingPeriod();
        tryCommitData(accountingPeriods, 'AccountingPeriods');

        litify_pm__Resolution__c resolution = createResolution(matter);
        tryCommitData(resolution, resolution.getSObjectType().getDescribe().getLabel());

        litify_pm__Role__c role = createRole(test1, matter);
        tryCommitData(role, 'Role');

        litify_pm__Damage__c damage = createDamage(role, matter, resolution);
        tryCommitData(damage, 'Damage');
        tryUpdateData(damage, 'Damage');

        List<litify_pm__Lien__c> liens = createLiens(resolution, test1, matter, role);
        tryCommitData(liens,'Liens ');

        Trust_Deposit__c trustDeposit = createTrustDeposit();
        tryCommitData(trustDeposit, 'Trust Deposit');

    }

    private static void tryCommitData(SObject sobj, String objName){
        try{
            insert sobj;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating' +  objName + ': ' + ex.getMessage());
        }
    }

    private static void tryCommitData(List<SObject> objList, String objName){
        try{
            insert objList;
        }catch(Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating' +  objName + ': ' + ex.getMessage());
        }
    }

    private static void tryUpdateData(SObject sobj, String objName){
        try{
            update sobj;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Updating' +  objName + ': ' + ex.getMessage());
        }
    }

    private static void tryUpdateData(List<SObject> sobj, String objName){
        try{
            update sobj;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Updating' +  objName + ': ' + ex.getMessage());
        }
    }

    public static User createAdminUser(){
        String uid = 'tadmin';
        return new User(
                LastName = (String) USER_PATTERN.get('lastName'),
                Alias = uid,
                Email = uid + '@' + (String) USER_PATTERN.get('domain'),
                EmailEncodingKey = (String)USER_PATTERN.get('emailEncodingKey'),
                LanguageLocaleKey = (String)USER_PATTERN.get('languageLocaleKey'),
                LocaleSidKey = (String)USER_PATTERN.get('localeSidKey'),
                ProfileId = SYS_ADMIN_PROFILE_ID,
                TimeZoneSidKey = (String)USER_PATTERN.get('timeZoneSidKey'),
                Username = (uid + '@' +  (String)USER_PATTERN.get('domain'))
        );
    }

    public static User createUserWithName(String name){
        Integer maxSize = 6;
        String uid = name;
        if(uid.length() > maxSize){
            uid = uid.substring(0, maxSize);
        }

        return new User(
                FirstName = name,
                LastName = name + '_' + (String) USER_PATTERN.get('lastName'),
                Alias = uid,
                Email = uid + '@' + (String) USER_PATTERN.get('domain'),
                EmailEncodingKey = (String)USER_PATTERN.get('emailEncodingKey'),
                LanguageLocaleKey = (String)USER_PATTERN.get('languageLocaleKey'),
                LocaleSidKey = (String)USER_PATTERN.get('localeSidKey'),
                ProfileId = STANDARD_PROFILE_ID,
                TimeZoneSidKey = (String)USER_PATTERN.get('timeZoneSidKey'),
                Username = (uid + '@' +  (String)USER_PATTERN.get('domain'))
        );
    }

    private static List<Account> getAccountsFromDb(){
        return [SELECT Id, Name FROM Account];
    }
    /**
     * @param name name of Account to Create
     *
     * @return Account record with name
     */
    public static Account createAccount(String name){
        Account account = new Account(Name = name);
        if(createdAccounts.isEmpty()){
            createdAccounts.put(account.Name, account);
        }else{
            Integer listSize = createdAccounts.size();
            if(createdAccounts.containsKey(name)){
                account.Name = name + ' ' +  listSize;
                createdAccounts.put(account.Name, account);
            }
        }
        return account;
    }

    private static Department__c createDepartment(User u){
        return new Department__c(Director__c = u.Id);
    }

    private static List<AcctSeed__GL_Account__c> createGLAccounts(Department__c department){
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();
        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = '1201-Client Costs Advanced',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = Label.Project_task_Revenue_GL_Account ,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));
        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = '1002-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
        ));
        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = '1020-Cash - Trust',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
        ));
        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = '2200-Trust Liability',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
        ));

        return glAccounts;
    }

    private static Firm_Ledger_COS_Fee_Revenue_GL_Account__c createLedgerRevenue(){
        return new Firm_Ledger_COS_Fee_Revenue_GL_Account__c(
                Fee_Revenue_GL_Account__c='4000-Fee Income',
                Hard_Cost_Advanced__c='1200-Client Costs Advanced',
                Soft_Cost_Reimbursed__c='4500-Litigation Exp Reimbursed',
                Trust_Receivable_GL_Account__c='1151-Trust Receivable',
                Open_case_expenses_GL_Account__c='1000-Cash - Operating', Name = 'AAA');
    }

    /**
     * @param ledger Firm_Ledger_COS_Fee_Revenue_GL_Account__c
     * @param department Department__c
     *
     * @return List<AcctSeed__GL_Account__c>
     */
    private static List<AcctSeed__GL_Account__c> createLedgerGLAccounts(Firm_Ledger_COS_Fee_Revenue_GL_Account__c ledger, Department__c department){
        List<AcctSeed__GL_Account__c> glAccounts = new List<AcctSeed__GL_Account__c>();

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = ledger.Fee_Revenue_GL_Account__c + ' ',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = ledger.Hard_Cost_Advanced__c+  '',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = ledger.Soft_Cost_Reimbursed__c,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = ledger.Trust_Receivable_GL_Account__c ,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        glAccounts.add(new AcctSeed__GL_Account__c(
                Name = ledger.Open_case_expenses_GL_Account__c ,
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                Department__c = department.Id,
                AcctSeed__Sub_Type_2__c = 'Cash'));

        return glAccounts;
    }

    /**
     * @param clientAccount Account
     * @param principalAttorney User
     *
     * @return litify_pm__Matter__c
     */
    private static litify_pm__Matter__c createMatter(Account clientAccount, User principalAttorney){
        return new litify_pm__Matter__c(
                litify_pm__Client__c = clientAccount.Id,
                litify_pm__Principal_Attorney__c = principalAttorney.Id,
                ATO_Case_Number__c = 'TestClass'
        );
    }

    private static litify_pm__Matter_Team_Role__c createMatterTeamRole(){
        return new litify_pm__Matter_Team_Role__c(Name='Attorney');
    }

    private static litify_pm__Matter_Team_Member__c createMatterTeamMember(litify_pm__Matter__c matter, User u, litify_pm__Matter_Team_Role__c role){
        return new litify_pm__Matter_Team_Member__c(
                Name='TestClass',
                litify_pm__Matter__c=matter.Id,
                litify_pm__User__c = u.Id,
                litify_pm__Role__c = role.Id
        );
    }
    /**
     * @param matter litify_pm__Matter__c
     *
     * @return litify_pm__Resolution__c
     */
    private static litify_pm__Resolution__c createResolution(litify_pm__Matter__c matter){
        return new litify_pm__Resolution__c(
                Hard_Costs__c=200,
                Soft_Costs__c=100,
                litify_pm__Total_Expenses__c=300,
                litify_pm__Matter__c = matter.Id,
                litify_pm__Settlement_Verdict_Amount__c=50000,
                litify_pm__Total_Damages__c =100,
                AAAA_Fee_Rate__c=33.333333
        );
    }
    /**
     * @param party Account
     * @param matter litify_pm__Matter__c
     *
     * @return litify_pm__Role__c
     */
    private static litify_pm__Role__c createRole(Account party, litify_pm__Matter__c matter){
        return new litify_pm__Role__c(litify_pm__Party__c = party.Id, litify_pm__Matter__c = matter.Id);
    }
    /**
     * @param provider litify_pm__Role__c
     * @param matter litify_pm__Matter__c
     * @param resolution litify_pm__Resolution__c
     *
     * @return litify_pm__Damage__c
     */
    private static litify_pm__Damage__c createDamage(litify_pm__Role__c provider, litify_pm__Matter__c matter, litify_pm__Resolution__c resolution){
        return new litify_pm__Damage__c(
                litify_pm__Provider__c = provider.Id,
                litify_pm__Matter__c = matter.Id,
                litify_pm__Amount_Billed__c = 100);
    }
    /**
     * @param objResolution litify_pm__Resolution__c
     * @param objAccount Account
     * @param objMatter litify_pm__Matter__c
     * @param objRole litify_pm__Role__c
     *
     * @return List<litify_pm__Lien__c>
     */
    private static List<litify_pm__Lien__c> createLiens(litify_pm__Resolution__c objResolution, Account objAccount, litify_pm__Matter__c objMatter, litify_pm__Role__c objRole){
        List<litify_pm__Lien__c> liens = new  List<litify_pm__Lien__c>();
        liens.add(new litify_pm__Lien__c(
                Resolution__c=objResolution.Id,
                litify_pm__lit_Comments__c ='Test1 Comment',
                litify_pm__lit_Amount__c =10,
                litify_pm__lit_Reductions__c = 5.7,
                Date_Issued__c =CURRENT_DATE,
                Payee_Party__c = objAccount.Id,
                litify_pm__lit_Matter__c =objMatter.Id,
                //litify_pm__lit_Payee__c = objRole.Id,
                Type__c ='Lien'));

        liens.add(new litify_pm__Lien__c(
                Resolution__c=objResolution.Id,
                litify_pm__lit_Comments__c ='Test1 Comment2',
                litify_pm__lit_Amount__c =20,
                litify_pm__lit_Reductions__c = 5.7,
                Date_Issued__c =CURRENT_DATE,
                litify_pm__lit_Matter__c =objMatter.Id,
                litify_pm__lit_Payee__c = objRole.Id,
                Type__c ='Lien'));

        return liens;
    }

    private static Map<String, litify_pm__Expense_Type__c> createExpenseTypeByCategory(){
        Map<String, litify_pm__Expense_Type__c> expenseTypeMap = new Map<String, litify_pm__Expense_Type__c>();

        litify_pm__Expense_Type__c hardCost = new litify_pm__Expense_Type__c(Category__c='Hard Cost', Name='Test HardCost');
        litify_pm__Expense_Type__c softCost = new litify_pm__Expense_Type__c(Category__c='Soft Cost', Name='Test SoftCost');
        expenseTypeMap.put(hardCost.Category__c, hardCost);
        expenseTypeMap.put(softCost.Category__c, softCost);

        return expenseTypeMap;
    }

    /**
     * @param expenseTypeMap Map<String, litify_pm__Expense_Type__c>
     * @param matter litify_pm__Matter__c
     *
     * @return List<litify_pm__Expense__c>
     */
    private static List<litify_pm__Expense__c> createExpenses(Map<String, litify_pm__Expense_Type__c> expenseTypeMap, litify_pm__Matter__c matter){
        List<litify_pm__Expense__c> toReturn = new List<litify_pm__Expense__c>();

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 200,
                litify_pm__Date__c = CURRENT_DATE,
                litify_pm__Matter__c = matter.Id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Hard Cost').Id,
                litify_pm__lit_Invoice__c ='Test11',
                Stage__c = 'In-Process'
        ));

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 9000,
                litify_pm__Date__c = CURRENT_DATE,
                litify_pm__Matter__c = matter.Id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Hard Cost').Id,
                litify_pm__lit_Invoice__c ='Test12',
                Stage__c = 'In-Process'
        ));

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = CURRENT_DATE,
                litify_pm__Matter__c = matter.Id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Soft Cost').Id,
                litify_pm__lit_Invoice__c ='Test12',
                Stage__c = 'In-Process'
        ));

        return toReturn;
    }

    private static Map<String, AcctSeed__Billing_Format__c> createBillingFormats(EmailTemplate validEmailTemplate){


        Map<String, AcctSeed__Billing_Format__c> billingFormats = new Map<String, AcctSeed__Billing_Format__c>();
        billingFormats.put('BillingProduct', new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Product',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = validEmailTemplate.DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
        ));

        billingFormats.put('BillingService',new AcctSeed__Billing_Format__c(
                Name = 'Default Billing Service',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = validEmailTemplate.DeveloperName,
                AcctSeed__Type__c = 'Billing',
                AcctSeed__Sort_Field__c = 'Name'
        ));

        billingFormats.put('OutstandingStatement', new AcctSeed__Billing_Format__c (
                Name = 'Billing Outstanding Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = validEmailTemplate.DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Outstanding Statement'
        ));

        billingFormats.put('ActivityStatement', new AcctSeed__Billing_Format__c (
                Name = 'Billing Activity Statement',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = validEmailTemplate.DeveloperName,
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Activity Statement'
        ));

        billingFormats.put('PackingSlip', new AcctSeed__Billing_Format__c (
                Name = 'Default Packing Slip',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Packing Slip'
        ));

        billingFormats.put('PurchaseOrder', new AcctSeed__Billing_Format__c (
                Name = 'Default Purchase Order',
                AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                AcctSeed__Default_Email_Template__c = 'Billing_Email_Template',
                AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                AcctSeed__Type__c = 'Purchase Order'
        ));

        return billingFormats;
    }

    private static List<AcctSeed__Ledger__c> createLedgers(Map<String, AcctSeed__Billing_Format__c> formatByName, List<AcctSeed__GL_Account__c> glAccounts){
        List<AcctSeed__Ledger__c> ledgers = new List<AcctSeed__Ledger__c>();
        for(AcctSeed__GL_Account__c glAccount : glAccounts){
            if(glAccount.Name == '1002-Cash'){
                ledgers.add(new AcctSeed__Ledger__c(
                        Name = 'Trust',
                        AcctSeed__Type__c = 'Budget',
                        AcctSeed__Default_Bank_Account__c = glAccount.Id,
                        AcctSeed__Default_Billing_Format__c = formatByName.get('BillingProduct').Id,
                        AcctSeed__Billing_Outstanding_Statement_Format__c = formatByName.get('OutstandingStatement').Id,
                        AcctSeed__Billing_Activity_Statement_Format__c = formatByName.get('ActivityStatement').Id,
                        AcctSeed__Default_Purchase_Order_Format__c = formatByName.get('PurchaseOrder').Id,
                        AcctSeed__Default_Packing_Slip_Format__c = formatByName.get('PackingSlip').Id
                ));

                ledgers.add(new AcctSeed__Ledger__c(
                        Name = 'FIRM',
                        AcctSeed__Type__c = 'Transactional',
                        AcctSeed__Default_Bank_Account__c = glAccount.Id,
                        AcctSeed__Default_Billing_Format__c = formatByName.get('BillingProduct').Id,
                        AcctSeed__Billing_Outstanding_Statement_Format__c = formatByName.get('OutstandingStatement').Id,
                        AcctSeed__Billing_Activity_Statement_Format__c = formatByName.get('ActivityStatement').Id,
                        AcctSeed__Default_Purchase_Order_Format__c = formatByName.get('PurchaseOrder').Id,
                        AcctSeed__Default_Packing_Slip_Format__c = formatByName.get('PackingSlip').Id
                ));
            }
        }

        return ledgers;
    }

    private static List<AcctSeed__Accounting_Variable__c> createAccountingVariables(){
        List<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        AcctSeed__Accounting_Variable__c objGLV2 = new AcctSeed__Accounting_Variable__c(Name='Location var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2');
        AcctSeed__Accounting_Variable__c objGLV3 = new AcctSeed__Accounting_Variable__c(Name='Department var',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3');
        listGLVariables.add(objGLV2);
        listGLVariables.add(objGLV3);
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(Name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(Name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(Name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(Name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));

        return listGLVariables;
    }

    private static List<AcctSeed__Accounting_Period__c> createAccountingPeriod(){
        List<AcctSeed__Accounting_Period__c> lstAccountingPeriod = new List<AcctSeed__Accounting_Period__c>();
        //Date currentDate = system.today();

        for (Integer i = 0; i < 10; i++) {
            AcctSeed__Accounting_Period__c objAccountingPeriod = new AcctSeed__Accounting_Period__c();
            objAccountingPeriod.AcctSeed__Start_Date__c = CURRENT_DATE
                    .addMonths(i);
            objAccountingPeriod.AcctSeed__End_Date__c = objAccountingPeriod.AcctSeed__Start_Date__c.addMonths(1).toStartOfMonth()
                    - 1;
            objAccountingPeriod.Name = objAccountingPeriod.AcctSeed__Start_Date__c.year() + '-'
                    + (String.valueOf(objAccountingPeriod.AcctSeed__Start_Date__c.month()).length() == 1 ? '0' : '')
                    + objAccountingPeriod.AcctSeed__Start_Date__c.month();

            objAccountingPeriod.AcctSeed__Status__c='Open';
            lstAccountingPeriod.add(objAccountingPeriod);
        }

        return lstAccountingPeriod;
    }
    /**
     * @return Trust_Deposit__c
     */
    private static Trust_Deposit__c createTrustDeposit(){
        return new Trust_Deposit__c(Name='Test', Date__c=CURRENT_DATE, Number_of_Items__c=1, Total__c=100);
    }
    /**
     * @param acct Account
     * @param matter litify_pm__Matter__c
     * @param trustDeposit Trust_Deposit__c
     *
     * @return Trust_Cash_Receipt__c
     */
    private static Trust_Cash_Receipt__c createCashReceipt(Account acct, litify_pm__Matter__c matter, Trust_Deposit__c trustDeposit){
        return new Trust_Cash_Receipt__c(Amount__c=100, Account__c = acct.Id, Matter__c = matter.Id, Trust_Deposit__c = trustDeposit.Id);
    }



}