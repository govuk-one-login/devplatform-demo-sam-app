import socket

import requests
from flask import Flask

app = Flask(__name__)


@app.route("/")
def hello():
    print("This is a log message")
    return "Hello World!"
