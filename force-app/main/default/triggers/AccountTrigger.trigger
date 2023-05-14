// @autor: Oleh Daybov
// @comments: I didn't add trigger handler
//            and didn't added triggerbypass coz no trigger handler (just made it as simle as possible)
trigger AccountTrigger on Account (after insert, after update) {

    private static Boolean isFirstTime = true; // static variable to track trigger recursion
    if (!isFirstTime) {
        return;
    } 

    // after insert
    if (Trigger.isAfter && Trigger.isInsert) {
        createChildAccounts(Trigger.new);
    }

    // after update
    if (Trigger.isAfter && Trigger.isUpdate) {

        Set<Id> mainAccountsSet = new Set<Id>();
        for (Account updatedAccount : Trigger.new) {
            // check if its parent account
            if (updatedAccount.ParentId == null) {
                mainAccountsSet.add(updatedAccount.Id);
            }
        }

        // check if Main accounts exist
        if (!mainAccountsSet.isEmpty()) {
            // Query for existing child accounts
            List<Account> childAccounts = [
                SELECT Id, ParentId  
                FROM Account
                WHERE ParentId IN :mainAccountsSet
            ];
  
            List<Account> legacyAccounts = new List<Account>();
            
            for (Account parentAccount : Trigger.new) {
                
                Boolean childAccountExists = false;
                for (Account childAccount : childAccounts) {

                    if (parentAccount.Id == childAccount.ParentId) {
                        childAccountExists = true;
                        break;
                    }
                }

                if (!childAccountExists) {
                    legacyAccounts.add(parentAccount);
                }
            }
            
            if (!legacyAccounts.isEmpty()) {
                createChildAccounts(legacyAccounts);
            }

        }
    }

    private static void createChildAccounts(List<Account> newAccounts) {
        // for preventing recusion in accounts creation
        isFirstTime = false;

        List<Account> childAccountsToInsert = new List<Account>();

        for (Account parentAccount : newAccounts) {
            // check if the account doesn't have a parent (so it's a main account)
            if (parentAccount.ParentId == null && parentAccount.Id != null) {
                Account childAccount = new Account(
                    Name = parentAccount.Name,
                    ParentId = parentAccount.Id
                );

                childAccountsToInsert.add(childAccount);
            }
            
        }

        if (!childAccountsToInsert.isEmpty()) {
            insert childAccountsToInsert;
        }
    }
}