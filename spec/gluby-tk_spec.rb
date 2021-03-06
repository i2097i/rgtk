require 'rspec_helper'

describe GlubyTK do
  TEST_PROJECT_DIR = "test_project"

  SPEC_BOX = {
    :interface => "interface/SpecBox.glade",
    :gluby => "src/gluby/gluby_spec_box.rb",
    :ruby => "src/spec_box.rb",
    :base => "spec_box"
  }

  before :all do
    system "gluby new #{TEST_PROJECT_DIR}"
  end

  after :all do
    system "rm -rf #{TEST_PROJECT_DIR}/"
  end

  it 'should have a version number' do
    expect(GlubyTK::VERSION).to be_truthy
  end

  it 'should generate a new project directory' do
    expect(File.exist?(TEST_PROJECT_DIR)).to be true
  end

  it 'should generate all required sub-directories' do
    GlubyTK::Generator::DIRECTORIES.each {|dir|
      puts "\tChecking #{dir}..."
      expect(File.exist?("#{TEST_PROJECT_DIR}/#{dir}")).to be true
    }
  end

  it 'should generate all required files from templates' do
    GlubyTK::Generator::TEMPLATES.each {|template|
      puts "\tChecking #{template[:name]}..."
      expect(File.exist?("#{TEST_PROJECT_DIR}/#{template[:path]}/#{template[:name]}")).to be true
    }
  end

  # This only works locally - travis doesn't like it
  # it 'should run the program properly' do
  #   success = system("cd #{TEST_PROJECT_DIR} && ruby #{Dir.pwd}/#{TEST_PROJECT_DIR}/main.rb &")
  #   sleep(10)
  #   system "pkill ruby"
  #   expect(success).to be == true
  # end

  it 'should build ruby classes for new interface files' do
    system("cp templates/SpecBox.glade.template #{TEST_PROJECT_DIR}/#{SPEC_BOX[:interface]}")
    GlubyTK::Generator.rebuild("#{Dir.pwd}/#{TEST_PROJECT_DIR}")
    expect(File.exist?("#{TEST_PROJECT_DIR}/#{SPEC_BOX[:ruby]}")).to be true
    expect(File.exist?("#{TEST_PROJECT_DIR}/#{SPEC_BOX[:gluby]}")).to be true
  end

  it 'should update child entities when interface files are changed' do
    # TODO: Modify the id of a child entity in an interface file and 
    # verify that it is updated in the gluby_ ruby class
  end

  it 'should remove gluby_* class files and requires for deleted interface files' do
    system("rm #{TEST_PROJECT_DIR}/#{SPEC_BOX[:interface]}")
    GlubyTK::Generator.rebuild("#{Dir.pwd}/#{TEST_PROJECT_DIR}")
    
    gluby_includes_path = "#{TEST_PROJECT_DIR}/src/gluby/gluby_includes.rb"
    expect(GlubyTK::FileOperator.file_contains_line?(gluby_includes_path, SPEC_BOX[:base])).to be false
    expect(File.exist?("#{TEST_PROJECT_DIR}/#{SPEC_BOX[:gluby]}")).to be false
  end

  # TODO: Need to create tests for listen and start
end