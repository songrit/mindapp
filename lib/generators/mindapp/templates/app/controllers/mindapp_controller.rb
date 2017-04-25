# -*- encoding : utf-8 -*-
class MindappController < ApplicationController
  def index
  end
  def logs
    @xmains = Mindapp::Xmain.all.desc(:created_at).page(params[:page]).per(10)
  end
  def error_logs
    @xmains = Mindapp::Xmain.in(status:['E']).desc(:created_at).page(params[:page]).per(10)
  end
  def pending
    @title= "Pending Tasks"
    @xmains = Mindapp::Xmain.in(status:['R','I']).asc(:created_at)
  end
  def cancel
    Mindapp::Xmain.find(params[:id]).update_attributes :status=>'X'
    if params[:return]
      redirect_to params[:return]
    else
      redirect_to action:"pending"
    end
  end
  def clear_xmains
    Mindapp::Xmain.where(:status =>{'$in'=>['R','I']}).update_all(:status=>'X')
    redirect_to action:"pending"
  end
  def ajax_notice
    if notice=Mindapp::Notice.recent(current_user, request.env["REMOTE_ADDR"])
      notice.update_attribute :unread, false
      js = "notice('#{notice.message}');"
    else
      js = ""
    end
    render plain: "<script>#{js}</script>"
  end
  def init
    module_code, code = params[:s].split(":")
    @service= Mindapp::Service.where(:module_code=> module_code, :code=> code).first
    # @service= Mindapp::Service.where(:module_code=> params[:module], :code=> params[:service]).first
    if @service && authorize_init?
      xmain = create_xmain(@service)
      result = create_runseq(xmain)
      unless result
        message = "cannot find action for xmain #{xmain.id}"
        ma_log("ERROR", message)
        flash[:notice]= message
        redirect_to "pending" and return
      end
      xmain.update_attribute(:xvars, @xvars)
      xmain.runseqs.last.update_attribute(:end,true)
      #Above line cause error update_attribute in heroku shown in logs and it was proposed to fixed in github:'kul1/g241502'
      redirect_to :action=>'run', :id=>xmain.id
    else
      refresh_to "/", :alert => "Error: cannot process"
    end
  end
  def run
    init_vars(params[:id])
    if authorize?
      # session[:full_layout]= false
      redirect_to(:action=>"run_#{@runseq.action}", :id=>@xmain.id)
    else
      redirect_to_root
    end
  end
  def run_form
    init_vars(params[:id])
    if authorize?
      if ['F', 'X'].include? @xmain.status
        redirect_to_root
      else
        service= @xmain.service
        if service
          @title= "Transaction ID #{@xmain.xid}: #{@xmain.name} / #{@runseq.name}"
          fhelp= "app/views/#{service.module.code}/#{service.code}/#{@runseq.code}.md"
          @help = File.read(fhelp) if File.exists?(fhelp)
          f= "app/views/#{service.module.code}/#{service.code}/#{@runseq.code}.html.erb"
          @ui= File.read(f)
        else
          # flash[:notice]= "ไม่สามารถค้นหาบริการที่ต้องการได้"
          ma_log "Error: Service not found"
          redirect_to_root
        end
      end
    else
      redirect_to_root
    end
  end
  def run_if
    init_vars(params[:id])
    condition= eval(@runseq.code).to_s
    match_found= false
    if condition
      xml= REXML::Document.new(@runseq.xml).root
      next_runseq= nil
      text = xml.elements['//node/node'].attributes['TEXT']
      match, name= text.split(':',2)
      label= name2code(name.strip)
      if condition==match
        if label=="end"
          @end_job= true
        else
          next_runseq= @xmain.runseqs.where(:code=> label, :action.ne=>'redirect').first
          match_found= true if next_runseq
          @runseq_not_f= false
        end
      end
    end
    unless match_found || @end_job
      next_runseq= @xmain.runseqs.where( rstep:(@xvars['current_step']+1) ).first
    end
    end_action(next_runseq)
  end
  def run_redirect
    init_vars(params[:id])
    # next_runseq= @xmain.runseqs.first :conditions=>["id != ? AND code = ?",@runseq.id, @runseq.code]
    next_runseq= @xmain.runseqs.where(:id.ne=>@runseq.id, :code=>@runseq.code).first
    @xmain.current_runseq= next_runseq.id
    end_action(next_runseq)
  end
  def run_do
    init_vars(params[:id])
    @runseq.start ||= Time.now
    @runseq.status= 'R' # running
    $runseq_id= @runseq.id
    $user_id= current_user.try(:id)
    set_global
    controller = Kernel.const_get(@xvars['custom_controller']).new
    result = controller.send(@runseq.code)
    init_vars_by_runseq($runseq_id)
    @xvars = $xvars
    @xvars[@runseq.code.to_sym]= result.to_s
    @xvars['current_step']= @runseq.rstep
    @runseq.status= 'F' #finish
    @runseq.stop= Time.now
    @runseq.save
    end_action
  rescue => e
    @xmain.status='E'
    @xvars['error']= e.to_s+e.backtrace.to_s
    @xmain.xvars= $xvars
    @xmain.save
    @runseq.status= 'F' #finish
    @runseq.stop= Time.now
    @runseq.save
    refresh_to "/", :alert => "ขออภัย เกิดข้อผิดพลาดในรหัสการดำเนินงาน #{@xmain.id} #{@xvars['error']}"
  end
  def run_output
    init_vars(params[:id])
    service= @xmain.service
    disp= get_option("display")
    display = (disp && !affirm(disp)) ? false : true
    if service
      f= "app/views/#{service.module.code}/#{service.code}/#{@runseq.code}.html.erb"
      @ui= File.read(f)
      if Mindapp::Doc.where(:runseq_id=>@runseq.id).exists?
        @doc= Mindapp::Doc.where(:runseq_id=>@runseq.id).first
        @doc.update_attributes :data_text=> render_to_string(:inline=>@ui, :layout=>"utf8"),
                               :xmain=>@xmain, :runseq=>@runseq, :user=>current_user,
                               :ip=> get_ip, :service=>service, :display=>display,
                               :secured => @xmain.service.secured
      else
        @doc= Mindapp::Doc.create :name=> @runseq.name,
                                  :content_type=>"output", :data_text=> render_to_string(:inline=>@ui, :layout=>"utf8"),
                                  :xmain=>@xmain, :runseq=>@runseq, :user=>current_user,
                                  :ip=> get_ip, :service=>service, :display=>display,
                                  :secured => @xmain.service.secured
      end
      @message = defined?(MSG_NEXT) ? MSG_NEXT : "Next &gt;"
      @message = "สิ้นสุดการทำงาน" if @runseq.end
      eval "@xvars[@runseq.code] = url_for(:controller=>'Mindapp', :action=>'document', :id=>@doc.id)"
    else
      # flash[:notice]= "ไม่สามารถค้นหาบริการที่ต้องการได้"
      ma_log "Error: service not found"
      redirect_to_root
    end
    #display= get_option("display")
    unless display
      end_action
    end
  end
  def run_mail
    init_vars(params[:id])
    service= @xmain.service
    f= "app/views/#{service.module.code}/#{service.code}/#{@runseq.code}.html.erb"
    @ui= File.read(f).html_safe
    @doc= Mindapp::Doc.create :name=> @runseq.name,
                              :content_type=>"mail", :data_text=> render_to_string(:inline=>@ui, :layout=>false),
                              :xmain=>@xmain, :runseq=>@runseq, :user=>current_user,
                              :ip=> get_ip, :service=>service, :display=>false,
                              :secured => @xmain.service.secured
    eval "@xvars[:#{@runseq.code}] = url_for(:controller=>'mindapp', :action=>'document', :id=>@doc.id)"
    mail_from = get_option('from')
    # sender= render_to_string(:inline=>mail_from) if mail_from
    mail_to = get_option('to')
    recipients= render_to_string(:inline=>mail_to) if mail_to
    mail_subject = get_option('subject')
    subject= render_to_string(:inline=>mail_subject) || "#{@runseq.name}"
    MindappMailer.gmail(@doc.data_text, recipients, subject).deliver unless DONT_SEND_MAIL
    end_action
  end
  def end_output
    init_vars(params[:xmain_id])
    end_action
  end
  def end_form
    init_vars(params[:xmain_id])
    eval "@xvars[@runseq.code] = {} unless @xvars[@runseq.code]"
    params.each { |k,v|
      if params[k].respond_to? :original_filename
        get_image(k, params[k])
      elsif params[k].is_a?(Hash)
        eval "@xvars[@runseq.code][k] = v"
        params[k].each { |k1,v1|
          next unless v1.respond_to?(:original_filename)
          get_image1(k, k1, params[k][k1])
        }
      else
        v = v.to_unsafe_h unless v.class == String
        eval "@xvars[@runseq.code][k] = v"
      end
    }
    end_action
  end
  def end_action(next_runseq = nil)
    #    @runseq.status='F' unless @runseq_not_f
    @xmain.xvars= @xvars
    @xmain.status= 'R' # running
    @xmain.save
    @runseq.status='F'
    @runseq.user= current_user
    @runseq.stop= Time.now
    @runseq.save
    next_runseq= @xmain.runseqs.where(:rstep=> @runseq.rstep+1).first unless next_runseq
    if @end_job || !next_runseq # job finish
      @xmain.xvars= @xvars
      @xmain.status= 'F' unless @xmain.status== 'E' # finish
      @xmain.stop= Time.now
      @xmain.save
      if @xvars['p']['return']
        redirect_to @xvars['p']['return'] and return
      else
        if @user
          redirect_to :action=>'pending' and return
        else
          redirect_to_root and return
        end
      end
    else
      @xmain.update_attribute :current_runseq, next_runseq.id
      redirect_to :action=>'run', :id=>@xmain.id and return
    end
  end
  # process images from first level
  def get_image(key, params)
    doc = Mindapp::Doc.create(
        :name=> params.key.to_s,
        :xmain=> params(@xmain.id),
        :runseq=> params(@runseq.id),
        :filename=> params.original_filename,
        :content_type => params.content_type || 'application/zip',
        :data_text=> params(''),
        :display=>params.true,
        :secured => params(@xmain.service.secured ))
    if defined?(IMAGE_LOCATION)
      filename = "#{IMAGE_LOCATION}/f#{Param.gen(:asset_id)}"
      File.open(filename,"wb") { |f| f.write(params.read) }
      # File.open(filename,"wb") { |f| f.puts(params.read) }
      eval "@xvars[@runseq.code][key] = '#{url_for(:action=>'document', :id=>doc.id, :only_path => true )}' "
      doc.update_attributes :url => filename, :basename => File.basename(filename), :cloudinary => false
    else
      result = Cloudinary::Uploader.upload(params)
      eval %Q{ @xvars[@runseq.code][key] = '#{result["url"]}' }
      doc.update_attributes :url => result["url"], :basename => File.basename(result["url"]), :cloudinary => true
    end
  end
  # process images from second level, e.g,, fields_for
  def get_image1(key, key1, params)
    doc = Mindapp::Doc.create(
        :name=> "#{key}_#{key1}",
        :xmain=> @xmain.id,
        :runseq=> @runseq.id,
        :filename=> params.original_filename,
        :content_type => params.content_type || 'application/zip',
        :data_text=> '',
        :display=>true, :secured => @xmain.service.secured )
    if defined?(IMAGE_LOCATION)
      filename = "#{IMAGE_LOCATION}/f#{Param.gen(:asset_id)}"
      File.open(filename,"wb") { |f| f.write(params.read) }
      eval "@xvars[@runseq.code][key][key1] = '#{url_for(:action=>'document', :id=>doc.id, :only_path => true)}' "
      doc.update_attributes :url => filename, :basename => File.basename(filename), :cloudinary => false
    else
      result = Cloudinary::Uploader.upload(params)
      eval %Q{ @xvars[@runseq.code][key][key1] = '#{result["url"]}' }
      doc.update_attributes :url => result["url"], :basename => File.basename(result["url"]), :cloudinary => true
    end
  end
  def doc_print
    render :file=>'public/doc.html', :layout=>'layouts/print'
  end
  # generate documentation for application
  def doc
    require 'rdoc'
    @app= get_app
    @intro = File.read('README.md')
    @print= "<div align='right'><img src='/assets/printer.png'/> <a href='/mindapp/doc_print' target='_blank'/>พิมพ์</a></div>"
    doc= render_to_string 'doc.md', :layout => false
    html= Maruku.new(doc).to_html
    File.open('public/doc.html','w') {|f| f.puts html }
    respond_to do |format|
      format.html {
        render :text=> @print+html, :layout => 'layouts/_page'
        # render :text=> Maruku.new(doc).to_html, :layout => false
        # format.html {
        #   h = RDoc::Markup::ToHtml.new
        #   render :text=> h.convert(doc), :layout => 'layouts/_page'
      }
      format.pdf  {
        latex= Maruku.new(doc).to_latex
        File.open('tmp/doc.md','w') {|f| f.puts doc}
        File.open('tmp/doc.tex','w') {|f| f.puts latex}
        # system('pdflatex tmp/doc.tex ')
        # send_file( 'tmp/doc.pdf', :type => ‘application/pdf’,
        # :disposition => ‘inline’, :filename => 'doc.pdf')
        render :text=>'done'
      }
    end
  end
  # handle uploaded image
  def document
    doc = Mindapp::Doc.find params[:id]
    if doc.cloudinary
      require 'net/http'
      require "uri"
      uri = URI.parse(doc.url)
      data = Net::HTTP.get_response(uri)
      send_data(data.body, :filename=>doc.filename, :type=>doc.content_type, :disposition=>"inline")
    else
      data= read_binary(doc.url)
      send_data(data, :filename=>doc.filename, :type=>doc.content_type, :disposition=>"inline")
    end
  end
  def status
    @xmain= Mindapp::Xmain.where(:xid=>params[:xid]).first
    @title= "Task number #{params[:xid]} #{@xmain.name}"
    @backbtn= true
    @xvars= @xmain.xvars
    # flash.now[:notice]= "รายการ #{@xmain.id} ได้ถูกยกเลิกแล้ว" if @xmain.status=='X'
    ma_log "Task #{@xmain.id} is cancelled" if @xmain.status=='X'
      # flash.now[:notice]= "transaction #{@xmain.id} was cancelled" if @xmain.status=='X'
  rescue
    refresh_to "/", :alert => "Could not find task number <b> #{params[:xid]} </b>"
  end
  def help
  end
  def search
    @q = params[:q] || params[:ma_search][:q] || ""
    @title = "ผลการค้นหา #{@q}"
    @backbtn= true
    @cache= true
    if @q.blank?
      redirect_to "/"
    else
      s= GmaSearch.create :q=>@q, :ip=> request.env["REMOTE_ADDR"]
      do_search
    end
  end
  def err404
    # ma_log 'ERROR', 'main/err404'
    flash[:notice] = "We're sorry, but something went wrong. We've been notified about this issue and we'll take a look at it shortly."
    ma_log "We're sorry, but something went wrong. We've been notified about this issue and we'll take a look at it shortly."
    redirect_to '/'
  end
  def err500
    # ma_log 'ERROR', 'main/err500'
    flash[:notice] = "We're sorry, but something went wrong. We've been notified about this issue and we'll take a look at it shortly."
    ma_log "We're sorry, but something went wrong. We've been notified about this issue and we'll take a look at it shortly."
    redirect_to '/'
  end

  private
  def create_xmain(service)
    c = name2camel(service.module.code)
    custom_controller= "#{c}Controller"
    Mindapp::Xmain.create :service=>service,
                          :start=>Time.now,
                          :name=>service.name,
                          :ip=> get_ip,
                          :status=>'I', # init
                          :user=>current_user,
                          :xvars=> {
                              :service_id=>service.id,
                              :p=>params.permit(:s, :action, :controller).to_h,
                              :id=>params[:id],
                              :user_id=>current_user.try(:id),
                              :custom_controller=>custom_controller,
                              :host=>request.host,
                              :referer=>request.env['HTTP_REFERER']
                          }
  end
  def create_runseq(xmain)
    @xvars= xmain.xvars
    default_role= get_default_role
    xml= xmain.service.xml
    root = REXML::Document.new(xml).root
    i= 0; j= 0 # i= step, j= form_step
    root.elements.each('node') do |activity|
      text= activity.attributes['TEXT']
      next if ma_comment?(text)
      next if text =~/^rule:\s*/
      action= freemind2action(activity.elements['icon'].attributes['BUILTIN']) if activity.elements['icon']
      return false unless action
      i= i + 1
      output_display= false
      if action=='output'
        display= get_option_xml("display", activity)
        if display && !affirm(display)
          output_display= false
        else
          output_display= true
        end
      end
      j= j + 1 if (action=='form' || output_display)
      @xvars['referer'] = activity.attributes['TEXT'] if action=='redirect'
      if action!= 'if'
        scode, name= text.split(':', 2)
        name ||= scode; name.strip!
        code= name2code(scode)
      else
        code= text
        name= text
      end
      role= get_option_xml("role", activity) || default_role
      rule= get_option_xml("rule", activity) || "true"
      runseq= Mindapp::Runseq.create :xmain=>xmain.id,
                                     :name=> name, :action=> action,
                                     :code=> code, :role=>role.upcase, :rule=> rule,
                                     :rstep=> i, :form_step=> j, :status=>'I',
                                     :xml=>activity.to_s
      xmain.current_runseq= runseq.id if i==1
    end
    @xvars['total_steps']= i
    @xvars['total_form_steps']= j
  end
  def init_vars(xmain)
    @xmain= Mindapp::Xmain.find xmain
    @xvars= @xmain.xvars
    @runseq= @xmain.runseqs.find @xmain.current_runseq
