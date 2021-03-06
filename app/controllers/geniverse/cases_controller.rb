module Geniverse
  class CasesController < Geniverse::ApplicationController
    # GET /cases
    # GET /cases.xml
    def index
      @cases = Case.all

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @cases }
        format.json { render :json => custom_array_hash(@cases) }
      end
    end

    # GET /cases/1
    # GET /cases/1.xml
    def show
      @case = Case.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @case }
        format.json { render :json => custom_item_hash(@case) }
      end
    end

    # GET /cases/new
    # GET /cases/new.xml
    def new
      @case = Case.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @case }
      end
    end

    # GET /cases/1/edit
    def edit
      @case = Case.find(params[:id])
    end

    # POST /cases
    # POST /cases.xml
    def create
      @case = Case.new(geniverse_case_params)

      respond_to do |format|
        if @case.save
          flash[:notice] = 'Case was successfully created.'
          format.html { redirect_to(@case) }
          format.xml  { render :xml => @case, :status => :created, :location => @case }
          format.json { render :json => custom_item_hash(@case), :status => :created, :location => @case }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @case.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /cases/1
    # PUT /cases/1.xml
    def update
      @case = Case.find(params[:id])

      respond_to do |format|
        if @case.update_attributes(geniverse_case_params)
          flash[:notice] = 'Case was successfully updated.'
          format.html { redirect_to(@case) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @case.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /cases/1
    # DELETE /cases/1.xml
    def destroy
      @case = Case.find(params[:id])
      @case.destroy

      respond_to do |format|
        format.html { redirect_to(cases_url) }
        format.xml  { head :ok }
      end
    end

    private

    def geniverse_case_params
      params.require(:geniverse_case).permit(
        :name,
        :order,
        :introImageUrl
      )
    end
  end
end
