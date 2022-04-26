public with sharing class Result {
    public Boolean IsSuccess {get; private set;}
    public Boolean IsFailure {get; private set;}

    public String Payload {get; private set;}

    private Result(Boolean isSuccess, String payload){
        if(!isSuccess && String.isBlank(payload)){
            throw new InvalidOperationException();
        }

        this.IsSuccess = isSuccess;
        this.IsFailure = !isSuccess;
        this.Payload = payload;
    }

    public static Result Fail(String message){
        return new Result(false, message);
    }

    public static Result OK(){
        return new Result(true, '');
    }

    public static Result Combine(List<Result> results){
        for(Result r : results){
            if(!r.IsSuccess){
                return r;
            }
        }
        return OK();
    }

    private class InvalidOperationException extends Exception{}
}