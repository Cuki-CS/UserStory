@IsTest
public class PriceBookEntrySelector_Test {
    @IsTest
    static void selector_method_exists(){
        Test.startTest();
        System.assertNotEquals(null, PriceBookEntrySelector.getOrderableActivePriceBookEntryRecordsOrEmptyList(), 'method exists and returns non null result');
        Test.stopTest();
    }

    @IsTest
    static void empty_list_returned_for_non_existing_records(){
        Test.startTest();
        System.assertEquals(true, PriceBookEntrySelector.getOrderableActivePriceBookEntryRecordsOrEmptyList().isEmpty(), 'returned list is empty');
        Test.stopTest();
    }

    @IsTest
    static void records_returned_for_filter_criteria(){
        Pricebook2 standardPricebook = TestDataFactory.createPriceBook(true);
        Product2 prod2 = TestDataFactory.createActiveProduct2(true, 'burek product');
        PricebookEntry pbEntry = TestDataFactory.createActivePriceBookEntry(true, 10, standardPriceBook.Id, prod2.Id);

        Test.startTest();
        System.assertEquals(10, PriceBookEntrySelector.getOrderableActivePriceBookEntryRecordsOrEmptyList().values()[0].UnitPrice, 'Price of returned product is 10');
        Test.stopTest();
    }
}
