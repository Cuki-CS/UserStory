@IsTest
public class TestDataFactory {
    public static Account createAccount(Boolean dmlExecute, String name){
        Account acc = new Account();
        acc.Name = name;

        if(dmlExecute){
            INSERT acc;
        }
        return acc;
    }

    public static Contract createContract(Boolean dmlExecute, Id accountId){
        Contract contract = new Contract();
        contract.StartDate = Date.today();
        contract.ContractTerm = 12;
        contract.AccountId = accountId;
        contract.Status = 'Draft';
        if(dmlExecute){
            INSERT contract;
        }
        return contract;
    }

    public static Order createOrder(Boolean dmlExecute, Id accountId, Id contractId){
        Order order = new Order();
        order.AccountId = accountId;
        order.ContractId = contractId;
        order.EffectiveDate = Date.today();
        order.Status = 'Draft';

        if(dmlExecute){
            INSERT order;
        }
        return order;
    }

    public static Pricebook2 createPriceBook(Boolean dmlExecute){
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 standardPricebook = new Pricebook2(
            Id = pricebookId,
            IsActive = true
        );

        if(dmlExecute){
            UPDATE standardPricebook;
        }

        return standardPricebook;
    }

    public static Product2 createActiveProduct2(Boolean dmlExecute, String name){
        Product2 prod2 = new Product2();
        prod2.Name = name;
        prod2.IsActive = true;
        prod2.ProductCode = 'test';

        if(dmlExecute){
            INSERT prod2;
        }

        return prod2;
    }

    public static PricebookEntry createActivePriceBookEntry(Boolean dmlExecute, Decimal unitPrice, Id priceBook2Id, Id product2Id){
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.IsActive = true;
        pbEntry.UnitPrice = unitPrice;
        pbEntry.Pricebook2Id = priceBook2Id;
        pbEntry.Product2Id = product2Id;

        if(dmlExecute){
            INSERT pbEntry;
        }

        return pbEntry;
    }
}
