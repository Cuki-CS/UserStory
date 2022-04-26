@IsTest
public class OrderManagementAPIArgs_Test {
    @IsTest
    public static void exception_raised_for_null_payload(){
        Test.startTest();
        try {
            new OrderManagementAPIArgs(null, null);
        }
        catch(Exception exc) {
            System.assertEquals('Order payload or order cannot be null or empty', exc.getMessage(), 'exception raised for null payload');
        }
        Test.stopTest();
    }

    @IsTest
    public static void exception_raised_for_empty_payload(){
        Test.startTest();
        try {
            new OrderManagementAPIArgs(new List<Object>(), null);
        }
        catch(Exception exc) {
            System.assertEquals('Order payload or order cannot be null or empty', exc.getMessage(), 'exception raised for empty payload');
        }
        Test.stopTest();
    }

    @IsTest
    static void return_value_for_correct_payload(){
        String accountId = TestDataFactory.createAccount(true, 'burek').Id;
        String contractId = TestDataFactory.createContract(true, accountId).Id;
        Order order = TestDataFactory.createOrder(true, accountId, contractId);
        Test.startTest();
        OrderManagementAPIArgs args = new OrderManagementAPIArgs(new List<Object>{new Map<String, Object>{'testkey' => 'testvalue'}}, order);
        System.assertNotEquals(null, args.order, 'value is returned for valid key');
        Test.stopTest(); 
    }
}
