package helloworld;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;
import com.amazonaws.services.lambda.runtime.LambdaLogger;

import java.util.Map;

// Handler value: example.Handler
public class App implements RequestHandler<Map<String,String>, String>{

  @Override
  public String handleRequest(Map<String,String> event, Context context)
  {
    return "Hello World";
  }
}