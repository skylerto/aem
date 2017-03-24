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
    @info = Aem::Info.new opts
  end

  it 'makes a help call' do
    cmd = Aem::AemCmd.new @info
    exec = cmd.help
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a list packages call' do
    cmd = Aem::AemCmd.new @info
    exec = cmd.list_packages
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a build package call' do
    cmd = Aem::AemCmd.new @info
    exec = cmd.build_package 'inlet-terms'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end

  it 'makes a build packages call' do
    cmd = Aem::AemCmd.new @info
    exec = cmd.build_packages 'inlet-terms', 'loading'
    expect(exec).not_to be nil
    expect(exec).not_to eq ''
  end
end
