#!/usr/bin/env python

from flask import Flask,redirect,request
app = Flask(__name__, static_url_path='/static')
from os import path
from subprocess import call
import pysrt

@app.route('/')
def hello():
  return "example usage: http://localhost:5000/segment?start=0&end=17&video=17-1.mp4"

@app.route('/segmentsubtitle')
def segmentsubtitle():
  args = request.args
  if 'subtitle' not in args or 'start' not in args or 'end' not in args:
    return 'missing args'
  subtitle = args['subtitle']
  start = int(args['start'])
  end = int(args['end'])
  subtitle_basename,subtitle_ext = subtitle.rsplit('.', 1)
  if subtitle_ext != 'srt':
    return 'expected subtitle in srt format'
  orig_subtitlename = subtitle_basename + '.' + subtitle_ext
  orig_subtitlepath = 'static/' + orig_subtitlename
  #segmented_subtitlename = subtitle_basename + '_' + str(start) + '_' + str(end) + '.txt'
  #segmented_subtitlepath = 'static/' + segmented_subtitlename
  if not path.exists(orig_subtitlepath):
    return 'no such path: ' + orig_subtitlepath
  #if not path.exists(segmented_subtitlepath):
  #  return 'need to generate: ' + segmented_subtitlepath
  #print 'redirect to ' + segmented_subtitlename
  #return redirect('http://localhost:8080/' + segmented_subtitlename)
  output = []
  subs = pysrt.open(orig_subtitlepath)
  for sub in subs:
    start_time_seconds = float(sub.start.ordinal)/1000.0
    end_time_seconds = float(sub.end.ordinal)/1000.0
    mid_time_seconds = (start_time_seconds + end_time_seconds) / 2.0
    if start <= mid_time_seconds <= end:
    #if start <= start_time_seconds <= end or start <= end_time_seconds <= end:
      output.append(sub.text)
  return '\n'.join(output)



@app.route('/segmentvideo')
def segmentvideo():
  #return 'segment!'
  #return app.send_static_file('17-1.mp4')
  args = request.args
  if 'video' not in args or 'start' not in args or 'end' not in args:
    return 'missing args'
  video = args['video']
  video_basename,video_ext = video.rsplit('.', 1)
  start = int(args['start'])
  end = int(args['end'])
  orig_videoname = video_basename + '.' + video_ext
  orig_videopath = 'static/' + orig_videoname
  segmented_videoname = video_basename + '_' + str(start) + '_' + str(end) + '.webm'
  segmented_videopath = 'static/' + segmented_videoname
  if not path.exists(orig_videopath):
    return 'no such path: ' + orig_videopath
  if not path.exists(segmented_videopath):
    options = []
    if segmented_videoname.endswith('.webm'):
      options = ['-cpu-used', '-5', '-deadline', 'realtime']
    print 'encoding, output to ' + segmented_videoname
    call(['C:/ffmpeg/ffmpeg.exe', '-i', orig_videopath] + options + ['-ss', str(start), '-t', str(end-start), segmented_videopath])
    #return 'need to generate segmented video: ' + segmented_videopath
  print 'redirect to ' + segmented_videoname
  return redirect('http://localhost:8080/' + segmented_videoname, code=302)

if __name__ == '__main__':
  app.run(debug=True)
