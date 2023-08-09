# frozen_string_literal: true

module BadgeHelper
  REPORT_BADGE_COLORS = {
    approved:         "badge--green",
    rejected:         "badge--red",
    debated:          "badge--orange",
    package_rejected: "badge--red",
    package_approved: "badge--blue",
    transmitted:      "badge--violet",
    completed:        "badge--pink",
    incomplete:       "badge--yellow"
  }.freeze

  PACKAGE_BADGE_COLORS = {
    approved:         "badge--blue",
    rejected:         "badge--red",
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
    text = "Priorité : "
    css  = "priority-badge "

    case priority.to_s
    when "high"
      text += svg_icon("chart-bar", "Haute", class: "high-priority-icon")
      css  += "badge--red"
    when "medium"
      text += svg_icon("chart-bar", "Moyenne", class: "medium-priority-icon")
      css  += "badge--yellow"
    else
      text += svg_icon("chart-bar", "Basse", class: "low-priority-icon")
      css  += "badge--lime"
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
    elsif report.package.rejected?
      :package_rejected
    elsif report.package.approved?
      :package_approved
    elsif report.transmitted?
      :transmitted
    elsif report.completed?
      :completed
    else
      :incomplete
    end
  end

  def package_status(package)
    if package.approved?
      :approved
    elsif package.rejected?
      :rejected
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
