root = exports ? this

add_video_obj = (obj) ->
  #add_video(obj.start, obj.end)
  newvid = $('<video>').attr('src', obj.url).attr('controls', 'controls').attr('width', '300').attr('height', '300').attr('autoplay', 'true').attr('loop', 'loop')
  vidid = obj.file.split('.')[0] + '_' + obj.start + '_' + obj.end
  newvid.attr('id', vidid)
  newvid.attr('subtitletext', obj.text)
  $('#videoDisplay').append newvid
  $('#' + vidid).mouseenter ->
    subtitletext = $('#' + vidid).attr('subtitletext')
    $('#framecontentRight').text(subtitletext)

#add_video = (start, end) ->
#  $('#videoDisplay').append $('<video>').attr('src', "17-1.mp4\#t=#{start},#{end}").attr('controls', 'controls')

getSlideData = (callback) ->
  $.getJSON '/getSlideData', (slides) ->
    callback(slides)

$(document).ready ->
  console.log('hello!')
  $('#foo').text('javascript working')
  getSlideData (slides) ->
    root.slides = slides
    for slide in slides.children
      add_video_obj(slide)
    $('#foo').text('javascript finished')
