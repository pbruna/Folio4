class MoneyAccountsController < ApplicationController

  def new
    @money_account = MoneyAccount.new
  end

  def index
    @money_accounts = current_account.money_accounts
  end

  def create
    @money_account = current_account.money_accounts.new(money_account_params)
    prices_to_numbers
    if @money_account.save
      flash.now[:notice] = 'Cuenta creada correctamente.'
      redirect_to money_accounts_path
    else
      flash.now[:error] = 'No pudimos guardar la Cuenta, por favor corrige los errores indicados.'
      render 'new'
    end
  end

  private
  def money_account_params
    params.require(:money_account).permit(:name, :number, :bank_name, :type_id,
                                          :total_credit_clp, :total_credit_usd
                                          )
  end

  def prices_to_numbers
    @money_account.total_credit_clp.to_s.gsub!(/\./,'')
    @money_account.total_credit_usd.to_s.gsub!(/\./,'')
  end

end
