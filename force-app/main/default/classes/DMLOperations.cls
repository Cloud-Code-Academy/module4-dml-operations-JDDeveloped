/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author John Duffy
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account johnAccount = new Account();
        // Set some fields on the Account
        johnAccount.Name = 'John';
        johnAccount.Industry = 'Electronics';
        johnAccount.type = 'Prospect';
     
        // Insert the Account into the database
        Insert johnAccount;

        // Return the Id of the newly created Account
        return johnAccount.Id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account inlineaccount = new Account(Name = name, Industry = industry);
        // Insert the Account into the database
        insert inlineaccount;

        // Insert the Account
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact newContact = new Contact();

        // Set some fields on the Contact
        // Set the AccountId field to the given accountId
            newContact.FirstName = 'Jack';
            newContact.LastName = 'Brown';
            newContact.Email = 'Fake@email.com';
            newContact.AccountId = accountId;
        

        // Insert the Contact into the database
        insert newContact;

        // Return the Id of the newly created Contact
        return newContact.Id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        // [SELECT Id FROM Contact WHERE Id = :contactId]
        Contact contactToUpdate = [SELECT Id, LastName FROM Contact WHERE Id = :contactId LIMIT 1];

        // Update the Contact's last name
        contactToUpdate.LastName = newLastName;

        // Update the Contact in the database
        update contactToUpdate;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        // [SELECT Id FROM Opportunity WHERE Id = :oppId]
        Opportunity opportunityToUpdate = [SELECT Id, StageName FROM Opportunity WHERE Id = :oppId LIMIT 1];

        // Update the Opportunity's stage
        opportunityToUpdate.StageName = newStage;

        // Update the Opportunity in the database
        update opportunityToUpdate;

        // Update the Opportunity's stage

        // Update the Opportunity in the database
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        // [SELECT Id FROM Account WHERE Id = :accountId]
        Account accountToUpdate = [SELECT Id, Name, Industry FROM Account WHERE Id = :accountId LIMIT 1];

        // Update the Name and Industry
        accountToUpdate.Name = newName;
        accountToUpdate.Industry = newIndustry;

        // Update the Account with the given Id with the new name and industry
        update accountToUpdate;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for( Opportunity opp: opportunities){
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
			opp.Amount = 50000;
        }
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * HINT: The account may or may not exists in the database but is required for opportunity creation. Consider how upsert operation can help with this.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];
        if(accounts.isEmpty()){
            Account newAcc = new Account(Name = accountName);
            Database.insert(newAcc);
            accounts.add(newAcc);
        } 
        List<Opportunity> opportunitiesThatExist = [SELECT Name, Id FROM Opportunity WHERE Name IN :oppNames AND AccountId = :accounts[0].Id];

        for(String oppName: oppNames){
            Boolean found = false;
                for(Opportunity opp: opportunitiesThatExist){
                    if(opp.Name.compareTo(oppName) == 0){
                        found = true;
                        opp.AccountId = accounts[0].Id;
                        break;
                    }
                }
            if(found == false){
                Opportunity newOpp = new Opportunity();
                newOpp.Name = oppName;
                newOpp.AccountId = accounts[0].Id;
                newOpp.StageName = 'Prospecting';
                newOpp.CloseDate = Date.today().addMonths(2); 
                opportunitiesThatExist.add(newOpp);
            }
        }
        Database.upsert(opportunitiesThatExist); 
    }
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {

        Account acc; 
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

        if (!accounts.isEmpty()) {
            // If the Account exists, update the description to "Updated Account"
            acc = accounts[0];
            acc.Description = 'Updated Account';
        } else {
            // If no such Account exists, create a new Account and set the description to "New Account"
            acc = new Account(
                Name = accountName,
                Description = 'New Account'
            );
        }
    
        // Upsert the Account
        upsert acc;
    
        return acc;
    }

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {

        String nameOfAccount;
        for(Contact contact : contactsToUpsert){
            nameOfAccount = contact.LastName; 
        }

		// Get the account based on the name or create one if it doesn't exist
        List<Account> accounts = [SELECT Id FROM Account WHERE Name = :nameOfAccount];
        if(accounts.isEmpty()){
            Account newAccount = new Account(Name = nameOfAccount);
            Database.upsert(newAccount);
        } 

		// Link the Contact to its Account using the Account Id
        String accountId;
        for(Contact contact : contactsToUpsert){
            for(Account account : ([SELECT Id FROM Account WHERE Name = :contact.LastName])){
                accountId = account.Id;
            }
            contact.AccountId = accountId;

        }

		// Upsert the Contacts
        Database.upsert(contactsToUpsert);

}

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {

        List<Lead> leadsToInsert = new List<Lead>();
        // Loop through each Lead name
        for (String name : leadNames) {
            Lead newLead = new Lead(
                FirstName = name, // Example: Using the lead name as first name
                LastName = 'Doe', // Example: Using 'Doe' as last name
                Company = 'Sample Company' // Example: Using 'Sample Company' as company name
            );
            leadsToInsert.add(newLead);
        }
        // Insert the Leads
        insert leadsToInsert;
        // Delete the Leads
        delete leadsToInsert;

    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
       
        List<Case> casesToInstert = new List<Case>();
       
       for (Integer i = 0; i < numOfCases; i++) {
        Case newCase = new Case(
            AccountId = accountId, // Associate case with the specified Account
            Subject = 'Sample Case ' + (i + 1), // Example: Generating a unique subject for each case
            Status = 'New' // Example: Setting status as 'New'
        );
        casesToInstert.add(newCase);
    }

    // Insert the cases
    insert casesToInstert;

    // Delete the cases
    delete casesToInstert;
}
}