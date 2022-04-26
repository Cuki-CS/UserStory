@IsTest
public class OrderManagementController_Test {
    @IsTest
    public static void exception_raised_for_null_arguments(){
        Test.startTest();
        try {
           new OrderManagementController(null, null);
        }
        catch(Exception exc) {
            System.assertEquals('Arguments cannot be null', exc.getMessage(), 'exception raised for null arguments');
        }
        Test.stopTest();
    }

    @IsTest
    public static void exception_raised_for_empty_arguments(){
        Test.startTest();
        try {
           new OrderManagementController(new List<Object>(), '');
        }
        catch(Exception exc) {
            System.assertEquals('Arguments cannot be null', exc.getMessage(), 'exception raised for empty arguments');
        }
        Test.stopTest();
    }

    @IsTest
    static void order_confirmed_by_service_and_activated(){
        Pricebook2 standardPricebook = TestDataFactory.createPriceBook(true);
        Product2 prod2 = TestDataFactory.createActiveProduct2(true, 'burek product');
        PricebookEntry pbEntry = TestDataFactory.createActivePriceBookEntry(true, 10, standardPriceBook.Id, prod2.Id);
        String accountId = TestDataFactory.createAccount(true, 'burek').Id;
        Contract contract = TestDataFactory.createContract(true, accountId);
        contract.Status = 'Activated';
        UPDATE contract;
        Order order = TestDataFactory.createOrder(false, accountId, contract.Id);
        order.Pricebook2Id = standardPricebook.Id;
        INSERT order;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = 'https://burek.requestcatcher.com/test';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Map<String, Object> inputParameters = new Map<String,Object>{
            'orderItems' => new List<Object>{
                new Map<String, Object>{
                    'Id' => pbEntry.Id,
                    'Name' => prod2.Name,
                    'Pricebook2Id' => standardPricebook.Id,
                    'ProductCode' => prod2.ProductCode,
                    'Quantity' => 1,
                    'TotalPrice' => 25000,
                    'UnitPrice' => 25000
                }
            },
            'orderId' => order.Id
        };

        Test.setMock(HttpCalloutMock.class, new RestOKMock());
        Test.startTest();
        OrderManagementController orderController = new OrderManagementController((List<Object>)inputParameters.get('orderItems'), (String)inputParameters.get('orderId'));
        orderController.executeCalloutToRestServiceAndReturnResponse();
        Test.stopTest();

        System.assertEquals('Activated', [SELECT Status FROM Order LIMIT 1].Status, 'Order is activated');
    }

    @IsTest
    static void order_rejected_by_service_and_notactivated(){
        Pricebook2 standardPricebook = TestDataFactory.createPriceBook(true);
        Product2 prod2 = TestDataFactory.createActiveProduct2(true, 'burek product');
        PricebookEntry pbEntry = TestDataFactory.createActivePriceBookEntry(true, 10, standardPriceBook.Id, prod2.Id);
        String accountId = TestDataFactory.createAccount(true, 'burek').Id;
        Contract contract = TestDataFactory.createContract(true, accountId);
        contract.Status = 'Activated';
        UPDATE contract;
        Order order = TestDataFactory.createOrder(false, accountId, contract.Id);
        order.Pricebook2Id = standardPricebook.Id;
        INSERT order;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        req.requestURI = 'https://burek.requestcatcher.com/test';
        req.httpMethod = 'POST';

        RestContext.request = req;
        RestContext.response = res;

        Map<String, Object> inputParameters = new Map<String,Object>{
            'orderItems' => new List<Object>{
                new Map<String, Object>{
                    'Id' => pbEntry.Id,
                    'Name' => prod2.Name,
                    'Pricebook2Id' => standardPricebook.Id,
                    'ProductCode' => prod2.ProductCode,
                    'Quantity' => 1,
                    'TotalPrice' => 25000,
                    'UnitPrice' => 25000
                }
            },
            'orderId' => order.Id
        };

        Test.setMock(HttpCalloutMock.class, new RestERRORMock());
        Test.startTest();
        OrderManagementController orderController = new OrderManagementController((List<Object>)inputParameters.get('orderItems'), (String)inputParameters.get('orderId'));
        orderController.executeCalloutToRestServiceAndReturnResponse();
        Test.stopTest();

        System.assertEquals('Draft', [SELECT Status FROM Order LIMIT 1].Status, 'Order is activated');
    }

    private class RestOKMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('');
            res.setStatusCode(200);
            return res;
        }
    }

    private class RestERRORMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody('');
            res.setStatusCode(500);
            return res;
        }
    }
}