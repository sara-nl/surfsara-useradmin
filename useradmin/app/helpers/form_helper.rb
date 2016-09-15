module FormHelper
  def error_messages(form)
    render 'shared/error_messages', form: form
  end
end
