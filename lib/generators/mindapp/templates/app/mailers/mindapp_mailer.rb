class MindappMailer < ActionMailer::Base
  default from: "from@example.com"
  def gmail(ui, to="", subject="", from="")
    @ui = ui
    mail(:to => to, :subject => subject, :from => from)
  end
end
