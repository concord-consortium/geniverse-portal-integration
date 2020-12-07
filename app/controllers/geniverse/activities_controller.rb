module Geniverse
  class ActivitiesController < Geniverse::ApplicationController
    # GET /activities
    # GET /activities.xml
    def index
      if params[:route]
        act = Activity.find_by_route(params[:route])
        @activities = act.nil? ? [] : [act]
        @activities.compact
      end

      @activities = Activity.all unless @activities && @activities.size > 0

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @activities }
        format.json { render :json => custom_array_hash(@activities) }
      end
    end

    # GET /activities/1
    # GET /activities/1.xml
    def show
      @activity = Activity.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @activity }
        format.json { render :json => custom_item_hash(@activity) }
      end
    end

    # GET /activities/new
    # GET /activities/new.xml
    def new
      @activity = Activity.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @activity }
      end
    end

    # GET /activities/1/edit
    def edit
      @activity = Activity.find(params[:id])
    end

    # POST /activities
    # POST /activities.xml
    def create
      @activity = Activity.new(activity_params)

      respond_to do |format|
        if @activity.save
          flash[:notice] = 'Activity was successfully created.'
          format.html { redirect_to(@activity) }
          format.xml  { render :xml => @activity, :status => :created, :location => @activity }
          format.json { render :json => custom_item_hash(@activity), :status => :created, :location => @activity }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /activities/1
    # PUT /activities/1.xml
    def update
      @activity = Activity.find(params[:id])

      respond_to do |format|
        if @activity.update_attributes(activity_params)
          flash[:notice] = 'Activity was successfully updated.'
          format.html { redirect_to(@activity) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @activity.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /activities/1
    # DELETE /activities/1.xml
    def destroy
      @activity = Activity.find(params[:id])
      @activity.destroy

      respond_to do |format|
        format.html { redirect_to(activities_url) }
        format.xml  { head :ok }
      end
    end

    def destroy_dragons
      @activity = params[:id]
      @dragons = Dragon.find(:all, :conditions => {:activity_id => @activity})
      @dragons.each {|d| d.destroy }
      redirect_to(activities_url)
    end

    private

    def activity_params
      params.require(:activity).permit(
        :initial_alleles,
        :base_channel_name,
        :max_users_in_room,
        :send_bred_dragons,
        :title,
        :hidden_genes,
        :static_genes,
        :crossover_when_breeding,
        :route,
        :pageType,
        :message,
        :match_dragon_alleles,
        :myCase_id,
        :myCaseOrder,
        :is_argumentation_challenge,
        :threshold_three_stars,
        :threshold_two_stars,
        :show_color_labels,
        :congratulations,
        :show_tooltips
      )
    end

  end
end
