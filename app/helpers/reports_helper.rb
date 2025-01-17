module ReportsHelper
  def status_pill(status)
    classname = "pill"
    case status
    when "created"
      classname += " pill-primary"
    when "done"
      classname += " pill-secondary"
    else
      classname += " pill-tertiary"
    end

    content_tag :span, status.titleize, class: classname
  end

  def report_type_pill(type)
    classname = "pill"
    text = type

    case type
    when "yelp"
      classname += " bg-red-900 text-white"
      text = "Yelp"
    when "google"
      classname += " pill-primary"
      text = "Google Maps"
    end

    content_tag :span, text, class: classname
  end
end
