require "spec_helper"

RSpec.describe Aem do
  it "has a version number" do
    expect(Aem::VERSION).not_to be nil
  end

  it 'reads a file' do
    opts = Aem::FileParse.new.read('res/aem.yaml')
    expect(opts).not_to be nil
    expect(opts['username']).to eq 'admin'
    expect(opts['password']).to eq 'admin'
    expect(opts['url']).to eq 'localhost:4502'
  end
end

RSpec.describe Aem::Info do
  it 'creates a new Info obj from the file' do
    opts = Aem::FileParse.new.read('res/aem.yaml')
    info = Aem::Info.new opts
    expect(info).not_to be nil
    expect(info.username).to eq 'admin'
    expect(info.password).to eq 'admin'
    expect(info.url).to eq 'localhost:4502'
  end
end

RSpec.describe Aem::AemCmd do

  before(:each) do
    opts = Aem::FileParse.new.read
    info = Aem::Info.new opts
    @cmd = Aem::AemCmd.new info
  end

  it 'makes a help call' do
    exec = @cmd.help
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a list packages call' do
    exec = @cmd.list_packages 'name'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'will list the package info' do
    exec = @cmd.package_info 'cq-mcm-content'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a build package call' do
    exec = @cmd.build_package 'cq-mcm-content'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a build packages call' do
    exec = @cmd.build_packages 'cq-media-content', 'cq-mcm-content'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'download a package' do
    exec = @cmd.download_package 'cq-media-content', '.'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
    expect(exec).to eq './cq-media-content.zip'
    expect(File.exist?('./cq-media-content.zip')).to be true
    File.delete('./cq-media-content.zip')
  end

  it 'upload a package' do
    exec = @cmd.upload_package('./res/cq-media-content.zip', 'cq-media-content')
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'installs a package' do
    exec = @cmd.install_package 'cq-media-content'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end
end
