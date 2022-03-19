#!/usr/bin/env python3
import argparse
from html.parser import HTMLParser
from html.entities import name2codepoint

parser = argparse.ArgumentParser()
parser.add_argument("filename", type=str)
args = parser.parse_args()
filename=args.filename

class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        for attr in attrs:
            if "title" in attr:
                print(attr)

    def handle_data(self, data):
        print(data)

parser = MyHTMLParser()
with open(filename, 'r', encoding='utf-8') as f:
    for line in f.readlines():
        if line.find("title") >= 0:
            #print(line)
            parser.feed(line)
            #print(parser.data)

