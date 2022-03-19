#!/usr/bin/env python3
import argparse
from wordcloud import WordCloud

parser = argparse.ArgumentParser()
parser.add_argument("filename", type=str)
args = parser.parse_args()
filename=args.filename

out_file=filename.split(".")[0]+".png"


with open(filename) as f:
    words = f.read()

wc = WordCloud(width=1200, height=800, background_color="white", font_path="/System/Library/Fonts/ヒラギノ角ゴシック W6.ttc")
wc.generate(words)
wc.to_file(out_file)
