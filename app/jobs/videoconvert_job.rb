class VideoconvertJob < ApplicationJob
  queue_as :low_priority

  def perform (filename)
    video = UserFile.where(file: filename).first

    if not (video)
      return 'done'
    end
    ivideo = Rails.root.to_s + '/storage/' + filename
    if not(File.exist?(ivideo))
      return 'done'
    end

    movie = FFMPEG::Movie.new(ivideo)
    metadata = movie.metadata
    duration = metadata[:format][:duration].to_f
    if not (movie.valid?)
      return 'done'
    end
    
    vbitrate = movie.video_bitrate / 1024
    if not (movie.audio_stream.nil?)
      abitrate = movie.audio_bitrate / 1024
    else
      abitrate = 0
    end

    # Do not process files if it is playable format and low bitrate
    if File.extname(ivideo) == '.mp4' and vbitrate < 1100
      return 'done'
    end

    if vbitrate > 1000
      vbitrate = 1000
    end
    if abitrate > 256
      abitrate = 256
    end

    # Disable the timeout altogether
#    Transcoder.timeout = false

    video_name = File.dirname(ivideo) + '/convert_' + File.basename(ivideo, ".*") + '.mp4'

    voptions = {
      video_codec: "libx264", frame_rate: movie.frame_rate, resolution: movie.resolution , video_bitrate: vbitrate, video_bitrate_tolerance: 100,
      audio_codec: "aac", audio_bitrate: abitrate, audio_sample_rate: 44100, audio_channels: 2,
      threads: 12
    }
    movie.transcode(video_name, voptions) do |progress|
      percentage = progress.to_f * 100
      puts "processed #{percentage}%"
    end 

    transcoded_movie = FFMPEG::Movie.new(video_name)
    metadata = transcoded_movie.metadata
    filesize = metadata[:format][:size].to_f

    if transcoded_movie.valid?
       video = UserFile.where(file: filename).first
       if not (video)
         File.delete(ivideo) if File.exist?(ivideo)
         return 'done'
       end
       newfilename = video_name.sub! (Rails.root.to_s + '/storage/'), ''
       video.file = newfilename
       video.filetype = 'video/mp4'
       video.filesize = filesize
       video.save

       File.delete(ivideo) if File.exist?(ivideo)
    else
       File.delete(video_name) if File.exist?(video_name)
    end
    return 'done'
  end
end