#    authorize?
    @xvars['current_step']= @runseq.rstep
    @xvars['referrer']= request.referrer
    session[:xmain_id]= @xmain.id
    session[:runseq_id]= @runseq.id
    unless params[:action]=='run_call'
      @runseq.start ||= Time.now
      @runseq.status= 'R' # running
      @runseq.save
    end
    $xmain= @xmain; $xvars= @xvars
    $runseq_id= @runseq.id
    $user_id= current_user.try(:id)
  end
  def init_vars_by_runseq(runseq_id)
    @runseq= Mindapp::Runseq.find runseq_id
    @xmain= @runseq.xmain
    @xvars= @xmain.xvars
    #@xvars[:current_step]= @runseq.rstep
    @runseq.start ||= Time.now
    @runseq.status= 'R' # running
    @runseq.save
  end
  def store_asset
    if params[:content]
      doc = GmaDoc.create! :name=> 'asset',
                           :filename=> (params[:file_name]||''),
                           :content_type => (params[:content_type] || 'application/zip'),
                           :data_text=> '',
                           :display=>true
      path = (IMAGE_LOCATION || "tmp")
      File.open("#{path}/f#{doc.id}","wb") { |f|
        f.puts(params[:content])
      }
      render :xml=>"<elocal><doc id='#{doc.id}' /><success /></elocal>"
    else
      render :xml=>"<elocal><fail /></elocal>"
    end
  end
  def do_search
    if current_user.secured?
      @docs = GmaDoc.search_secured(@q.downcase, params[:page], PER_PAGE)
    else
      @docs = GmaDoc.search(@q.downcase, params[:page], PER_PAGE)
    end
    @xmains = GmaXmain.find(@docs.map(&:ma_xmain_id)).sort { |a,b| b.id<=>a.id }
    # @xmains = GmaXmain.find @docs.map(&:created_at).sort { |a,b| b<=>a }
  end
  def read_binary(path)
    File.open path, "rb" do |f| f.read end
  end
end
