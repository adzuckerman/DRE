@isTest
public class AccountAllHandlerTest {
    
    private static testmethod void testAccountAllInsert(){
    
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
    }
}