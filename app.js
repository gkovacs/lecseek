// Generated by LiveScript 1.2.0
(function(){
  var express, app, path, fs, parser, slides_human_readable, to_numeric_time, srt_time_to_seconds, subtitle_file_to_data, getTextAtTime, spawn, makeSegment, to_machine_readable_timestamps, slides;
  express = require('express');
  app = express();
  path = require('path');
  fs = require('fs');
  parser = require('subtitles-parser');
  app.use(express['static'](path.join(__dirname, 'static')));
  slides_human_readable = {
    start: '0:00',
    end: '14:53',
    file: '17-1.mp4',
    subtitle_file: '17-1.srt',
    children: [
      {
        start: '0:00',
        end: '0:21'
      }, {
        start: '0:21',
        end: '2:53'
      }, {
        start: '2:53',
        end: '3:32'
      }, {
        start: '3:32',
        end: '4:41'
      }, {
        start: '4:41',
        end: '6:28'
      }, {
        start: '6:28',
        end: '8:16'
      }, {
        start: '8:16',
        end: '11:12'
      }, {
        start: '11:12',
        end: '12:38'
      }, {
        start: '12:38',
        end: '14:15'
      }, {
        start: '14:15',
        end: '14:53'
      }
    ]
  };
  to_numeric_time = function(str){
    var ref$, min, sec;
    ref$ = str.split(':'), min = ref$[0], sec = ref$[1];
    min = parseInt(min);
    sec = parseInt(sec);
    return min * 60 + sec;
  };
  srt_time_to_seconds = function(str){
    var ref$, hour, minute, sec, millisec;
    ref$ = str.split(':'), hour = ref$[0], minute = ref$[1], sec = ref$[2];
    ref$ = sec.split(','), sec = ref$[0], millisec = ref$[1];
    hour = parseInt(hour);
    minute = parseInt(minute);
    sec = parseInt(sec);
    millisec = parseInt(millisec);
    return hour * 3600 + minute * 60 + sec + millisec / 1000.0;
  };
  subtitle_file_to_data = {};
  getTextAtTime = function(subtitle_file, start, end){
    var output, data, subtitleText, i$, len$, sub, start_time, end_time, mid_time;
    output = [];
    data = subtitle_file_to_data[subtitle_file];
    if (data == null) {
      subtitleText = fs.readFileSync('static/' + subtitle_file, 'utf-8');
      data = parser.fromSrt(subtitleText);
      subtitle_file_to_data[subtitle_file] = data;
    }
    for (i$ = 0, len$ = data.length; i$ < len$; ++i$) {
      sub = data[i$];
      start_time = srt_time_to_seconds(sub.startTime);
      end_time = srt_time_to_seconds(sub.endTime);
      mid_time = (start_time + end_time) / 2.0;
      if (start <= mid_time && mid_time <= end) {
        output.push(sub.text);
      }
    }
    return output.join('\n');
  };
  spawn = require('child_process').spawn;
  fs = require('fs');
  makeSegment = function(video, start, end, output, callback){
    var extra_options, command, options, ffmpeg;
    extra_options = [];
    if (output.indexOf('.webm') !== -1) {
      extra_options = ['-cpu-used', '-5', '-deadline', 'realtime'];
    }
    command = 'avconv';
    options = ['-ss', start, '-t', end - start, '-i', video].concat(extra_options.concat(['-y', output]));
    ffmpeg = spawn(command, options);
    ffmpeg.stdout.on('data', function(data){
      return console.log('stdout:' + data);
    });
    ffmpeg.stderr.on('data', function(data){
      return console.log('stderr:' + data);
    });
    return ffmpeg.on('exit', function(code){
      console.log('exited with code:' + code);
      if (callback != null) {
        return callback();
      }
    });
  };
  app.get('/segmentvideo', function(req, res){
    var video, start, end, video_base, video_path, output_file, output_path;
    console.log('segmentvideo');
    video = req.query.video;
    start = req.query.start;
    end = req.query.end;
    video_base = video.split('.')[0];
    video_path = 'videos/' + video;
    output_file = video_base + '_' + start + '_' + end + '.webm';
    output_path = 'static/' + output_file;
    if (fs.existsSync(output_path)) {
      return res.sendfile(output_path);
    } else {
      return makeSegment(video_path, start, end, output_path, function(){
        return res.sendfile(output_path);
      });
    }
  });
  to_machine_readable_timestamps = function(tree, file, subtitle_file){
    var output, res$, k, v, i$, ref$, len$, x;
    res$ = {};
    for (k in tree) {
      v = tree[k];
      res$[k] = v;
    }
    output = res$;
    if (output.file != null) {
      file = output.file;
    } else if (file != null) {
      output.file = file;
    }
    if (output.subtitle_file != null) {
      subtitle_file = output.subtitle_file;
    } else if (subtitle_file != null) {
      output.subtitle_file = subtitle_file;
    }
    if (output.start != null) {
      output.start = to_numeric_time(output.start);
    }
    if (output.end != null) {
      output.end = to_numeric_time(output.end);
    }
    if (output.file != null && output.start != null && output.end != null) {
      output.url = "segmentvideo?start=" + output.start + "&end=" + output.end + "&video=" + output.file;
    }
    if (output.subtitle_file != null && output.start != null && output.end != null) {
      output.text = getTextAtTime(output.subtitle_file, output.start, output.end);
    }
    if (output.children != null && output.children.length != null) {
      res$ = [];
      for (i$ = 0, len$ = (ref$ = output.children).length; i$ < len$; ++i$) {
        x = ref$[i$];
        res$.push(to_machine_readable_timestamps(x, file, subtitle_file));
      }
      output.children = res$;
    }
    return output;
  };
  root.slides = slides = to_machine_readable_timestamps(slides_human_readable);
  app.get('/getSlideData', function(req, res){
    return res.json(slides);
  });
  app.listen(8080);
  console.log('Listening on port 8080');
}).call(this);
