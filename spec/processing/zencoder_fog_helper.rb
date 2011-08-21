def zencoder_fog_tests(fog_credentials)
  describe CarrierWave::Zencoder do

    before do
      CarrierWave.configure do |config|
        config.reset_config
        config.fog_attributes  = {}
        config.fog_credentials = fog_credentials
        config.fog_directory   = CARRIERWAVE_DIRECTORY
        config.fog_host        = nil
        config.fog_public      = true
      end

      eval <<-RUBY
class FogSpec#{fog_credentials[:provider]}Uploader < CarrierWave::Uploader::Base
storage :fog
end
      RUBY

      @provider = fog_credentials[:provider]

      # @uploader = FogSpecUploader.new
      @uploader = eval("FogSpec#{@provider}Uploader")
      @uploader.stub!(:store_path).and_return('uploads/video.m4v')

      @storage = CarrierWave::Storage::Fog.new(@uploader)
      @directory = @storage.connection.directories.get(CARRIERWAVE_DIRECTORY) || @storage.connection.directories.create(:key => CARRIERWAVE_DIRECTORY, :public => true)

      @file = CarrierWave::SanitizedFile.new(
        :tempfile => StringIO.new(File.open(file_path('video.m4v')).read),
        :filename => 'video.m4v'
      )
      
      @fog_file = @storage.store!(@file)

      # Load up zencoder class
      @klass = Class.new do
      include CarrierWave::Zencoder
      end
      @instance = @klass.new
      @instance.stub(:current_path).and_return(@fog_file.url)
      @instance.stub(:cached?).and_return true

      Zencoder.api_key = 'abc123'
      @outputs = {}

    end # before

    describe "#create" do
      it "should create a job response" do
        response = @instance.create
        response.should be_instance_of Zencoder::Response
      end  

      it "should create a successful response" do
        response = @instance.create
        response.success?.should be_true
      end  
    end # #create

  end # Zencoder
end # zencoder_fog_tests
