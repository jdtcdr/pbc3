class FormsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /forms
  # GET /forms.xml
  def index
    @forms = if params[:page_id]
        @page = Page.find(params[:page_id])
        return unless page_administrator!
        @page.forms
      else
        return unless administrator!
        @forms = Form.order('name ASC')
      end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @forms }
    end
  end

  # GET /forms/1
  # GET /forms/1.xml
  def show
    @form = Form.find(params[:id])
    @page = @form.page
    return unless page_administrator!

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @form }
    end
  end

  # GET /forms/new
  # GET /forms/new.xml
  def new
    @form = Form.new
    @form.page = Page.find(params[:page_id]) if params[:page_id]
    @page = @form.page
    return unless page_administrator!
    @copy_form = nil

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @form }
    end
  end
  
  def copy
    @copy_form = Form.find(params[:id])
    @form = Form.new
    @form.name = @copy_form.name + ' Copy'
    @form.page = @copy_form.page
    @page = @form.page
    return unless page_administrator!
    render :action => 'new'
  end

  # GET /forms/1/edit
  def edit
    @form = Form.find(params[:id])
    @page = @form.page
    return unless page_administrator!
  end

  # POST /forms
  # POST /forms.xml
  def create
    @form = Form.new(params[:form])
    if params.has_key?(:copy_form_id)
      @copy_form = Form.find(params[:copy_form_id])
      @form.copy(@copy_form)
    end
    @page = @form.page
    return unless page_administrator!

    respond_to do |format|
      if @form.save and (@copy_form or @form.create_default_fields)
        format.html { redirect_to(edit_form_url(@form),
          :notice => 'Form was successfully created.') }
        format.xml  { render :xml => @form, :status => :created, :location => @form }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /forms/1
  # PUT /forms/1.xml
  def update
    @form = Form.find(params[:id])
    @page = @form.page
    return unless page_administrator!
    ordered_field_ids = params[:field_order].split(',').map{|id| id.to_i}
    if current_user.administrator? and params[:choose_page_id] and
      Page.find_by_id(params[:choose_page_id])
      params[:form][:page_id] = params[:choose_page_id] # due to flexbox
    end

    respond_to do |format|
      if @form.update_attributes(params[:form]) and
        @form.order_fields(ordered_field_ids)
        format.html { redirect_to(new_form_fill_path(@form),
          :notice => 'Form was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @form.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /forms/1
  # DELETE /forms/1.xml
  def destroy
    @form = Form.find(params[:id])
    @page = @form.page
    return unless page_administrator!
    @form.destroy

    respond_to do |format|
      format.html { redirect_to(forms_url(:page_id => @page.id)) }
      format.xml  { head :ok }
    end
  end
end
