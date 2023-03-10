# frozen_string_literal: true

class FundTransactionsController < ApplicationController
  load_and_authorize_resource

  def index
    authorize! :index, FundTransactionsController

    @pagy, @fund_transactions = pagy(FundTransaction.transactions(current_user.id).order('created_at DESC'), items: 13)
  end

  def new
    authorize! :new, FundTransactionsController

    @fund_transaction = if params[:payee_id].present?
                          current_user.fund_transactions.build(payee_id: params[:payee_id])
                        else
                          current_user.fund_transactions.build
                        end
  end

  def create
    @fund_transaction = current_user.fund_transactions.build(fund_transaction_params)

    if @fund_transaction.save
      flash[:notice] = 'Transaction has been successfully completed'
    else
      flash[:error] = @fund_transaction.errors.full_messages.to_sentence
    end
    redirect_to request.referer
  end

  private

  def fund_transaction_params
    params.require(:fund_transaction).permit(:payee_info, :purpose_of_payment_id, :amount)
  end
end
