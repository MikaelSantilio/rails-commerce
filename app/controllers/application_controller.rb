class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  private

  def record_invalid(exception)
    render json: {
      error: 'Dados inválidos',
      message: exception.message,
      errors: exception.record.errors.full_messages,
      status: 422
    }, status: :unprocessable_entity
  end
end