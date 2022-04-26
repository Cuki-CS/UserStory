@IsTest
public class LWCImplementationSelector_Test {
    @IsTest
    static void throwing_exception_for_incorrect_parameter(){
        Test.startTest();
        try {
            LWCImplementationSelector.getImplementatationForParameters(null);
        } catch (Exception exc) {
            System.assertEquals('Script-thrown exception', exc.getMessage(), 'exception is thrown for null parameters');
        }
        Test.stopTest();
    }

    @IsTest
    static void throwing_exception_for_unsupported_operation(){
        Test.startTest();
        try {
            LWCImplementationSelector.getImplementatationForParameters(new Map<String, Object>{'some new method' => true});
        } catch (Exception exc) {
            System.assertEquals('Script-thrown exception', exc.getMessage(), 'exception is thrown for unsupported operation');
        }
        Test.stopTest();
    }

    @IsTest
    static void return_empty_list_of_products_for_non_existing_products(){
        Test.startTest();
        List<PricebookEntry> returnedResult = (List<PricebookEntry>)LWCImplementationSelector.getImplementatationForParameters(new Map<String, Object>{'getDistinctPriceBookEntries' => true});
        System.assertEquals(0, returnedResult.size(), 'empty list returned');
        Test.stopTest();
    }

    @IsTest
    static void return_list_of_products(){
        Pricebook2 standardPricebook = TestDataFactory.createPriceBook(true);
        Product2 prod2 = TestDataFactory.createActiveProduct2(true, 'burek product');
        PricebookEntry pbEntry = TestDataFactory.createActivePriceBookEntry(true, 10, standardPriceBook.Id, prod2.Id);

        Test.startTest();
        List<PricebookEntry> returnedResult = (List<PricebookEntry>)LWCImplementationSelector.getImplementatationForParameters(new Map<String, Object>{'getDistinctPriceBookEntries' => true});
        System.assertEquals(1, returnedResult.size(), 'list of products returned');
        Test.stopTest();
    }

    @IsTest
    static void return_order_status(){
        String accountId = TestDataFactory.createAccount(true, 'burek').Id;
        String contractId = TestDataFactory.createContract(true, accountId).Id;
        Order order = TestDataFactory.createOrder(true, accountId, contractId);

        Test.startTest();
        String returnedOrder = (String)LWCImplementationSelector.getImplementatationForParameters(new Map<String, Object>{'selectOrderStatus' => true, 'orderId' => order.Id});
        System.assert(returnedOrder.contains('Draft'), 'Status is Draft');
        Test.stopTest();
    }

    @IsTest
    static void execute_remote_call_and_update_order_status_on_confirm(){
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
            'orderId' => order.Id,
            'callOrderActivationService' => true
        };

        Test.setMock(HttpCalloutMock.class, new RestOKMock());

        Test.startTest();
        Object returnedOrder = LWCImplementationSelector.getImplementatationForParameters(inputParameters);
        Test.stopTest();
        System.assertEquals('Activated', [SELECT Status FROM Order LIMIT 1].Status, 'Order is activated');
    }

    @IsTest
    static void execute_remote_call_and_handle_exception_flow(){
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
            'orderId' => order.Id,
            'callOrderActivationService' => true
        };

        Test.setMock(HttpCalloutMock.class, new RestERRORMock());

        Test.startTest();
        Object returnedResponse = LWCImplementationSelector.getImplementatationForParameters(inputParameters);
        Test.stopTest();
        System.assert(JSON.serialize(returnedResponse).contains('Callout failed'), 'Error is returned');
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
