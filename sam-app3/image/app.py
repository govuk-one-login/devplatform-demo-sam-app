from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    print("This is a log message")
    return "Hello World!"

@app.route("/test")
def test():
    print("This is a test call")
    return "Test successful!"
