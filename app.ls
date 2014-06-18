express = require 'express'
app = express()
path = require 'path'
fs = require 'fs'
parser = require 'subtitles-parser'

#app.use(express.static(__dirname)); # Current directory is root
app.use(express.static(path.join(__dirname, 'static'))) #  "public" off of current is root

slides_human_readable = {
  start: '0:00'
  end: '14:53'
  file: '17-1.mp4'
  subtitle_file: '17-1.srt'
  children: [
    {
      start: '0:00'
      end: '0:21'
    }
    {
      start: '0:21'
      end: '2:53'
    }
    {
      start: '2:53'
      end: '3:32'
    }
    {
      start: '3:32'
      end: '4:41'
    }
    {
      start: '4:41'
      end: '6:28'
    }
    {
      start: '6:28'
      end: '8:16'
    }
    {
      start: '8:16'
      end: '11:12'
    }
    {
      start: '11:12'
      end: '12:38'
    }
    {
      start: '12:38'
      end: '14:15'
    }
    {
      start: '14:15'
      end: '14:53'
    }
  ]
}

to_numeric_time = (str) ->
  [min,sec] = str.split(':')
  min = parseInt(min)
  sec = parseInt(sec)
  return min*60 + sec

srt_time_to_seconds = (str) ->
  [hour,minute,sec] = str.split(':')
  [sec,millisec] = sec.split(',')
  hour = parseInt(hour)
  minute = parseInt(minute)
  sec = parseInt(sec)
  millisec = parseInt(millisec)
  return hour * 3600 + minute * 60 + sec + millisec / 1000.0

subtitle_file_to_data = {}

getTextAtTime = (subtitle_file, start, end) ->
  output = []
  data = subtitle_file_to_data[subtitle_file]
  if not data?
    subtitleText = fs.readFileSync('static/' + subtitle_file, 'utf-8')
    data = parser.fromSrt(subtitleText)
    subtitle_file_to_data[subtitle_file] = data
  for sub in data
    start_time = srt_time_to_seconds(sub.startTime)
    end_time = srt_time_to_seconds(sub.endTime)
    mid_time = (start_time + end_time) / 2.0
    #if start <= mid_time <= end
    if start <= end_time <= end
      output.push sub.text
  return output.join('\n')


to_machine_readable_timestamps = (tree, file, subtitle_file) ->
  output = {[k, v] for k,v of tree}
  if output.file?
    file = output.file
  else if file?
    output.file = file
  if output.subtitle_file?
    subtitle_file = output.subtitle_file
  else if subtitle_file?
    output.subtitle_file = subtitle_file
  if output.start?
    output.start = to_numeric_time(output.start)
  if output.end?
    output.end = to_numeric_time(output.end)
  if output.file? and output.start? and output.end?
    #output.url = "#{output.file}\#t=#{output.start},#{output.end}"
    output.url = "http://localhost:5000/segmentvideo?start=#{output.start}&end=#{output.end}&video=#{output.file}"
  if output.subtitle_file? and output.start? and output.end?
    output.text = getTextAtTime(output.subtitle_file, output.start, output.end)
  if output.children? and output.children.length?
    output.children = [to_machine_readable_timestamps(x, file, subtitle_file) for x in output.children]
  return output

root.slides = slides = to_machine_readable_timestamps(slides_human_readable)

app.get '/getSlideData', (req, res) ->
  res.json slides

app.listen(8080)
console.log('Listening on port 8080');
