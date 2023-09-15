# frozen_string_literal: true

module BadgeHelper
  REPORT_BADGE_COLORS = {
    approved:         "badge--green",
    rejected:         "badge--red",
    debated:          "badge--orange",
    returned:         "badge--red",
    assigned:         "badge--blue",
    transmitted:      "badge--violet",
    completed:        "badge--pink",
    incomplete:       "badge--yellow"
  }.freeze

  PACKAGE_BADGE_COLORS = {
    assigned:         "badge--blue",
    returned:         "badge--red",
    transmitted:      "badge--violet",
    completed:        "badge--pink",
    incomplete:       "badge--yellow"
  }.freeze

  def report_badge(arg)
    status =
      case arg
      when Report then report_status(arg)
      when Symbol then arg
      else raise TypeError, "invalid argument for report_badge: expect a Report or a Symbol, got #{arg.inspect}"
      end

    text = t(status, scope: "report_badge")
    color = REPORT_BADGE_COLORS[status]

    badge(text, color)
  end

  def package_badge(arg)
    status =
      case arg
      when Package then package_status(arg)
      when Symbol  then arg
      else raise TypeError, "invalid argument for package_badge: expect a Package or a Symbol, got #{arg.inspect}"
      end

    text = t(status, scope: "package_badge")
    color = PACKAGE_BADGE_COLORS[status]

    badge(text, color)
  end

  def priority_badge(priority)
    text  = "Priorité : "
    text += priority_icon_component(priority)

    css  = "priority-badge "
    css +=
      case priority.to_s
      when "high"   then "badge--red"
      when "medium" then "badge--yellow"
      else               "badge--lime"
      end

    badge(text.html_safe, css) # rubocop:disable Rails/OutputSafety
  end

  def report_status(report)
    if report.approved?
      :approved
    elsif report.rejected?
      :rejected
    elsif report.debated?
      :debated
    elsif report.returned?
      :returned
    elsif report.assigned?
      :assigned
    elsif report.transmitted?
      :transmitted
    elsif report.completed?
      :completed
    else
      :incomplete
    end
  end

  def package_status(package)
    if package.assigned?
      :assigned
    elsif package.returned?
      :returned
    elsif package.transmitted?
      :transmitted
    elsif package.completed?
      :completed
    else
      :incomplete
    end
  end

  def badge(text, css = nil)
    tag.div(text, class: "badge #{css}")
  end
end
