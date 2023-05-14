@isTest
private class AccountTriggerTest {

    @isTest
    static void testAccountTrigger() {
        // Create a main account
        Account mainAccount = new Account(Name = 'Main Account');
        //  Create another main account
        Account anotherMainAccount = new Account(Name = 'Another Main Account');
        insert new List<Account>{mainAccount, anotherMainAccount};

        // Query the child accounts associated with the main accounts
        List<Account> childAccounts = [
            SELECT Id, ParentId, Name 
            FROM Account
            WHERE ParentId IN :new Set<Id>{mainAccount.Id, anotherMainAccount.Id}
        ];

        System.assert(!childAccounts.isEmpty(), 'We expect child account created.');
        System.assertEquals(2, childAccounts.size(), 'We expect 2 child account created.');

        // find child account for delete
        Account childAccountToDelete = new Account();
        for (Account childAccount : childAccounts) {
            if (childAccount.ParentId == anotherMainAccount.Id) {
                childAccountToDelete = childAccount;
            }
        }

        // deleting child account for legacy account check
        delete childAccountToDelete;
        // update main accounts for check after update
        mainAccount.Name = 'Updated Main Account';
        anotherMainAccount.Name = 'Legacy Account Now';
        // its multiple to check all the casess and have 100% coverage
        update new List<Account>{mainAccount, anotherMainAccount};
        // refresh child accounts
        childAccounts = [
            SELECT Id, ParentId, Name 
            FROM Account
            WHERE ParentId IN :new Set<Id>{mainAccount.Id, anotherMainAccount.Id}
        ];

        System.assert(!childAccounts.isEmpty(), 'We expect child account created.');
        System.assertEquals(2, childAccounts.size(), 'We expect 2 child account created.');
    }
}