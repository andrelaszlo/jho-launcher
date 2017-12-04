class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :statsd_conn

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end

  protected

  def statsd_conn
    @statsd = Statsd.new 'localhost', 8125
  end
end
