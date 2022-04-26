@IsTest
public class OrderSelector_Test {
    @IsTest
    static void exception_thrown_for_null_order_id(){
        Test.startTest();
        try {
            OrderSelector.getOrderByOrderId(null);
        } catch (Exception exc) {
            System.assertEquals('Order id is required', exc.getMessage(), 'exeption thrown for null id');
        }
        Test.stopTest();
    }

    @IsTest
    static void order_returned_for_correct_id(){
        Account acc = TestDataFactory.createAccount(true, 'test account');
        Contract contract = TestDataFactory.createContract(true, acc.Id);
        Order order = TestDataFactory.createOrder(true, acc.Id, contract.Id);

        Test.startTest();
        System.assertEquals(order.Id, OrderSelector.getOrderByOrderId(order.Id).Id, 'record returned');
        Test.stopTest();
    }
}
