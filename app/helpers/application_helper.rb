module ApplicationHelper
  include Pagy::Frontend
  include SanitizeUrl
  ALERT_TYPES = {
    success: 'alert-success',
    error: 'alert-danger',
    alert: 'alert-warning',
    notice: 'alert-info'
  }.freeze

  def bootstrap_class_for(flash_type)
    ALERT_TYPES[flash_type.to_sym] || flash_type.to_s
  end

  def language_title(lang)
    case lang
    when 'py'
      'Python'
    when 'cs'
      'C#'
    else
      lang
    end
  end

  def parse_markdown(str)
    return if str.blank?
    content_tag :div, class: 'markdown' do
      render_markdown(str)
    end
  end

  def render_markdown(str)
    return if str.blank?
    CommonMarker.render_html(str, :UNSAFE, [:tagfilter, :autolink, :table, :strikethrough]).html_safe
  end

  def page_title
    title = ""
    title += "#{@page_title} - " if @page_title.present?
    title += "Forage"
  end
end
