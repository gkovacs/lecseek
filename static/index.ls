root = exports ? this

slides_human_readable = {
  start: '0:00'
  end: '14:53'
  file: '17-1.mp4'
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

to_machine_readable_timestamps = (tree, file) ->
  output = {[k, v] for k,v of tree}
  if output.file?
    file = output.file
  else if file?
    output.file = file
  if output.start?
    output.start = to_numeric_time(output.start)
  if output.end?
    output.end = to_numeric_time(output.end)
  if output.file? and output.start? and output.end?
    #output.url = "#{output.file}\#t=#{output.start},#{output.end}"
    output.url = "http://localhost:5000/segmentvideo?start=#{output.start}&end=#{output.end}&video=#{output.file}"
  if output.children? and output.children.length?
    output.children = [to_machine_readable_timestamps(x, file) for x in output.children]
  return output

root.slides = slides = to_machine_readable_timestamps(slides_human_readable)

add_video_obj = (obj) ->
  #add_video(obj.start, obj.end)
  newvid = $('<video>').attr('src', obj.url).attr('controls', 'controls').attr('width', '300').attr('height', '300').attr('autoplay', 'true').attr('loop', 'loop')
  $('#videoDisplay').append newvid

#add_video = (start, end) ->
#  $('#videoDisplay').append $('<video>').attr('src', "17-1.mp4\#t=#{start},#{end}").attr('controls', 'controls')

$(document).ready ->
  console.log('hello!')
  $('#foo').text('javascript working')
  for slide in slides.children
    add_video_obj(slide)
  $('#foo').text('javascript finished')
