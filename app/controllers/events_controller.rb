class EventsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :administrator!
  
  # GET /events
  # GET /events.xml
  def index
    @events = Event.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @events }
    end
  end

  # GET /events/1
  # GET /events/1.xml
  def show
    @event = Event.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/new
  # GET /events/new.xml
  def new
    @event = Event.new
    @event.page = Page.find_by_id(params[:page_id])

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @event }
    end
  end

  # GET /events/1/edit
  def edit
    @event = Event.find(params[:id])
  end

  # POST /events
  # POST /events.xml
  def create
    parse_times
    @event = Event.new(params[:event])

    respond_to do |format|
      if @event.save
        format.html { redirect_to(edit_page_url(@event.page,
            :aspect => 'events', :event_id => @event.id),
            :notice => 'Event was successfully created.') }
        format.xml  { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /events/1
  # PUT /events/1.xml
  def update
    parse_times
    @event = Event.find(params[:id])

    respond_to do |format|
      if @event.update_attributes(params[:event])
        format.html { redirect_to(edit_page_url(@event.page,
            :aspect => 'events', :event_id => @event.id),
            :notice => 'Event was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  # DELETE /events/1.xml
  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    respond_to do |format|
      format.html { redirect_to(edit_page_url(@event.page,
          :aspect => 'events')) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  
  
  def parse_times
    params[:event][:start_at] =
      DateTime.parse_from_form(params[:event][:start_at])
    params[:event][:stop_at] =
      DateTime.parse_from_form(params[:event][:stop_at])
    logger.info "!!! start at #{params[:event][:start_at]}"
  end
  
end
