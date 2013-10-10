# -*- encoding : utf-8 -*-
module Mindapp
  module Helpers
    require "rexml/document"
    include REXML
    # methods from application_controller
    def b(s)
      "<b>#{s}</b>".html_safe
    end
    def date_thai(d= Time.now, options={})
      unless d
        ""
      else
        y = d.year+543
        if options[:monthfull] || options[:month_full]
          mh= ['มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน', 'กรกฏาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม']
        else
          mh= ['ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.', 'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.']
        end
        if options[:dateonly] || options[:date_only]
          d.day.to_s+" "+mh[d.month-1]+" "+y.to_s
        else
          d.day.to_s+" "+mh[d.month-1]+" "+y.to_s+" เวลา "+sprintf("%02d",d.hour.to_s)+":"+sprintf("%02d",d.min.to_s)
        end
      end
    end
    def link_to_blank(body, url_options = {}, html_options = {})
      link_to(body, url_options, html_options.merge(target: "_blank"))
    end
    def code_text(s) # old def code(s)
      "<pre style='background-color: #efffef;'><code class='ruby' lang='ruby'>#{s}</code></pre>".html_safe
    end
    def refresh_to(url='/', option={})
      if option[:alert]
        ma_log option[:alert]
      end
      render :text => "<script>window.location.replace('#{url}')</script>"
    end
    def read_binary(path)
      File.open path, "rb" do |f| f.read end
    end
    def redirect_to_root
      redirect_to root_path
    end
    def get_option(opt, runseq=@runseq)
      xml= REXML::Document.new(runseq.xml).root
      url=''
      xml.each_element('///node') do |n|
        text= n.attributes['TEXT']
        url= text if text =~/^#{opt}:\s*/
      end
      c, h= url.split(':', 2)
      opt= h ? h.strip : false
    end
    def ma_comment?(s)
      s[0]==35
    end
    def get_ip
      request.env['HTTP_X_FORWARDED_FOR'] || request.env['REMOTE_ADDR']
    end
    def get_default_role
      default_role= Mindapp::Role.where(:code =>'default').first
      return default_role ? default_role.name.to_s : ''
    end
    def name2code(s)
      # rather not ignore # symbol cause it could be comment
      code, name = s.split(':')
      code.downcase.strip.gsub(' ','_').gsub(/[^#_\/a-zA-Z0-9]/,'')
    end
    def name2camel(s)
      s.gsub(' ','_').camelcase
    end
    def true_action?(s)
      %w(call ws redirect invoke email).include? s
    end
    def set_global
      $xmain= @xmain ; $runseq = @runseq ; $user = current_user ; $xvars= @xmain.xvars; $ip = request.env["REMOTE_ADDR"]
    end
    def authorize? # use in pending tasks
      @runseq= @xmain.runseqs.find @xmain.current_runseq
      return false unless @runseq
      @user = current_user
      set_global
      return false unless eval(@runseq.rule) if @runseq.rule
      return true if true_action?(@runseq.action)
      # return false if check_wait
      return true if @runseq.role.blank?
      unless @runseq.role.empty?
        return false unless @user.role
        return @user.role.upcase.split(',').include?(@runseq.role.upcase)
      end
      return true
    end
    def authorize_init? # use when initialize new transaction
      # check module role
      mrole = @service.module.role
      return false if mrole && !current_user
      return false if mrole && !current_user.has_role(mrole)

      # check step 1 role
      xml= @service.xml
      step1 = REXML::Document.new(xml).root.elements['node']
      role= get_option_xml("role", step1) || ""
  #    rule= get_option_xml("rule", step1) || true
      return true if role==""
      unless current_user
        return role.blank?
      else
        return false unless current_user.role
        return current_user.has_role(role)
      end
    end
    def ma_log(message)
        Mindapp::Notice.create :message => ERB::Util.html_escape(message.gsub("`","'")),
          :unread=> true, :ip=> ($ip || request.env["REMOTE_ADDR"])
      # if session[:user_id]
      #   Mindapp::Notice.create :message => ERB::Util.html_escape(message.gsub("`","'")),
      #     :user_id => $user.id, :unread=> true, :ip=> env["REMOTE_ADDR"]
      # else
      #   Mindapp::Notice.create :message => ERB::Util.html_escape(message.gsub("`","'")),
      #     :unread=> true, :ip=> env["REMOTE_ADDR"]
      # end
    end

    alias :ma_notice :ma_log

    # methods from application_helper
    def markdown(text)
      erbified = ERB.new(text.html_safe).result(binding)
      red = Redcarpet::Markdown.new(Redcarpet::Render::HTML, :autolink => true, :space_after_headers => true)
      red.render(erbified).html_safe
    end
    def align_text(s, pixel=3)
      "<span style='position:relative; top:-#{pixel}px;'>#{s}</span>".html_safe
    end
    def status_icon(status)
      case status
      when 'R'
        image_tag 'user.png'
      when 'F'
        image_tag 'tick.png'
      when 'I'
        image_tag 'control_play.png'
      when 'E'
        image_tag 'logout.png'
      when 'X'
        image_tag 'cross.png'
      else
        image_tag 'cancel.png'
      end
    end
    def role_name(code)
      role= Mindapp::Role.where(code:code).first
      return role ? role.name : ""
    end
    def uncomment(s)
      s.sub(/^#\s/,'')
    end
    def code_div(s)
      "<pre style='background-color: #efffef;'><code class='ruby' lang='ruby'>    #{s}</code></pre>".html_safe
    end
    def ajax?(s)
      return s.match('file_field') ? false : true
    end
    def step(s, total) # square text
      s = (s==0)? 1: s.to_i
      total = total.to_i
      out ="<div class='step'>"
      (s-1).times {|ss| out += "<span class='steps_done'>#{(ss+1)}</span>" }
      out += %Q@<span class='step_now' >@
      out += s.to_s
      out += "</span>"
      out += %Q@@
      for i in s+1..total
        out += "<span class='steps_more'>#{i}</span>"
      end
      out += "</div>"
      out.html_safe
    end

    # methods that I don't know where they came from
    def current_user
      if session[:user_id]
        return @user ||= User.find(session[:user_id])
      else
        return nil
      end
    end
    def ui_action?(s)
      %w(form output mail pdf).include? s
    end
    # def handle_ma_notice
    #   if Mindapp::Notice.recent.count>0
    #     notice= Mindapp::Notice.recent.last
    #     notice.update_attribute :unread, false
    #     "<script>notice('#{notice.message}');</script>"
    #   else
    #     ""
    #   end
    # end
    def process_services
      # todo: persist mm_md5
      xml= @app||get_app
      if defined? session
        md5= Digest::MD5.hexdigest(xml.to_s)
        if session[:mm_md5]
          return if session[:mm_md5]==md5
        else
          session[:mm_md5]= md5
        end
      end
      protected_services = []
      protected_modules = []
      mseq= 0
      @services= xml.elements["//node[@TEXT='services']"] || REXML::Document.new
      @services.each_element('node') do |m|
        ss= m.attributes["TEXT"]
        code, name= ss.split(':', 2)
        next if code.blank?
        next if code.comment?
        module_code= code.to_code
        # create or update to GmaModule
        ma_module= Mindapp::Module.find_or_create_by :code=>module_code
        ma_module.update_attributes :uid=>ma_module.id.to_s
        protected_modules << ma_module.uid
        name = module_code if name.blank?
        ma_module.update_attributes :name=> name.strip, :seq=> mseq
        mseq += 1
        seq= 0
        m.each_element('node') do |s|
          service_name= s.attributes["TEXT"].to_s
          scode, sname= service_name.split(':', 2)
          sname ||= scode; sname.strip!
          scode= scode.to_code
          if scode=="role"
            ma_module.update_attribute :role, sname
            next
          end
          if scode.downcase=="link"
            role= get_option_xml("role", s) || ""
            rule= get_option_xml("rule", s) || ""
            ma_service= Mindapp::Service.find_or_create_by :module_code=> ma_module.code, :code=> scode, :name=> sname
            ma_service.update_attributes :xml=>s.to_s, :name=>sname,
              :list=>listed(s), :secured=>secured?(s),
              :module_id=>ma_module.id, :seq => seq,
              :confirm=> get_option_xml("confirm", xml),
              :role => role, :rule => rule, :uid=> ma_service.id.to_s
            seq += 1
            protected_services << ma_service.uid
          else
            # normal service
            step1 = s.elements['node']
            role= get_option_xml("role", step1) || ""
            rule= get_option_xml("rule", step1) || ""
            ma_service= Mindapp::Service.find_or_create_by :module_code=> ma_module.code, :code=> scode
            ma_service.update_attributes :xml=>s.to_s, :name=>sname,
              :list=>listed(s), :secured=>secured?(s),
              :module_id=>ma_module.id, :seq => seq,
              :confirm=> get_option_xml("confirm", xml),
              :role => role, :rule => rule, :uid=> ma_service.id.to_s
            seq += 1
            protected_services << ma_service.uid
          end
        end
      end
      Mindapp::Module.not_in(:uid=>protected_modules).delete_all
      Mindapp::Service.not_in(:uid=>protected_services).delete_all
    end
    def get_app
      f= MM || "#{Rails.root}/app/mindapp/index.mm"
      dir= File.dirname(f)
      t= REXML::Document.new(File.read(MM).gsub("\n","")).root
      recheck= true ; first_pass= true
      while recheck
        recheck= false
        t.elements.each("//node") do |n|
          if n.attributes['LINK'] # has attached file
            if first_pass
              f= "#{dir}/#{n.attributes['LINK']}"
            else
              f= n.attributes['LINK']
            end
            next unless File.exists?(f)
            tt= REXML::Document.new(File.read(f).gsub("\n","")).root.elements["node"]
            make_folders_absolute(f,tt)
            tt.elements.each("node") do |tt_node|
              n.parent.insert_before n, tt_node
            end
            recheck= true
            n.parent.delete_element n
          end
        end
        first_pass = false
      end
      return t
    end
    def controller_exists?(modul)
      File.exists? "#{Rails.root}/app/controllers/#{modul}_controller.rb"
    end
    def dup_hash(a)
      h = Hash.new(0)
      a.each do |aa|
        h[aa] += 1
      end
      return h
    end
    def login?
      session[:user_id] != nil
    end
    def own_xmain?
      if $xmain
        return current_user.id==$xvars['user_id']
      else
        # if eval on first step would return true so user can start service
        return true
      end
    end
    def get_option_xml(opt, xml)
      if xml
        url=''
        xml.each_element('node') do |n|
          text= n.attributes['TEXT']
          url= text if text =~/^#{opt}/
        end
        return nil if url.blank?
        c, h= url.split(':', 2)
        opt= h ? h.strip : true
      else
        return nil
      end
    end
    def listed(node)
      icons=[]
      node.each_element("icon") do |nn|
        icons << nn.attributes["BUILTIN"]
      end
      return !icons.include?("closed")
    end
    def secured?(node)
      icons=[]
      node.each_element("icon") do |nn|
        icons << nn.attributes["BUILTIN"]
      end
      return icons.include?("password")
    end
    def freemind2action(s)
      case s.downcase
      #when 'bookmark' # Excellent
      #  'call'
      when 'bookmark' # Excellent
        'do'
      when 'attach' # Look here
        'form'
      when 'edit' # Refine
        'pdf'
      when 'wizard' # Magic
        'ws'
      when 'help' # Question
        'if'
      when 'forward' # Forward
        'redirect'
      when 'kaddressbook' #Phone
        'invoke' # invoke new service along the way
      when 'pencil'
        'output'
      when 'mail'
        'mail'
      end
    end
    def affirm(s)
      return s =~ /[y|yes|t|true]/i ? true : false
    end
    def negate(s)
      return s =~ /[n|no|f|false]/i ? true : false
    end

    # module FormBuilder
    #   def date_field(method, options = {})
    #     default= self.object.send(method) || Date.today
    #     data_options= ({"mode"=>"calbox"}).merge(options)
    #     %Q(<input name='#{self.object_name}[#{method}]' id='#{self.object_name}_#{method}' value='#{default.strftime("%F")}' type='date' data-role='datebox' data-options='#{data_options.to_json}'>).html_safe
    #   end
    # end
  end
end

class String
  def comment?
    self[0]=='#'
  end
  def to_code
    s= self.dup
#    s.downcase!
#    s.gsub! /[\s\-_]/, ""
#    s
    code, name = s.split(':')
    code.downcase.strip.gsub(' ','_').gsub(/[^#_\/a-zA-Z0-9]/,'')
  end
end

module ActionView
  module Helpers
    module DateHelper
      def date_field_tag(method, options = {})
        default= options[:default] || Date.today
        data_options= ({"mode"=>"calbox"}).merge(options)
        %Q(<input name='#{method}' id='#{method}' value='#{default.strftime("%F")}' type='date' data-role='datebox' data-options='#{data_options.to_json}'>).html_safe
      end
    end
    class FormBuilder
#      def date_select_thai(method)
#        self.date_select method, :use_month_names=>THAI_MONTHS, :order=>[:day, :month, :year]
#      end
      def date_field(method, options = {})
        default= options[:default]  || self.object.send(method) || Date.today
        data_options= ({"mode"=>"calbox"}).merge(options)
        out= %Q(<input name='#{self.object_name}[#{method}]' id='#{self.object_name}_#{method}' value='#{default.strftime("%F")}' type='date' data-role='datebox' data-options='#{data_options.to_json}'>)
        out.html_safe
      end
      def time_field(method, options = {})
        default= self.object.send(method) || Time.now
        data_options= ({"mode"=>"timebox"}).merge(options)
        out=%Q(<input name='#{self.object_name}[#{method}]' id='#{self.object_name}_#{method}' value='#{default}' type='date' data-role='datebox' data-options='#{data_options.to_json}'>)
        out.html_safe
      end
      def date_select_thai(method, default= Time.now, disabled=false)
        date_select method, :default => default, :use_month_names=>THAI_MONTHS, :order=>[:day, :month, :year], :disabled=>disabled
      end
      def datetime_select_thai(method, default= Time.now, disabled=false)
        datetime_select method, :default => default, :use_month_names=>THAI_MONTHS, :order=>[:day, :month, :year], :disabled=>disabled
      end

      def point(o={})
        o[:zoom]= 11 unless o[:zoom]
        o[:width]= '100%' unless o[:width]
        o[:height]= '300px' unless o[:height]
        o[:lat] = 13.91819 unless o[:lat]
        o[:lng] = 100.48889 unless o[:lng]

        out = <<-EOT
  <script type='text/javascript'>
  //<![CDATA[
    var latLng;
    var map_#{self.object_name};
    var marker_#{self.object_name};

    function init_map() {
      var lat =  #{o[:lat]};
      var lng =  #{o[:lng]};
      //var lat =  position.coords.latitude"; // HTML5 pass position in function initialize(position)
      // google.loader.ClientLocation.latitude;
      //var lng =  position.coords.longitude;
      // google.loader.ClientLocation.longitude;
      latLng = new google.maps.LatLng(lat, lng);
      map_#{self.object_name} = new google.maps.Map(document.getElementById("map_#{self.object_name}"), {
        zoom: #{o[:zoom]},
        center: latLng,
        mapTypeId: google.maps.MapTypeId.ROADMAP
      });
      marker_#{self.object_name} = new google.maps.Marker({
        position: latLng,
        map: map_#{self.object_name},
        draggable: true,
      });
      google.maps.event.addListener(marker_#{self.object_name}, 'dragend', function(event) {
        $('##{self.object_name}_lat').val(event.latLng.lat());
        $('##{self.object_name}_lng').val(event.latLng.lng());
      });
      google.maps.event.addListener(map_#{self.object_name}, 'click', function(event) {
        $('##{self.object_name}_lat').val(event.latLng.lat());
        $('##{self.object_name}_lng').val(event.latLng.lng());
        move();
      });
      $('##{self.object_name}_lat').val(lat);
      $('##{self.object_name}_lng').val(lng);
    };

    function move() {
      latLng = new google.maps.LatLng($('##{self.object_name}_lat').val(), $('##{self.object_name}_lng').val());
      map_#{self.object_name}.panTo(latLng);
      marker_#{self.object_name}.setPosition(latLng);
    }

    //google.maps.event.addDomListener(window, 'load', init_map);

  //]]>
  </script>
  <div class="field" data-role="fieldcontain">
    Latitude: #{self.text_field :lat, :style=>"width:300px;" }
    Longitude: #{self.text_field :lng, :style=>"width:300px;" }
  </div>
  <p/>
  <div id='map_#{self.object_name}' style='max-width: none !important; width:#{o[:width]}; height:#{o[:height]};' class='map'></div>
  <script>
    $('##{self.object_name}_lat').change(function() {move()});
    $('##{self.object_name}_lng').change(function() {move()});
    //var w= $("input[id*=lat]").parent().width();
    //$("input[id*=lat]").css('width','300px');
    //$("input[id*=lng]").css('width','300px');
    $( document ).one( "pagechange", function(){
      init_map();
    });
  </script>
EOT
        out.html_safe
      end
    end
  end
end
