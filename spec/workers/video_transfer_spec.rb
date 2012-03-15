require 'spec_helper'

describe VideoTransfer do
  let(:out)         { mock('out') }
  let(:user)        { mock('user') }
  let(:youtube)     { mock('youtube') }
  let(:out_video)   { mock('out_video') }
  let(:path)        { 'tmp/path-of-downloaded-file.video' }

  def setup_out
    out.should_receive(:user).and_return(user)
    user.should_receive(:youtube).and_return(youtube)
  end

  before do
    ENV['NIMBB_VIDEO_DOWNLOAD_URI'] = 'http://nimbb.com'
    ENV['NIMBB_PUBLIC_KEY']         = '123'
    ENV['NIMBB_PRIVATE_KEY']        = 'xyz'
    ENV['NIMBB_VIDEO_FORMAT']       = 'swf'
  end

  it 'should construct a download uri' do
    out_video = double(:guid => '3456')
    out.should_receive(:video).and_return(out_video)
    VideoTransfer.construct_nimbb_download_uri(out).should eq('http://nimbb.com?&key=123&code=xyz&guid=3456&format=swf')
  end
  
  it 'should download a nimbb video' do
    uri   = 'http://video-to-download.com'
    io    = mock('io')
    file  = mock('file')
  
    File.should_receive(:open).with(path, 'wb').and_yield(file)
    Kernel.should_receive(:open).with(uri).and_return(io)
    io.should_receive(:read).and_return('bits and bytes')
    file.should_receive('<<').with('bits and bytes')
    
    VideoTransfer.download_nimbb_video(path, uri)
  end
  
  context 'get youtube video info' do
    before do
      setup_out
    end
  
    it 'should be successful with valid youtube video id' do
      youtube_video = mock('youtube_video')
      out_video     = mock('out_video')

      out.should_receive(:video).exactly(2).times.and_return(out_video)
      out_video.should_receive(:youtube_id).exactly(2).times.and_return('123')
      youtube.should_receive(:my_video).with('123').and_return(youtube_video)
      
      VideoTransfer.get_youtube_video_info(out).should eq(youtube_video)
    end
    
    it 'should catch query error with invalid youtube video id' do
      out_video = mock('video')
      
      out.should_receive(:video).exactly(2).times.and_return(out_video)
      out_video.should_receive(:youtube_id).exactly(2).times.and_return('invalid youtube video id')
      youtube.should_receive(:my_video).with('invalid youtube video id') { raise UploadError.new('youtube id is invalid') }
      
      VideoTransfer.get_youtube_video_info(out).should be_nil
    end  
    
    it 'should throw an exception on fatal error' do
      out_video = mock('video')
      
      out.should_receive(:video).exactly(2).times.and_return(out_video)
      out_video.should_receive(:youtube_id).exactly(2).times.and_return('api error')
      youtube.should_receive(:my_video).with('api error') { raise StandardError.new('there was an api error') }
      
      lambda{ VideoTransfer.get_youtube_video_info(out) }.should raise_error(StandardError, 'there was an api error')
    end
  end
  
  it 'should upload a nimbb video to youtube' do
    setup_out
    file      = mock('file')
    response  = mock('response')
    out_video = double(:guid => '3456')
    
    out.should_receive(:video).exactly(3).times.and_return(out_video)
    File.should_receive(:open).with(path).and_yield(file)
    out_video.should_receive(:name).and_return('999')    
    youtube.should_receive(:video_upload).with(file, :title => '999').and_return(response)
    response.should_receive(:unique_id).and_return(456)
    out_video.should_receive(:youtube_id=).with(456)
    out_video.should_receive(:save!)
    
    VideoTransfer.upload_nimbb_video_to_youtube(out, path).should eq(response)
  end
end
