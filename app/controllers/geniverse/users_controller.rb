require 'geniverse/report'
require 'base64'

module Geniverse
  class UsersController < Geniverse::ApplicationController
    # GET /users
    # GET /users.xml
    def index
      if params[:username]
        user = Geniverse::User.find_by_username(params[:username])
        @users = [user] if user

        # raise ActiveRecord::RecordNotFound, "Couldn't find user with username #{params[:username]}" unless @users
        @users = [] unless @users
      else
         # @users = Geniverse::User.all
         @users = []
      end


      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @users }
        format.json { render :json => custom_array_hash(@users) }
      end
    end

    # GET /users/1
    # GET /users/1.xml
    def show
      if params[:id]
        @user = Geniverse::User.find(params[:id])
      else
         @user = Geniverse::User.find_by_username(params[:username])
         raise ActiveRecord::RecordNotFound, "Couldn't find user with username #{params[:username]}" unless @user
      end

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
        format.json { render :json => custom_item_hash(@user) }
      end
    end

    # GET /users/new
    # GET /users/new.xml
    def new
      @user = Geniverse::User.new

      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @user }
      end
    end

    # GET /users/1/edit
    def edit
      @user = Geniverse::User.find(params[:id])
    end

    # POST /users
    # POST /users.xml
    def create
      user_params = paramify_json(params[:user])
      user_params[:password_hash] = user_params[:passwordHash] if user_params.has_key? :passwordHash
      user_params.delete(:passwordHash)

      @user = Geniverse::User.new(user_params)

      respond_to do |format|
        if @user.save
          format.html { redirect_to(@user, :notice => 'User was successfully created.') }
          format.xml  { render :xml => @user, :status => :created, :location => @user }
          format.json { render :json => custom_item_hash(@user), :status => :created, :location => @user }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # PUT /users/1
    # PUT /users/1.xml
    def update
      @user = Geniverse::User.find(params[:id])
      respond_to do |format|
        attributes = paramify_json(params[:user])
        if @user.update_attributes(attributes)
          format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
          format.xml  { head :ok }
          format.json { render :json => custom_item_hash(@user), :status => :ok, :location => @user}
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /users/1
    # DELETE /users/1.xml
    def destroy
      @user = Geniverse::User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      end
    end

    def starsReport
      sio = StringIO.new
      b64 = params[:id] || ""
      b64 = b64.gsub('_','/').gsub('-','+')
      report = Report::Stars.new Base64.decode64(b64).split(',')

      book = report.run_report
      send_data(book.to_data_string,
                 :type => "application/vnd.ms.excel",
                 :filename => "stars.xls" )

    end


  end
end
