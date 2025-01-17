class ReportsController < ApplicationController
  before_action :require_account
  before_action :get_api_token, only: %i(chat)
  # before_action :require_subscription!, except: %i(index)

  def index
    @pagy, @reports = pagy(current_account.reports)
  end

  def show
    @report = Report.find_by_prefix_id(params[:id])

    if !@report || @report.account != current_account
      redirect_to reports_path, alert: 'Report not found'
    end

    respond_to do |format|
      format.html
      format.csv { 
        send_data @report.csv, filename: @report.title, type: 'text/csv'
      }
    end
  end

  def chat
    @report = Report.find_by_prefix_id(params[:id])

    if !@report || @report.account != current_account
      redirect_to reports_path, alert: 'Report not found'
    end
  end

  def new
    @report = current_account.reports.new(report_type: :yelp)
    @terms = Report.business_types.sort.map { |str| { title: str } }
  end

  def create
    @report = current_account.reports.new(report_params)
    if @report.save!
      HandleReportJob.perform_later(@report.id)
      redirect_to reports_path, notice: 'Report created successfully'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def report_params
    params.require(:report).permit(:title, :location, :term, :report_type)
  end

  def get_api_token
    @api_token = current_user.api_tokens.first_or_create(name: "Managed")
    @api_token.save if @api_token.new_record?
  end
end
