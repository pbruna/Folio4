class CompaniesController < ApplicationController

  def index
    @companies = current_account.companies_in_alphabetycal_order(params[:company_name_like])
    respond_to do |format|
      format.html 
      format.js
    end
  end
  
  def invoices
    @company = current_account.companies.find(params[:id])
    params[:search] = {company_id: @company.id}
    @invoices_total_resume = @company.invoices_search(params[:search])
    @invoices = @invoices_total_resume.page(params[:page]) 
    @search_params = params.to_param
  end
  
  def expenses
    @company = current_account.companies.find(params[:id])
  end
  
  def contacts
    @company = current_account.companies.find(params[:id])
    @contacts = @company.contacts_in_alphabetycal_order(params[:contact_name_like])
    respond_to do |format|
      format.html 
      format.js
    end
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.account_id = current_account.id
    if @company.save
      flash[:notice] = "Empresa guardada correctamente."
      redirect_to company_path(@company)
    else
      render "new"
    end
  end
  
  def update
    @company = current_account.companies.find(params[:id])
    if @company.update_attributes(company_params)
      flash[:notice] = "Empresa guardada correctamente."
      redirect_to company_path(@company)
    else
      render "edit"
    end
  end
  
  def edit
    @company = current_account.companies.find(params[:id])
  end
  
  def destroy
    @company = current_account.companies.find(params[:id])
    if @company.destroy
      flash[:notice] = "Empresa eliminada correctamente"
      redirect_to companies_path()
    else
      flash[:error] = "No se puede eliminar esta empresa"
      redirect_to @company
    end
  end
  
  def show
    @company = current_account.companies.find(params[:id])
  end


  private
    def company_params
      params.require(:company).permit(:avatar, :name, :city, :address, :province, :rut, :company_name_like, :industry)
    end


end
