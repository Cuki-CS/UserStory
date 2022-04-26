@IsTest
public class Result_Test {
    @IsTest
    static void exception_thrown_for_blank_error(){
        Test.startTest();
        try {
            Result result = Result.Fail('');
        } catch (Exception exc) {
            System.assertNotEquals(null, exc, 'exception is raised for empty error');
        }
        Test.stopTest();
    }

    @IsTest
    static void ok_result_raised(){
        Test.startTest();
        Result result = Result.OK();
        System.assertEquals(true, result.IsSuccess, 'successfull result');
        System.assertEquals(false, result.IsFailure, 'result is not success');
        Test.stopTest();
    }

    @IsTest
    static void fail_result_raised(){
        Test.startTest();
        Result result = Result.Fail('message');
        System.assertEquals(false, result.IsSuccess, 'result is not success');
        System.assertEquals(true, result.IsFailure, 'result is failure');
        System.assertEquals('message', result.Error, 'message is the passed error');
        Test.stopTest();
    }

    @IsTest
    static void combined_results_are_failed(){
        Test.startTest();
        Result combinedResult = Result.Combine(new List<Result>{Result.Fail('message'), Result.OK()});

        System.assertEquals(false, combinedResult.IsSuccess, 'result is not success');
        System.assertEquals(true, combinedResult.IsFailure, 'result is failure');
        System.assertEquals('message', combinedResult.Error, 'message is the passed error');
        Test.stopTest();
    }

    @IsTest
    static void combined_results_are_ok(){
        Test.startTest();
        Result combinedResult = Result.Combine(new List<Result>{Result.OK(), Result.OK()});

        System.assertEquals(true, combinedResult.IsSuccess, 'result is success');
        System.assertEquals(false, combinedResult.IsFailure, 'result is not failure');
        System.assertEquals('', combinedResult.Error, 'error is blank for ok result');
        Test.stopTest();
    }
}