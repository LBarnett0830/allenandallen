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
    public static final String USER_NAME_PATTERN = 'user%';

    private static final Id STANDARD_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
    private static final Id SYS_ADMIN_PROFILE_ID = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;

    public static void createTestData(){
        User adminUser = createAdminUser();
        adminUser.Expense_Approval_Limit__c = 0;
        User principalUser = createUserWithName('Principal');
        principalUser.Expense_Approval_Limit__c = 0;
        User litigationUser = createUserWithName('Litigation');
        litigationUser.Expense_Approval_Limit__c = 0;
        try{
            insert new List<User>{ adminUser, principalUser, litigationUser };
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating Test Admin User: ' + ex.getMessage());
        }

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

        try{
            insert testAccounts;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating Test Accounts ' + ex.getMessage());
        }

        Department__c department = createDepartment(adminUser);
        try{
            insert department;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating Department: ' + ex.getMessage());
        }

        List<AcctSeed__GL_Account__c> standardGLAccounts = createGLAccounts(department);
        try{
            insert standardGLAccounts;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating standardGLAccounts: ' + ex.getMessage());
        }

        Firm_Ledger_COS_Fee_Revenue_GL_Account__c firmLedger = createLedgerRevenue();
        try{
            insert firmLedger;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating firmLedger: ' + ex.getMessage());
        }

        List<AcctSeed__GL_Account__c> firmLedgerAccounts = createLedgerGLAccounts(firmLedger, department);
        try{
            insert firmLedgerAccounts;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating firmLedgerAccounts: ' + ex.getMessage());
        }

        litify_pm__Matter__c matter = createMatter(test1);
        //matter.litify_pm__Principal_Attorney__c = principalUser.Id;
        //matter.Litigation_Assistant__c = litigationUser.Id;
        try{
            insert matter;
            matter.litify_pm__Principal_Attorney__c = principalUser.Id;
            matter.Litigation_Assistant__c = litigationUser.Id;
            try{
                //update matter;
                System.debug(LoggingLevel.INFO, 'Update Attempt Here');
            }catch (Exception ex){
                System.debug(LoggingLevel.ERROR, ex.getMessage());
                System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
                throw new AuraHandledException('Error Updating matter: ' + ex.getMessage());
            }
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating matter: ' + ex.getMessage());
        }

        litify_pm__Resolution__c resolution = createResolution(matter);
        try{
            insert resolution;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating resolution: ' + ex.getMessage());
        }
        litify_pm__Role__c role = createRole(test1, matter);
        try{
            insert role;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating role: ' + ex.getMessage());
        }
        litify_pm__Damage__c damage = createDamage(role, matter, resolution);
        try{
            insert damage;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating damage: ' + ex.getMessage());
        }

        List<litify_pm__Lien__c> liens = createLiens(resolution, test1, matter, role);
        try{
            insert liens;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating liens: ' + ex.getMessage());
        }

        Map<String, litify_pm__Expense_Type__c> expenseByCategory = createExpenseTypeByCategory();
        try{
            insert expenseByCategory.values();
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating expenseByCategory: ' + ex.getMessage());
        }

        List<litify_pm__Expense__c> expenses = createExpenses(expenseByCategory, matter);
        try{
            insert expenses;
        }catch (Exception ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            throw new AuraHandledException('Error Creating expenses: ' + ex.getMessage());
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

    public static List<Account> getAccountsFromDb(){
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

    public static Department__c createDepartment(User u){
        return new Department__c(Director__c = u.Id);
    }

    public static List<AcctSeed__GL_Account__c> createGLAccounts(Department__c department){
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

    public static Firm_Ledger_COS_Fee_Revenue_GL_Account__c createLedgerRevenue(){
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
    public static List<AcctSeed__GL_Account__c> createLedgerGLAccounts(Firm_Ledger_COS_Fee_Revenue_GL_Account__c ledger, Department__c department){
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
     *
     * @return litify_pm__Matter__c
     */
    public static litify_pm__Matter__c createMatter(Account clientAccount){
        return new litify_pm__Matter__c(litify_pm__Client__c = clientAccount.Id, OwnerId = UserInfo.getUserId());
    }
    /**
     * @param matter litify_pm__Matter__c
     *
     * @return litify_pm__Resolution__c
     */
    public static litify_pm__Resolution__c createResolution(litify_pm__Matter__c matter){
        return new litify_pm__Resolution__c(
                Hard_Costs__c=200,
                Soft_Costs__c=100,
                litify_pm__Total_Expenses__c=300,
                litify_pm__Matter__c = matter.id,
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
    public static litify_pm__Role__c createRole(Account party, litify_pm__Matter__c matter){
        return new litify_pm__Role__c(litify_pm__Party__c = party.Id, litify_pm__Matter__c = matter.Id);
    }
    /**
     * @param provider litify_pm__Role__c
     * @param matter litify_pm__Matter__c
     * @param resolution litify_pm__Resolution__c
     *
     * @return litify_pm__Damage__c
     */
    public static litify_pm__Damage__c createDamage(litify_pm__Role__c provider, litify_pm__Matter__c matter, litify_pm__Resolution__c resolution){
        return new litify_pm__Damage__c(
                litify_pm__Provider__c = provider.Id,
                litify_pm__Matter__c = matter.Id,
                litify_pm__Amount_Billed__c = 100,
                Resolution__c = resolution.Id);
    }
    /**
     * @param objResolution litify_pm__Resolution__c
     * @param objAccount Account
     * @param objMatter litify_pm__Matter__c
     * @param objRole litify_pm__Role__c
     *
     * @return List<litify_pm__Lien__c>
     */
    public static List<litify_pm__Lien__c> createLiens(litify_pm__Resolution__c objResolution, Account objAccount, litify_pm__Matter__c objMatter, litify_pm__Role__c objRole){
        List<litify_pm__Lien__c> liens = new  List<litify_pm__Lien__c>();
        liens.add(new litify_pm__Lien__c(
                Resolution__c=objResolution.id,
                litify_pm__lit_Comments__c ='Test1 Comment',
                litify_pm__lit_Amount__c =10,
                litify_pm__lit_Reductions__c = 5.7,
                Date_Issued__c =system.today(),
                Payee_Party__c = objAccount.Id,
                litify_pm__lit_Matter__c =objMatter.id,
                //litify_pm__lit_Payee__c = objRole.id,
                Type__c ='Lien'));

        liens.add(new litify_pm__Lien__c(
                Resolution__c=objResolution.id,
                litify_pm__lit_Comments__c ='Test1 Comment2',
                litify_pm__lit_Amount__c =20,
                litify_pm__lit_Reductions__c = 5.7,
                Date_Issued__c =system.today(),
                litify_pm__lit_Matter__c =objMatter.id,
                litify_pm__lit_Payee__c = objRole.id,
                Type__c ='Lien'));

        return liens;
    }

    public static Map<String, litify_pm__Expense_Type__c> createExpenseTypeByCategory(){
        Map<String, litify_pm__Expense_Type__c> expenseTypeMap = new Map<String, litify_pm__Expense_Type__c>();

        litify_pm__Expense_Type__c hardCost = new litify_pm__Expense_Type__c(Category__c='Hard Cost');
        litify_pm__Expense_Type__c softCost = new litify_pm__Expense_Type__c(Category__c='Soft Cost');
        expenseTypeMap.put(hardCost.Category__c, hardCost);
        expenseTypeMap.put(softCost.Category__c, softCost);

        return expenseTypeMap;
    }

    public static List<litify_pm__Expense__c> createExpenses(Map<String, litify_pm__Expense_Type__c> expenseTypeMap, litify_pm__Matter__c matter){
        List<litify_pm__Expense__c> toReturn = new List<litify_pm__Expense__c>();

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 200,
                litify_pm__Date__c = System.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Hard Cost').Id,
                litify_pm__lit_Invoice__c ='Test11',
                Stage__c = 'In-Process'
        ));

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 9000,
                litify_pm__Date__c = System.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Hard Cost').Id,
                litify_pm__lit_Invoice__c ='Test12',
                Stage__c = 'In-Process'
        ));

        toReturn.add(new litify_pm__Expense__c(
                litify_pm__Amount__c = 100,
                litify_pm__Date__c = System.today(),
                litify_pm__Matter__c = matter.id,
                litify_pm__ExpenseType2__c = expenseTypeMap.get('Soft Cost').Id,
                litify_pm__lit_Invoice__c ='Test12',
                Stage__c = 'In-Process'
        ));

        return toReturn;
    }



}