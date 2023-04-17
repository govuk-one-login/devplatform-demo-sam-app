package helloworld;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import org.junit.Test;

public class AppTest {
  @Test
  public void successfulResponse() {
    App app = new App();
    String result = app.handleRequest(null, null);
    assertNotNull(result);
    assertEquals("Hello World", result);
  }
}