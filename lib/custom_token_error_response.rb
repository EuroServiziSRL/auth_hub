module CustomTokenErrorResponse
  def body
    {
      status_code: 401,
      message: I18n.t('devise.failure.invalid', authentication_keys: ::AuthHub::User.authentication_keys.join('/')),
      result: []
    }
    # or merge with existing values by
    # super.merge({key: value})
  end
end