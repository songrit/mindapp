require 'mindapp'
require 'mindapp/helpers'
include Mindapp::Helpers

@btext= "# mindapp begin"
@etext= "# mindapp end"

namespace :mindapp do
  desc "generate models from mm"
  task :update=> :environment do
    @app= get_app
    process_models
    process_controllers
    gen_views
  end

  desc "cancel all pending tasks"
  task :cancel=> :environment do
    Mindapp::Xmain.update_all "status='X'", "status='I' or status='R'"
  end
end

# ----------------------------
  def gen_views
    t = ["*** generate ui ***"]
    Mindapp::Module.all.each do |m|
      m.services.each do |s|
        next if s.code=='link'
        dir ="app/views/#{s.module.code}"
        unless File.exists?(dir)
          Dir.mkdir(dir)
          t << "create directory #{dir}"
        end
        dir ="app/views/#{s.module.code}/#{s.code}"
        unless File.exists?(dir)
          Dir.mkdir(dir)
          t << "create directory #{dir}"
        end
        xml= REXML::Document.new(s.xml)
        xml.elements.each('*/node') do |activity|
          icon = activity.elements['icon']
          next unless icon
          action= freemind2action(icon.attributes['BUILTIN'])
          next unless ui_action?(action)
          code_name = activity.attributes["TEXT"].to_s
          next if code_name.comment?
          code= name2code(code_name)
          if action=="pdf"
            f= "app/views/#{s.module.code}/#{s.code}/#{code}.pdf.prawn"
          else
            f= "app/views/#{s.module.code}/#{s.code}/#{code}.html.erb"
          end
          unless File.exists?(f)
            FileUtils.cp "app/mindapp/template/view.html.erb", f
            # ff=File.open(f, 'w'); ff.close
            t << "create file #{f}"
          end
        end
      end
    end
    puts t.join("\n")
  end
  def process_controllers
    process_services
    modules= Mindapp::Module.all
    modules.each do |m|
      next if controller_exists?(m.code)
      system("rails generate controller #{m.code}")
    end
  end

  def process_models
    # app= get_app
    # t= ["process models"]
    models= @app.elements["//node[@TEXT='models']"] || REXML::Document.new
    models.each_element('node') do |model|
      # t << "= "+model.attributes["TEXT"]
      model_name= model.attributes["TEXT"]
      next if model_name.comment?
      model_code= name2code(model_name)
      model_file= "#{Rails.root}/app/models/#{model_code}.rb"
      if File.exists?(model_file)
        doc= File.read(model_file)
      else
        system("rails generate model #{model_code}")
        doc= File.read(model_file)
      end
      doc = add_utf8(doc)
      attr_hash= make_fields(model)
      doc = add_mindapp(doc, attr_hash)
      # t << "modified:   #{model_file}"
      File.open(model_file, "w") do |f|
        f.puts doc
      end
    end
    # puts t.join("\n")
  end

  def add_mindapp(doc, attr_hash)
    if doc =~ /#{@btext}/
      s1,s2,s3= doc.partition(/  #{@btext}.*#{@etext}\n/m)
      s2= ""
    else
      s1,s2,s3= doc.partition("include Mongoid::Document\n")
    end
    doc= s1+s2+ <<-EOT
  #{@btext}
  include Mongoid::Timestamps
  EOT
    attr_hash.each do |a|
      # doc+= "\n*****"+a.to_s+"\n"
      if a[:edit]
        doc += "  #{a[:text]}\n"
      else
        doc += "  field :#{a[:code]}, :type => #{a[:type].capitalize}\n"
      end
    end
    doc += "  #{@etext}\n"
    doc + s3
  end

  def add_utf8(doc)
    unless doc =~ /encoding\s*:\s*utf-8/
      doc.insert 0, "# encoding: utf-8\n"
    else
      doc
    end
  end

  # inspect all nodes that has attached file (2 cases) and replace relative path with absolute path
  def make_folders_absolute(f,tt)
    tt.elements.each("//node") do |nn|
      if nn.attributes['LINK']
        nn.attributes['LINK']= File.expand_path(File.dirname(f))+"/#{nn.attributes['LINK']}"
      end
    end
  end
  def name2code(s)
    # rather not ignore # symbol cause it could be comment
    code, name = s.split(':')
    code.downcase.strip.gsub(' ','_').gsub(/[^#_\/a-zA-Z0-9]/,'')
  end
  def model_exists?(model)
    File.exists? "#{Rails.root}/app/models/#{model}.rb"
  end
  def make_fields(n)
    # s= field string used by generate model cli (old style mindapp)
    s= ""
    # h= hash :code, :type, :edit, :text
    h= []
    n.each_element('node') do |nn|
      text = nn.attributes['TEXT']
      icon = nn.elements['icon']
      edit= (icon && icon.attribute('BUILTIN').value=="edit")
      next if text.comment? && !edit

      # sometimes freemind puts all fields inside a blank node
      unless text.empty?
        k,v= text.split(/:\s*/,2)
        v ||= 'string'
        v= 'float' if v=~/double/i
        s << " #{name2code(k.strip)}:#{v.strip} "
        h << {:code=>name2code(k.strip), :type=>v.strip, :edit=>edit, :text=>text}
      else
        nn.each_element('node') do |nnn|
          icon = nnn.elements['icon']
          edit1= (icon && icon.attribute('BUILTIN').value=="edit")
          text1 = nnn.attributes['TEXT']
          next if text1 =~ /\#.*/
          k,v= text1.split(/:\s*/,2)
          v ||= 'string'
          v= 'float' if v=~/double/i
          s << " #{name2code(k.strip)}:#{v.strip} "
          h << {:code=>name2code(k.strip), :type=>v.strip, :edit=>edit1, :text=>text1}
        end
      end
    end
    # f
    h
  end

# ----------------------------
class String
  def comment?
    self[0]=='#'
    # self[0]==35 # check if first char is #
  end
  def to_code
    s= self.dup
    s.downcase.strip.gsub(' ','_').gsub(/[^#_\/a-zA-Z0-9]/,'')
  end
end
