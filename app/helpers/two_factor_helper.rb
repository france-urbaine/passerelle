# frozen_string_literal: true

module TwoFactorHelper
  OTP_ISSUER = "FiscaHub"

  def otp_provisioning_uri(user = current_user)
    user.otp_provisioning_uri(user.email, issuer: OTP_ISSUER)
  end

  def otp_qr_code_as_svg_tag(*user, **options)
    RQRCode::QRCode.new(
      otp_provisioning_uri(*user)
    ).as_svg(
      **options,
      module_size: 4,
      use_path: true
    ).html_safe # rubocop:disable Rails/OutputSafety
  end
end
